import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/modules/auth_repository.dart';
import '../../../data/service/navigation_service/navigation_import.dart';
import '../../../data/service/remote_config_service.dart';
import '../../../screens/login/login_screen.dart';
import '../../../widgets/app_snackbar.dart';

class DoctorSettingsController extends BaseController {
  static const String settingsId = 'doctor_settings';

  final AuthRepository _authRepository;
  final NavigationService _navigationService;
  final RemoteConfigService _remoteConfigService;

  DoctorSettingsController(
    this._authRepository,
    this._navigationService,
    this._remoteConfigService,
  );

  @override
  void onInit() {
    super.onInit();
    // Track screen view
    trackScreenView('doctor_settings_screen');
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
      // Track logout event
      trackAnalyticsEvent('logout_attempt', parameters: {
        'user_type': 'doctor',
      });

      await handleAsyncOperation(() async {
        // Sign out from Firebase and clear storage
        await _authRepository.signOut();

        // Track successful logout
        trackAnalyticsEvent('logout_success', parameters: {
          'user_type': 'doctor',
        });

        // Navigate to login screen
        _navigationService.offAllToRoute(
          LoginScreen.loginScreen,
          requireNetwork: false,
        );
      });
    }
  }

  /// Handle privacy policy - open URL from Remote Config
  Future<void> onPrivacyPolicy() async {
    try {
      final privacyPolicyUrl = _remoteConfigService.getPrivacyPolicyUrl();
      
      if (privacyPolicyUrl.isEmpty) {
        AppSnackBar.error(
          title: 'Error',
          message: 'Privacy policy URL is not configured',
        );
        return;
      }

      final uri = Uri.parse(privacyPolicyUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        // Track analytics
        trackAnalyticsEvent('privacy_policy_opened', parameters: {
          'user_type': 'doctor',
        });
      } else {
        AppSnackBar.error(
          title: 'Error',
          message: 'Could not open privacy policy URL',
        );
      }
    } catch (e) {
      debugPrint('Error opening privacy policy: $e');
      AppSnackBar.error(
        title: 'Error',
        message: 'Failed to open privacy policy',
      );
    }
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // TODO: implement handleNetworkChange
  }
}

