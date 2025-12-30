import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/base_class/base_controller.dart';
import '../../data/service/remote_config_service.dart';
import '../../widgets/app_snackbar.dart';

class ForceUpdateController extends BaseController {
  static const String contentId = 'force_update_content';
  static const String iconId = 'force_update_icon';
  static const String buttonId = 'force_update_button';

  final RemoteConfigService _remoteConfigService;

  ForceUpdateController(this._remoteConfigService);

  String _latestVersion = '1.0.0';
  String get latestVersion => _latestVersion;

  bool _showPulse = true;
  bool get showPulse => _showPulse;

  @override
  void onInit() {
    super.onInit();
    // Track screen view
    trackScreenView('force_update_screen');

    _loadVersionInfo();
    _startPulseAnimation();
  }

  void _loadVersionInfo() {
    try {
      _latestVersion = _remoteConfigService.getLatestVersion();
      if (_latestVersion.isEmpty) {
        _latestVersion = '1.0.0';
      }
      update([contentId]);
    } catch (e) {
      debugPrint('Error loading version info: $e');
    }
  }

  void _startPulseAnimation() {
    // Pulse animation will be handled by the widget
  }

  void togglePulse() {
    _showPulse = !_showPulse;
    update([iconId]);
  }

  Future<void> onUpdateTap() async {
    try {
      // Track analytics event
      trackAnalyticsEvent('force_update_button_tapped', parameters: {
        'current_version': _latestVersion,
      });

      final storeUrl = _remoteConfigService.getStoreUrl();

      if (storeUrl.isEmpty) {
        // Fallback to default store URLs
        final defaultUrl = GetPlatform.isAndroid
            ? 'https://play.google.com/store/apps/details?id=com.shivphysio.app'
            : 'https://apps.apple.com/app/id123456789'; // Replace with actual App Store ID

        await _launchUrl(defaultUrl);
      } else {
        await _launchUrl(storeUrl);
      }
    } catch (e) {
      debugPrint('Error opening store: $e');
      AppSnackBar.error(
        title: 'Error',
        message: 'Unable to open app store. Please update manually.',
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // Force update screen doesn't need network change handling
  }
}

