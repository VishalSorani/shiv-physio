import 'dart:async';

import '../../core/exceptions/app_exceptions.dart' as app_ex;
import '../base_class/base_repository.dart';
import '../models/token.dart';
import '../models/user.dart' as model;
import '../service/storage_service.dart';
import '../service/onesignal_service.dart';
import '../service/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// AuthRepository: owns all authentication-related business logic.
///
/// Current expectation for this project: Google Sign-In via Firebase Auth only.
class AuthRepository extends BaseRepository {
  final SupabaseClient _supabase;
  final StorageService _storageService;
  final fb_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  Completer<void>? _googleInitCompleter;

  AuthRepository({
    required SupabaseClient supabase,
    required StorageService storageService,
    fb_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _supabase = supabase,
       _storageService = storageService,
       _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitCompleter != null) {
      return _googleInitCompleter!.future;
    }
    _googleInitCompleter = Completer<void>();
    try {
      // google_sign_in >= 7 requires initialize() before authenticate().
      await _googleSignIn.initialize();
      _googleInitCompleter!.complete();
    } catch (e) {
      _googleInitCompleter!.completeError(e);
      rethrow;
    }
  }

  /// Sign in with Google.
  ///
  /// NOTE: This is the single entry point used by the LoginController.
  /// Returns the User object (stored in StorageService) and isDoctor status.
  Future<bool> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      // Already signed in? Refresh token in storage and return.
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final idToken = await currentUser.getIdToken(true);
        if (idToken == null || idToken.isEmpty) {
          throw app_ex.AuthException('Failed to refresh session token.');
        }
        await _persistFirebaseIdToken(idToken);
        final user = await _ensureSupabaseUserAndGetUser(
          firebaseUid: currentUser.uid,
          email: currentUser.email,
          fullName: currentUser.displayName,
          avatarUrl: currentUser.photoURL,
        );

        // Update OneSignal ID if available
        await _updateOneSignalId(currentUser.uid);

