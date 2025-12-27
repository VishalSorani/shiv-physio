// lib/data/clients/permissions/permission_handler_client.dart

import '/data/clients/permission/permission_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PermissionHandlerClient implements PermissionClient {
  const PermissionHandlerClient();

  Future<bool> _requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      debugPrint(
        'Permission request result for ${permission.toString()}: $status',
      );
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  // ignore: unused_element
  Future<bool> _hasPermission(Permission permission) async {
    try {
      final status = await permission.status;
      debugPrint('Permission status for ${permission.toString()}: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking permission status: $e');
      return false;
    }
  }

  @override
  Future<bool> checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      debugPrint('Notification permission status: $status');

      if (status.isGranted) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        debugPrint('Notification permission is permanently denied');
        return false;
      }
      return false;
      // return await _requestPermission(Permission.notification);
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return false;
    }
  }

  @override
  Future<bool> requestNotificationPermission() async {
    try {
      return await _requestPermission(Permission.notification);
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  @override
  Future<bool> launchAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('Error launching app settings: $e');
      return false;
    }
  }

  @override
  Future<bool> checkCameraPermission() {
    throw UnimplementedError();
  }

  @override
  Future<bool> checkLocationPermission() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      debugPrint('Location permission status: $status');

      if (status.isGranted) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        debugPrint('Location permission is permanently denied');
        return false;
      }

      return false;
      // If you want to auto-request here instead, call _requestPermission.
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  @override
  Future<bool> checkMicrophonePermission() {
    throw UnimplementedError();
  }

  @override
  Future<bool> checkPhotosPermission() {
    throw UnimplementedError();
  }

  @override
  Future<bool> requestCameraPermission() {
    throw UnimplementedError();
  }

  @override
  Future<bool> requestLocationPermission() async {
    try {
      // Request foreground location; background behavior is configured via manifest/Info.plist
      return await _requestPermission(Permission.locationWhenInUse);
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  @override
  Future<bool> requestMicrophonePermission() {
    throw UnimplementedError();
  }

  @override
  Future<bool> requestPhotosPermission() {
    throw UnimplementedError();
  }
}
