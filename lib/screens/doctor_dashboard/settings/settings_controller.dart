import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/modules/auth_repository.dart';
import '../../../data/service/navigation_service/navigation_import.dart';
import '../../../screens/login/login_screen.dart';
import '../../../widgets/app_snackbar.dart';

class DoctorSettingsController extends BaseController {
  static const String settingsId = 'doctor_settings';

  final AuthRepository _authRepository;
  final NavigationService _navigationService;

  DoctorSettingsController(
    this._authRepository,
    this._navigationService,
  );

  // Settings state
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  bool _emailNotificationsEnabled = true;
  bool get emailNotificationsEnabled => _emailNotificationsEnabled;

  bool _darkModeEnabled = false;
  bool get darkModeEnabled => _darkModeEnabled;

  /// Toggle notifications
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    update([settingsId]);
    // TODO: Save to storage/preferences
  }

  /// Toggle email notifications
  void toggleEmailNotifications(bool value) {
    _emailNotificationsEnabled = value;
    update([settingsId]);
    // TODO: Save to storage/preferences
  }

  /// Toggle dark mode
  void toggleDarkMode(bool value) {
    _darkModeEnabled = value;
    update([settingsId]);
    // TODO: Save to storage/preferences and apply theme
  }

  /// Handle logout with confirmation
  Future<void> onLogout() async {
    // Show confirmation dialog
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? You will need to sign in again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await handleAsyncOperation(() async {
        // Sign out from Firebase and clear storage
        await _authRepository.signOut();

        // Navigate to login screen
        _navigationService.offAllToRoute(
          LoginScreen.loginScreen,
          requireNetwork: false,
        );
      });
    }
  }

  /// Handle account settings
  void onAccountSettings() {
    AppSnackBar.info(
      title: 'Coming Soon',
      message: 'Account settings feature will be available soon',
    );
  }

  /// Handle privacy settings
  void onPrivacySettings() {
    AppSnackBar.info(
      title: 'Coming Soon',
      message: 'Privacy settings feature will be available soon',
    );
  }

  /// Handle help & support
  void onHelpSupport() {
    AppSnackBar.info(
      title: 'Coming Soon',
      message: 'Help & support feature will be available soon',
    );
  }

  /// Handle about
  void onAbout() {
    AppSnackBar.info(
      title: 'Coming Soon',
      message: 'About feature will be available soon',
    );
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // TODO: implement handleNetworkChange
  }
}

