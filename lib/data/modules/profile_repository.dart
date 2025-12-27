import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_class/base_repository.dart';
import '../service/storage_service.dart';

/// Repository for managing doctor profile data
class ProfileRepository extends BaseRepository {
  final SupabaseClient _supabase;
  final StorageService _storageService;
  final FirebaseStorage _firebaseStorage;

  ProfileRepository({
    required SupabaseClient supabase,
    required StorageService storageService,
    FirebaseStorage? firebaseStorage,
  })  : _supabase = supabase,
        _storageService = storageService,
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  /// Get current doctor ID from storage
  String? _getDoctorId() {
    final user = _storageService.getUser();
    return user?.id;
  }

  /// Upload profile photo to Firebase Storage
  Future<String> uploadProfilePhoto(File imageFile) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Uploading profile photo for doctor: $doctorId');

      // Create a reference to the file location
      final fileName = 'profile_photos/$doctorId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _firebaseStorage.ref().child(fileName);

      // Upload the file
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      logI('Profile photo uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      logE('Error uploading profile photo', error: e);
      handleRepositoryError(e);
      rethrow;
    }
  }

  /// Get doctor profile from Supabase
  Future<Map<String, dynamic>?> getDoctorProfile() async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        logW('No doctor ID found in storage');
        return null;
      }

      logD('Fetching doctor profile for: $doctorId');

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', doctorId)
          .eq('is_doctor', true)
          .maybeSingle();

      if (response == null) {
        logD('No doctor profile found');
        return null;
      }

      logI('Doctor profile fetched successfully');
      return Map<String, dynamic>.from(response);
    } catch (e) {
      logE('Error fetching doctor profile', error: e);
      handleRepositoryError(e);
      rethrow;
    }
  }

  /// Save doctor profile to Supabase
  /// Note: Additional fields (qualifications, specializations, etc.) are stored as JSON
  Future<void> saveDoctorProfile({
    required String fullName,
    String? avatarUrl,
    String? email,
    String? phone,
    String? title,
    String? qualifications,
    String? specializations,
    int? yearsOfExperience,
    String? clinicName,
    String? clinicAddress,
    int? consultationFee,
  }) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Saving doctor profile for: $doctorId');

      // Prepare profile data
      final profileData = <String, dynamic>{
        'id': doctorId,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'avatar_url': avatarUrl,
        // Store additional fields as JSON in a text field
        // We'll use a JSONB column if available, or store as JSON string
        // For now, we'll add these to a separate update
      };

      // Update the user record
      await _supabase.from('users').upsert(profileData);

      // Store additional profile fields in a JSON structure
      // Since we don't have a separate doctor_profile table, we'll store
      // additional data in a JSON field or extend the users table
      // For now, let's try to store in a JSONB column if it exists
      // Otherwise, we'll need to create a migration

      // Try to update with additional fields if the column exists
      final additionalData = <String, dynamic>{};
      if (title != null) additionalData['title'] = title;
      if (qualifications != null) additionalData['qualifications'] = qualifications;
      if (specializations != null) additionalData['specializations'] = specializations;
      if (yearsOfExperience != null) additionalData['years_of_experience'] = yearsOfExperience;
      if (clinicName != null) additionalData['clinic_name'] = clinicName;
      if (clinicAddress != null) additionalData['clinic_address'] = clinicAddress;
      if (consultationFee != null) additionalData['consultation_fee'] = consultationFee;

      // Add additional profile fields
      // Note: Migration 202512280001_add_doctor_profile_fields.sql adds these columns
      final updateData = <String, dynamic>{...profileData};
      
      if (title != null) updateData['title'] = title;
      if (qualifications != null) updateData['qualifications'] = qualifications;
      if (specializations != null) updateData['specializations'] = specializations;
      if (yearsOfExperience != null) updateData['years_of_experience'] = yearsOfExperience;
      if (clinicName != null) updateData['clinic_name'] = clinicName;
      if (clinicAddress != null) updateData['clinic_address'] = clinicAddress;
      if (consultationFee != null) updateData['consultation_fee'] = consultationFee;

      // Update with all fields
      await _supabase.from('users').upsert(updateData);

      logI('Doctor profile saved successfully');
    } catch (e) {
      logE('Error saving doctor profile', error: e);
      handleRepositoryError(e);
      rethrow;
    }
  }
}

