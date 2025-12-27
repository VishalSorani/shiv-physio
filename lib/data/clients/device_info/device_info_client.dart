import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '/data/clients/device_info/device_info_provider.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoClient implements DeviceInfoProvider {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  @override
  Future<String> getDeviceId() async {
    logger('Getting device ID');
    String deviceId = '';

    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        deviceId = webInfo.userAgent ?? webInfo.vendor ?? 'unknown';
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        deviceId = windowsInfo.deviceId;
      } else if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        deviceId = macOsInfo.systemGUID ?? 'unknown';
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        deviceId = linuxInfo.machineId ?? 'unknown';
      }
    } catch (e) {
      logger('Error getting device ID: $e');
      deviceId = 'unknown';
      rethrow;
    }

    logger('Device ID: $deviceId');
    return deviceId;
  }

  @override
  Future<String> getDeviceModel() async {
    logger('Getting device model');
    String model = '';

    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        model = webInfo.browserName.toString();
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        model = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        model = iosInfo.model;
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        model = windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        model = macOsInfo.model;
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        model = linuxInfo.name;
      }
    } catch (e) {
      logger('Error getting device model: $e');
      model = 'unknown';
      rethrow;
    }

    logger('Device model: $model');
    return model;
  }

  @override
  Future<String> getDeviceOsVersion() async {
    logger('Getting OS version');
    String osVersion = '';

    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        osVersion = webInfo.platform ?? 'unknown';
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        osVersion = androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        osVersion = iosInfo.systemVersion;
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        osVersion =
            '${windowsInfo.majorVersion}.${windowsInfo.minorVersion}.${windowsInfo.buildNumber}';
      } else if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        osVersion = macOsInfo.osRelease;
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        osVersion = linuxInfo.version ?? 'unknown';
      }
    } catch (e) {
      logger('Error getting OS version: $e');
      osVersion = 'unknown';
      rethrow;
    }

    logger('OS version: $osVersion');
    return osVersion;
  }

  @override
  Future<Map<String, dynamic>> getAllDeviceInfo() async {
    logger('Getting all device info');
    Map<String, dynamic> deviceData = {};

    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        deviceData = webInfo.data;
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceData = _convertAndroidInfo(androidInfo);
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceData = _convertIosInfo(iosInfo);
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        deviceData = windowsInfo.data;
      } else if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        deviceData = macOsInfo.data;
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        deviceData = linuxInfo.data;
      }
    } catch (e) {
      logger('Error getting all device info: $e');
      deviceData = {'error': e.toString()};
      rethrow;
    }

    logger('All device info retrieved');
    return deviceData;
  }

  Map<String, dynamic> _convertAndroidInfo(AndroidDeviceInfo info) {
    return {
      'id': info.id,
      'model': info.model,
      'brand': info.brand,
      'manufacturer': info.manufacturer,
      'device': info.device,
      'product': info.product,
      'androidId': info.id,
      'isPhysicalDevice': info.isPhysicalDevice,
      'sdkInt': info.version.sdkInt,
      'release': info.version.release,
      'securityPatch': info.version.securityPatch,
      'board': info.board,
      'bootloader': info.bootloader,
      'display': info.display,
      'fingerprint': info.fingerprint,
      'hardware': info.hardware,
      'host': info.host,
      'supported32BitAbis': info.supported32BitAbis,
      'supported64BitAbis': info.supported64BitAbis,
      'supportedAbis': info.supportedAbis,
      'tags': info.tags,
      'type': info.type,
    };
  }

  Map<String, dynamic> _convertIosInfo(IosDeviceInfo info) {
    return {
      'name': info.name,
      'systemName': info.systemName,
      'systemVersion': info.systemVersion,
      'model': info.model,
      'localizedModel': info.localizedModel,
      'identifierForVendor': info.identifierForVendor,
      'isPhysicalDevice': info.isPhysicalDevice,
      'utsname': {
        'sysname': info.utsname.sysname,
        'nodename': info.utsname.nodename,
        'release': info.utsname.release,
        'version': info.utsname.version,
        'machine': info.utsname.machine,
      },
    };
  }

  @override
  Future<String> getAppVersion() async {
    logger('Getting app version');
    String version = 'unknown';

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      version = '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      logger('Error getting app version: $e');
      rethrow;
    }

    logger('App version: $version');
    return version;
  }

  @override
  Future<bool> isPhysicalDevice() async {
    try {
      if (kIsWeb) return false;

      if (Platform.isAndroid) {
        return _deviceInfo.androidInfo.then((info) => info.isPhysicalDevice);
      } else if (Platform.isIOS) {
        return _deviceInfo.iosInfo.then((info) => info.isPhysicalDevice);
      } else {
        return false; // Emulators not common for desktop platforms
      }
    } catch (e) {
      logger('Error checking physical device: $e');
      rethrow;
    }
  }

  void logger(String message) {
    log('DeviceInfoClient: $message');
  }

  @override
  Future<String> getDevicePlatform() async {
    if (kIsWeb) return 'web';
    if (Platform.isIOS || Platform.isMacOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    // Default fallback for desktop platforms if needed
    if (Platform.isWindows || Platform.isLinux) return 'android';
    return 'android';
  }
}

// Don't forget to add these dependencies to your pubspec.yaml:
  // device_info_plus: ^11.3.3
  // package_info_plus: ^8.3.0