import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiv_physio_app/data/models/token.dart';
import 'package:shiv_physio_app/data/models/user.dart';

import '/data/clients/storage/storage_provider.dart';

class StorageService {
  final StorageProvider _storageProvider;

  static const String _tokenKey = '@storage_Key';
  static const String _userDataKey = '@user_Data';

  StorageService(this._storageProvider);

  // logs
  void logger(String message) {
    log('StorageService: $message');
  }

  /// Saves user data to storage
  Future<void> setUser(User user) async {
    await _storageProvider.write(_userDataKey, user.toJson());
    logger('setUser: $user');
  }

  // Retrieves user data from storage
  User? getUser() {
    final userData = _storageProvider.read<Map<String, dynamic>>(_userDataKey);
    if (userData == null) {
      return null;
    }
    logger('getUser: $userData');
    return User.fromJson(userData);
  }

  /// Checks if user data is present in storage
  bool hasUser() {
    final userData = _storageProvider.read<Map<String, dynamic>>(_userDataKey);
    return userData != null;
  }

  /// Clears user data from storage
  Future<void> clearUser() async {
    await _storageProvider.delete(_userDataKey);
    logger('clearUser');
  }

  /// Clears all user related data (user and token)
  Future<void> clearUserData() async {
    await clearUser();
    await clearToken();
    logger('clearAuthData');
  }

  //set token
  Future<void> setToken(Tokens token) async {
    await _storageProvider.write(_tokenKey, token.toJson());
    logger('setToken: $token');

    // Also sync to SharedPreferences for background worker access
    // Background workers run in separate isolates and need SharedPreferences
    if (token.accessToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bg_access_token', token.accessToken!);
      logger('Synced access token to SharedPreferences for background worker');
    }
  }

  //get token
  Tokens? getToken() {
    final tokenData = _storageProvider.read<Map<String, dynamic>>(_tokenKey);
    if (tokenData == null) {
      return null;
    }
    logger('getToken: $tokenData');
    return Tokens.fromJson(tokenData);
  }

  //get access token
  String? getAccessToken() {
    final token = getToken();
    logger('====================== Access Token =========================');
    logger('getAccessToken: ${token?.accessToken}');
    logger('=============================================================');
    return token?.accessToken;
  }

  //get refresh token
  String? getRefreshToken() {
    final token = getToken();
    logger('====================== Refresh Token =========================');
    logger('getRefreshToken: ${token?.refreshToken}');
    logger('=============================================================');
    return token?.refreshToken;
  }

  //clear token
  Future<void> clearToken() async {
    await _storageProvider.delete(_tokenKey);
    logger('clearToken');

    // Also clear from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bg_access_token');
    logger('Cleared access token from SharedPreferences');
  }
}