        await _storageService.setUser(user);
        return user.isDoctor;
      }

      // 1) Google account selection
      final googleAccount = await _googleSignIn.authenticate();

      final idToken = googleAccount.authentication.idToken;
      String? accessToken;
      try {
        final authz = await googleAccount.authorizationClient.authorizeScopes(
          const ['email'],
        );
        accessToken = authz.accessToken;
      } catch (_) {
        // Access token may not be available for all flows; Firebase can still
        // accept idToken-only credentials on supported platforms.
        accessToken = null;
      }

      if (idToken == null || idToken.isEmpty) {
        throw app_ex.AuthException('Google sign-in failed (missing id token).');
      }

      // 3) FirebaseAuth sign-in
      final credential = fb_auth.GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw app_ex.AuthException('Firebase sign-in failed.');
      }

      // 4) Persist Firebase ID token for API usage (Bearer)
      final firebaseIdToken = await firebaseUser.getIdToken(true);
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw app_ex.AuthException('Failed to fetch Firebase session token.');
      }
      await _persistFirebaseIdToken(firebaseIdToken);

      // 5) Ensure Supabase `public.users` row exists and store user info.
      final user = await _ensureSupabaseUserAndGetUser(
        firebaseUid: firebaseUser.uid,
        email: firebaseUser.email,
        fullName: firebaseUser.displayName,
        avatarUrl: firebaseUser.photoURL,
      );

      // 6) Update OneSignal ID if available
      await _updateOneSignalId(firebaseUser.uid);

      await _storageService.setUser(user);
      return user.isDoctor;
    } catch (e, stackTrace) {
      handleRepositoryError(e, stackTrace);
    }
  }

  Future<void> _persistFirebaseIdToken(String idToken) async {
    final tokens = Tokens(
      accessToken: idToken,
      refreshToken: null,
      tokenType: 'Bearer',
      expiresIn: null,
    );
    await _storageService.setToken(tokens);
  }

  /// Ensures a row exists in Supabase `public.users` and returns the full User object.
  ///
  /// IMPORTANT:
  /// Plan B1:
  /// - `public.users.id` is TEXT and stores the Firebase UID
  /// - `public.users` allows anon reads/writes
  Future<model.User> _ensureSupabaseUserAndGetUser({
    required String firebaseUid,
    required String? email,
    required String? fullName,
    required String? avatarUrl,
  }) async {
    return _ensureByIdFirebaseUid(
      firebaseUid: firebaseUid,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }

  Future<model.User> _ensureByIdFirebaseUid({
    required String firebaseUid,
    required String? email,
    required String? fullName,
    required String? avatarUrl,
  }) async {
    try {
      // Use upsert to handle both insert (new user) and update (existing user)
      // Upsert will insert if id doesn't exist, or update if it does
      // Note: We don't include 'created_at' so it will:
      // - Use the database default (now()) for new inserts
      // - Preserve the existing value for updates
      final now = DateTime.now().toIso8601String();

      final userData = <String, dynamic>{
        'id': firebaseUid,
        'email': email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'updated_at': now,
      };

      // Upsert the user (handles primary key conflict automatically)
      final result = await _supabase
          .from('users')
          .upsert(userData)
          .select()
          .single();

      return model.User.fromJson(result);
    } catch (e) {
      logE('Failed to upsert user in Supabase', error: e);
      throw app_ex.AuthException(
        'Supabase user sync failed. Ensure you applied migration `202512270003_plan_b1_users_id_text_fix.sql`.',
        originalError: e,
      );
    }
  }

  /// Check if user profile is complete (has phone number)
  /// Returns true if profile is complete, false otherwise
  Future<bool> isUserProfileComplete() async {
    try {
      final user = _storageService.getUser();
      if (user == null) {
        return false;
      }

      // Check if user has phone number
      // Profile is considered complete if phone is not null and not empty
      return user.phone != null && user.phone!.trim().isNotEmpty;
    } catch (e) {
      logE('Error checking user profile completeness', error: e);
      return false;
    }
  }

  /// Update OneSignal ID in database
  Future<void> _updateOneSignalId(String userId) async {
    try {
      // Check if OneSignal is initialized
      if (!OneSignalService.isInitialized) {
        logW('OneSignal not initialized, skipping OneSignal ID update');
        return;
      }

      // Get OneSignal player ID
      final oneSignalService = OneSignalService.instance;
      final playerId = await oneSignalService.getPlayerId();

      if (playerId == null || playerId.isEmpty) {
        logW('OneSignal player ID not available, skipping update');
        return;
      }

      // Update OneSignal ID in Supabase
      await _supabase
          .from('users')
          .update({'onesignal_id': playerId})
          .eq('id', userId);

      logI('OneSignal ID updated for user: $userId');
    } catch (e) {
      logE('Error updating OneSignal ID', error: e);
      // Don't throw - OneSignal ID update failure shouldn't break login
    }
  }

  /// Sign out from Firebase and clear all stored data
  Future<void> signOut() async {
    try {
      logD('Signing out user');

      // 1. Sign out from Firebase Auth
      await _firebaseAuth.signOut();
      logD('Signed out from Firebase Auth');

      // 2. Sign out from Google Sign In
      try {
        await _googleSignIn.signOut();
        logD('Signed out from Google Sign In');
      } catch (e) {
        logW('Error signing out from Google: $e');
        // Continue even if Google sign out fails
      }

      // 3. Clear all stored user data and tokens
      await _storageService.clearUserData();
      logD('Cleared user data from storage');

      // 4. Sign out from Supabase (if needed)
      try {
        await _supabase.auth.signOut();
        logD('Signed out from Supabase');
      } catch (e) {
        logW('Error signing out from Supabase: $e');
        // Continue even if Supabase sign out fails
      }

      // 5. Reset analytics and Crashlytics
      if (FirebaseAppService.isInitialized) {
        try {
          await FirebaseAppService.instance.resetAnalyticsData();
          await FirebaseAppService.instance.setUserId(null);
          await FirebaseAppService.instance.setCrashlyticsUserId(null);
          logD('Reset analytics data');
        } catch (e) {
          logW('Error resetting analytics: $e');
          // Continue even if analytics reset fails
        }
      }

      logI('User signed out successfully');
    } catch (e) {
      logE('Error during sign out', error: e);
      // Even if there's an error, try to clear storage
      try {
        await _storageService.clearUserData();
      } catch (clearError) {
        logE('Error clearing storage during sign out', error: clearError);
      }
      rethrow;
    }
  }
}
