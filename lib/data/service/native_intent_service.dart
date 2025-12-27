import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shiv_physio_app/widgets/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Enum representing different sharing platforms
enum SharePlatform {
  sms,
  whatsapp,
  email,
  facebookMessenger,
  instagram,
  x,
  tiktok,
  system, // Added system option for generic share
}

/// Data class for share options
class ShareOption {
  final SharePlatform platform;
  final String label;
  final IconData icon;
  final String? packageName; // Android package name or iOS URL scheme

  const ShareOption({
    required this.platform,
    required this.label,
    required this.icon,
    this.packageName,
  });
}

/// A service for handling native interactions with device capabilities including
/// sharing, phone calls, maps, and URL opening
class NativeIntentService {
  // List of share options with their respective icons and package names
  // List of share options with their respective icons and package names
  List<ShareOption> get shareOptions => [
    const ShareOption(
      platform: SharePlatform.sms,
      label: 'SMS',
      icon: Icons.sms,
      packageName: 'sms:',
    ),
    ShareOption(
      platform: SharePlatform.whatsapp,
      label: 'WhatsApp',
      icon: Icons.message,
      packageName: Platform.isAndroid ? 'com.whatsapp' : 'whatsapp:',
    ),
    const ShareOption(
      platform: SharePlatform.email,
      label: 'Email',
      icon: Icons.email,
      packageName: 'mailto:',
    ),
    ShareOption(
      platform: SharePlatform.facebookMessenger,
      label: 'Messenger',
      icon: Icons.facebook,
      packageName: Platform.isAndroid ? 'com.facebook.orca' : 'fb-messenger:',
    ),
    ShareOption(
      platform: SharePlatform.instagram,
      label: 'Instagram',
      icon: Icons.camera_alt,
      packageName: Platform.isAndroid ? 'com.instagram.android' : 'instagram:',
    ),
    ShareOption(
      platform: SharePlatform.x,
      label: 'X',
      icon: Icons.alternate_email,
      packageName: Platform.isAndroid ? 'com.twitter.android' : 'twitter:',
    ),
    ShareOption(
      platform: SharePlatform.tiktok,
      label: 'TikTok',
      icon: Icons.music_note,
      packageName: Platform.isAndroid ? 'com.zhiliaoapp.musically' : 'tiktok:',
    ),
    const ShareOption(
      platform: SharePlatform.system,
      label: 'More',
      icon: Icons.more_horiz,
    ),
  ];

  /// Try to launch a URL and handle errors
  Future<bool> _tryLaunchUrl(Uri uri, String appName) async {
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppSnackBar.error(title: 'Error', message: 'Unable to launch $appName');
        return false;
      }
    } catch (e) {
      AppSnackBar.error(
        title: 'Error',
        message: 'Error launching $appName: $e',
      );
      return false;
    }
  }

  //----------------------------------------------------------------------------
  // URL Opening Functionality
  //----------------------------------------------------------------------------

  /// Open a URL in the browser
  Future<bool> openUrl(String url) async {
    try {
      // Ensure URL has a scheme
      String processedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        processedUrl = 'https://$url';
      }

      final Uri uri = Uri.parse(processedUrl);
      return await _tryLaunchUrl(uri, 'Browser');
    } catch (e) {
      AppSnackBar.error(title: 'Error', message: 'Error opening URL: $e');
      return false;
    }
  }
}
