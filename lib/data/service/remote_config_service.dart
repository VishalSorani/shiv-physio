// // import 'package:find_my_player/services/app_info_service.dart';
// import 'dart:developer';
// import 'dart:io';

// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:pub_semver/pub_semver.dart';

// class FirebaseRemoteConfig extends GetxController {
//   static const String _androidMinVersionKey = 'android_version';
//   static const String _iosMinVersionKey = 'ios_version';
//   static const String _androidStoreUrlKey = 'androidStoreUrl';
//   static const String _iosStoreUrlKey = 'iosStoreUrl';
//   static const String _maxFreeRecipeGenerationsCountKey =
//       'max_free_recipe_generations_count';

//   final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
//   bool _isInitialized = false;

//   // final AppInfoService _appInfoService = AppInfoService.instance;

//   Future<bool> get needForceUpdate async {
//     final requiredVersionStr = getRequiredMinimumVersion();

//     final packageInfo = await PackageInfo.fromPlatform();

//     // * On Android, the current version shows as `X.Y.Z.flavor`
//     // * But semver can only parse this if it's formatted as `X.Y.Z-flavor`
//     // * and we only care about X.Y.Z, so we can remove the flavor
//     const flavorStr = appFlavor ?? '';
//     final currentVersionStr = flavorStr.isEmpty
//         ? packageInfo.version
//         : packageInfo.version.replaceAll('.$flavorStr', '');

//     // * Parse versions in semver format
//     try {
//       final requiredVersion = Version.parse(
//         _sanitizeVersion(requiredVersionStr),
//       );
//       final currentVersion = Version.parse(_sanitizeVersion(currentVersionStr));

//       return currentVersion < requiredVersion;
//     } on FormatException catch (e) {
//       log('Remote config version parsing error: $e');
//       return false;
//     }
//   }

//   Future<void> initialize() async {
//     if (_isInitialized) {
//       return;
//     }

//     try {
//       // Set configuration with shorter timeout to prevent hanging
//       await _remoteConfig.setConfigSettings(
//         RemoteConfigSettings(
//           fetchTimeout: const Duration(seconds: 10), // Reduced from 30
//           minimumFetchInterval: const Duration(seconds: 10),
//         ),
//       );

//       // Set default values to prevent crashes when fetch fails
//       await _remoteConfig.setDefaults(const {
//         _androidMinVersionKey: '1.0.1',
//         _iosMinVersionKey: '1.0.1',
//         _androidStoreUrlKey:
//             '',
//         _iosStoreUrlKey:
//             '',
//         _maxFreeRecipeGenerationsCountKey: '20',
//       });

//       // Fetch with error handling
//       await _remoteConfig.fetchAndActivate().catchError((error) {
//         log('Remote config fetch error: $error');
//         return false; // Use cached/default values
//       });

//       // Optional: listen for and activate changes to the Firebase Remote Config values
//       _remoteConfig.onConfigUpdated.listen((event) async {
//         try {
//           await _remoteConfig.activate();
//         } catch (e) {
//           log('Remote config activation error: $e');
//         }
//       });
//     } catch (e) {
//       log('Remote config initialization error: $e');
//       // Continue with default values
//     }

//     _isInitialized = true;
//   }

//   // Helper methods to simplify using the values in other parts of the code
//   String getRequiredMinimumVersion() {
//     final key = Platform.isIOS ? _iosMinVersionKey : _androidMinVersionKey;
//     return _remoteConfig.getString(key);
//   }

//   String getForceUpdateStoreUrl() {
//     final key = Platform.isIOS ? _iosStoreUrlKey : _androidStoreUrlKey;
//     return _remoteConfig.getString(key);
//   }

//   int getMaxFreeRecipeGenerationsCount() {
//     return _remoteConfig.getInt(_maxFreeRecipeGenerationsCountKey);
//   }

//   String _sanitizeVersion(String value) {
//     final sanitized = value.trim();
//     if (sanitized.isEmpty) {
//       return '0.0.0';
//     }

//     // Ensure semver compatibility by appending missing segments if required.
//     final segments = sanitized.split('.');
//     if (segments.length == 1) {
//       return '$sanitized.0.0';
//     } else if (segments.length == 2) {
//       return '$sanitized.0';
//     }
//     return sanitized;
//   }
// }
