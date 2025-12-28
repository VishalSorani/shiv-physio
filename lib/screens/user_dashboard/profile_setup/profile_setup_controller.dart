import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/service/storage_service.dart';
import '../../../widgets/app_snackbar.dart';
import '../../user_dashboard/user_dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileSetupController extends BaseController {
  // GetBuilder IDs
  static const String appBarId = 'profile_setup_appbar';
  static const String headerId = 'profile_setup_header';
  static const String photoId = 'profile_setup_photo';
  static const String fullNameId = 'profile_setup_fullname';
  static const String phoneId = 'profile_setup_phone';
  static const String addressId = 'profile_setup_address';
  static const String buttonId = 'profile_setup_button';
  static const String skipButtonId = 'profile_setup_skip';

  final StorageService _storageService;
  final SupabaseClient _supabase;
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  ProfileSetupController(this._storageService, this._supabase);

  // State variables
  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;

  String _fullName = '';
  String get fullName => _fullName;

  String _phoneNumber = '';
  String get phoneNumber => _phoneNumber;

  String _address = '';
  String get address => _address;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _storageService.getUser();
    if (user != null) {
      _fullName = user.fullName ?? '';
      _phoneNumber = user.phone ?? '';
      _avatarUrl = user.avatarUrl;
      update([fullNameId, phoneId, photoId]);
    }
  }

  void updatePhoneNumber(String value) {
    _phoneNumber = value;
    update([phoneId]);
  }

  void updateAddress(String value) {
    _address = value;
    update([addressId]);
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

  Future<void> onSaveAndContinue() async {
    if (_isSaving) return;

    await HapticFeedback.lightImpact();

    // Validate phone number (basic validation)
    if (_phoneNumber.trim().isEmpty) {
      AppSnackBar.error(
        title: 'Validation Error',
        message: 'Please enter your phone number',
      );
      return;
    }

    _isSaving = true;
    update([buttonId]);

    try {
      await handleAsyncOperation(() async {
        final user = _storageService.getUser();
        if (user == null) {
          throw Exception('User not found');
        }

        // Update user profile in Supabase
        final updateData = <String, dynamic>{
          'id': user.id,
          'phone': _phoneNumber.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (_avatarUrl != null) {
          updateData['avatar_url'] = _avatarUrl;
        }

        if (_address.trim().isNotEmpty) {
          updateData['address'] = _address.trim();
        }

        await _supabase.from('users').upsert(updateData);

        // Update local storage
        final updatedUser = user.copyWith(
          phone: _phoneNumber.trim(),
          avatarUrl: _avatarUrl,
          address: _address.trim().isNotEmpty ? _address.trim() : null,
        );
        await _storageService.setUser(updatedUser);

        AppSnackBar.success(
          title: 'Success',
          message: 'Profile updated successfully',
        );

        // Navigate to user dashboard
        await Future.delayed(const Duration(milliseconds: 500));
        navigationService.offAllToRoute(
          UserDashboardScreen.userDashboardScreen,
          requireNetwork: false,
        );
      });
    } finally {
      _isSaving = false;
      update([buttonId]);
    }
  }

  Future<void> onSkip() async {
    await HapticFeedback.lightImpact();
    navigationService.offAllToRoute(
      UserDashboardScreen.userDashboardScreen,
      requireNetwork: false,
    );
  }

  void onBack() {
    navigationService.goBack();
  }

  @override
  void handleNetworkChange(bool isConnected) {
    handleNetworkChangeDefault(isConnected);
  }
}
