import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Service for managing Firebase Remote Config
/// Handles version checking for force updates
class RemoteConfigService {
  static RemoteConfigService? _instance;
  static bool _isInitialized = false;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Remote Config Keys
  static const String _androidMinVersionKey = 'android_version';
  static const String _iosMinVersionKey = 'ios_version';
  static const String _androidStoreUrlKey = 'android_store_url';
  static const String _iosStoreUrlKey = 'ios_store_url';
  static const String _latestVersionKey = 'latest_version';
  static const String _allowedCitiesKey = 'allowed_cities';
  static const String _privacyPolicyUrlKey = 'privacy_policy_url';
  static const String _termsOfServiceUrlKey = 'terms_of_service_url';

  RemoteConfigService._();

  /// Get singleton instance
  static RemoteConfigService get instance {
    _instance ??= RemoteConfigService._();
    return _instance!;
  }

  /// Whether Remote Config has been initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize Remote Config with default values
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Set configuration with timeout
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 10),
        ),
      );

      // Set default values to prevent crashes when fetch fails
      await _remoteConfig.setDefaults({
        _androidMinVersionKey: '1.0.0',
        _iosMinVersionKey: '1.0.0',
        _androidStoreUrlKey: '',
        _iosStoreUrlKey: '',
        _latestVersionKey: '1.0.0',
        _allowedCitiesKey: '["Rajkot"]', // Empty JSON array as default
        _privacyPolicyUrlKey: '',
        _termsOfServiceUrlKey: '',
      });

      // Fetch and activate
      await _remoteConfig.fetchAndActivate().catchError((error) {
        log('Remote config fetch error: $error');
        return false; // Use cached/default values
      });

      // Listen for config updates
      _remoteConfig.onConfigUpdated.listen((event) async {
        try {
          await _remoteConfig.activate();
          log('Remote config updated and activated');
        } catch (e) {
          log('Remote config activation error: $e');
        }
      });
    } catch (e) {
      log('Remote config initialization error: $e');
      // Continue with default values
    }

    _isInitialized = true;
  }

  /// Check if force update is required
  /// Returns true if current version is less than minimum required version
  Future<bool> isForceUpdateRequired() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final requiredVersion = getRequiredMinimumVersion();

      return _compareVersions(currentVersion, requiredVersion) < 0;
    } catch (e) {
      log('Error checking force update: $e');
      return false; // Don't block app if version check fails
    }
  }

  /// Get required minimum version from Remote Config
  String getRequiredMinimumVersion() {
    final key = Platform.isIOS ? _iosMinVersionKey : _androidMinVersionKey;
    return _remoteConfig.getString(key);
  }

  /// Get latest version from Remote Config
  String getLatestVersion() {
    return _remoteConfig.getString(_latestVersionKey);
  }

  /// Get store URL for the current platform
  String getStoreUrl() {
    final key = Platform.isIOS ? _iosStoreUrlKey : _androidStoreUrlKey;
    return _remoteConfig.getString(key);
  }

  /// Get list of allowed cities from Remote Config
  /// Returns empty list if not configured or parsing fails
  List<String> getAllowedCities() {
    try {
      final citiesJson = _remoteConfig.getString(_allowedCitiesKey);
      if (citiesJson.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(citiesJson) as List;
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      log('Error parsing allowed cities: $e');
      return [];
    }
  }

  /// Check if a city is in the allowed cities list
  bool isCityAllowed(String? city) {
    if (city == null || city.isEmpty) {
      return false;
    }

    final allowedCities = getAllowedCities();
    if (allowedCities.isEmpty) {
      // If no cities configured, allow all (backward compatibility)
      return true;
    }

    // Case-insensitive comparison
    return allowedCities.any(
      (allowedCity) => allowedCity.toLowerCase() == city.toLowerCase(),
    );
  }

  /// Get privacy policy URL from Remote Config
  String getPrivacyPolicyUrl() {
    return _remoteConfig.getString(_privacyPolicyUrlKey);
  }

  /// Get terms of service URL from Remote Config
  String getTermsOfServiceUrl() {
    return _remoteConfig.getString(_termsOfServiceUrlKey);
  }

  /// Compare two version strings (e.g., "1.0.1" vs "1.0.2")
  /// Returns:
  /// - negative if version1 < version2
  /// - zero if version1 == version2
  /// - positive if version1 > version2
  int _compareVersions(String version1, String version2) {
    try {
      final v1Parts = version1.split('.').map(int.parse).toList();
      final v2Parts = version2.split('.').map(int.parse).toList();

      // Pad shorter version with zeros
      while (v1Parts.length < v2Parts.length) {
        v1Parts.add(0);
      }
      while (v2Parts.length < v1Parts.length) {
        v2Parts.add(0);
      }

      for (int i = 0; i < v1Parts.length; i++) {
        if (v1Parts[i] < v2Parts[i]) {
          return -1;
        } else if (v1Parts[i] > v2Parts[i]) {
          return 1;
        }
      }
      return 0;
    } catch (e) {
      log('Error comparing versions: $e');
      return 0; // If parsing fails, assume versions are equal
    }
  }
}
