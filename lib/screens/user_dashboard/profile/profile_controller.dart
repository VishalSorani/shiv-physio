import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/service/storage_service.dart';
import '../../../widgets/app_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum Gender { male, female, other }

class ProfileController extends BaseController {
  static const String contentId = 'profile_content';
  static const String photoId = 'profile_photo';
  static const String formId = 'profile_form';
  static const String saveButtonId = 'save_button';

  final StorageService _storageService;
  final SupabaseClient _supabase;
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  ProfileController(
    this._storageService,
    this._supabase,
  );

  // Form controllers
  late final TextEditingController _fullNameController;
  late final TextEditingController _ageController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get ageController => _ageController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get addressController => _addressController;

  // State variables
  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;

  Gender? _selectedGender;
  Gender? get selectedGender => _selectedGender;

  bool _isPhoneVerified = false;
  bool get isPhoneVerified => _isPhoneVerified;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String get genderDisplayText {
    switch (_selectedGender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case null:
        return 'Select Gender';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _fullNameController = TextEditingController();
    _ageController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _loadUserData();
  }

  @override
  void onClose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.onClose();
  }

  void _loadUserData() {
    final user = _storageService.getUser();
    if (user != null) {
      _fullNameController.text = user.fullName ?? '';
      _ageController.text = user.age?.toString() ?? '';
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      _avatarUrl = user.avatarUrl;
      _isPhoneVerified = user.phone != null && user.phone!.isNotEmpty;

      // Parse gender
      if (user.gender != null) {
        switch (user.gender!.toLowerCase()) {
          case 'male':
            _selectedGender = Gender.male;
            break;
          case 'female':
            _selectedGender = Gender.female;
            break;
          case 'other':
            _selectedGender = Gender.other;
            break;
        }
      }

      update([formId, photoId]);
    }
  }

  void updateGender(Gender? gender) {
    _selectedGender = gender;
    update([formId]);
  }

  Future<void> onPhotoTap() async {
    try {
      await HapticFeedback.lightImpact();
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        await handleAsyncOperation(() async {
          // Upload to Firebase Storage
          final file = File(image.path);
          final user = _storageService.getUser();
          if (user == null) {
            throw Exception('User not found');
          }

          // Create a reference to the file location
          final fileName =
              'profile_photos/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          final ref = _firebaseStorage.ref().child(fileName);

          // Upload the file
          final uploadTask = ref.putFile(
            file,
            SettableMetadata(
              contentType: 'image/jpeg',
              cacheControl: 'public, max-age=31536000',
            ),
          );

          // Wait for upload to complete
          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();

          _avatarUrl = downloadUrl;
          update([photoId]);

          AppSnackBar.success(
            title: 'Success',
            message: 'Photo uploaded successfully',
          );
        });
      }
    } catch (e) {
      AppSnackBar.error(
        title: 'Error',
        message: 'Failed to upload photo: ${e.toString()}',
      );
    }
  }

  Future<void> onSave() async {
    if (_isSaving) return;

    await HapticFeedback.lightImpact();

    // Validate required fields
    if (_fullNameController.text.trim().isEmpty) {
      AppSnackBar.error(
        title: 'Validation Error',
        message: 'Please enter your full name',
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      AppSnackBar.error(
        title: 'Validation Error',
        message: 'Please enter your phone number',
      );
      return;
    }

    _isSaving = true;
    update([saveButtonId]);

    try {
      await handleAsyncOperation(() async {
        final user = _storageService.getUser();
        if (user == null) {
          throw Exception('User not found');
        }

        // Parse age
        int? age;
        if (_ageController.text.trim().isNotEmpty) {
          age = int.tryParse(_ageController.text.trim());
        }

        // Update user profile in Supabase
        final updateData = <String, dynamic>{
          'id': user.id,
          'full_name': _fullNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'age': age,
          'address': _addressController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (_avatarUrl != null) {
          updateData['avatar_url'] = _avatarUrl;
        }

        if (_selectedGender != null) {
          updateData['gender'] = _selectedGender!.name;
        }

        await _supabase.from('users').upsert(updateData);

        // Update local storage
        final updatedUser = user.copyWith(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          age: age,
          address: _addressController.text.trim(),
          avatarUrl: _avatarUrl,
          gender: _selectedGender?.name,
        );
        await _storageService.setUser(updatedUser);

        AppSnackBar.success(
          title: 'Success',
          message: 'Profile updated successfully',
        );

        update([formId, photoId]);
      });
    } finally {
      _isSaving = false;
      update([saveButtonId]);
    }
  }

  void onBack() {
    navigationService.goBack();
  }

  String getInitials() {
    final name = _fullNameController.text.trim();
    if (name.isEmpty) return 'PC';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  void handleNetworkChange(bool isConnected) {
    handleNetworkChangeDefault(isConnected);
  }
}
