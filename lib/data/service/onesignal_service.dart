import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal Notification Service
/// Handles initialization, device registration, and notification events
class OneSignalService {
  OneSignalService._();

  static OneSignalService? _instance;
  static bool _isInitialized = false;

  /// OneSignal App ID
  static const String _appId = '534bfa2f-3aad-4158-8c0f-2fdec84feae3';

  Function(dynamic)? _onNotificationReceived;
  Function(dynamic)? _onNotificationOpened;

  /// Get singleton instance
  static OneSignalService get instance {
    if (_instance == null) {
      throw StateError(
        'OneSignalService has not been initialized. Call initialize() before accessing instance.',
      );
    }
    return _instance!;
  }

  /// Whether OneSignal has been initialized
  static bool get isInitialized => _isInitialized;

  String? _playerId;
  String? get playerId => _playerId;

  /// Initialize OneSignal with the app ID
  static Future<OneSignalService> initialize({
    Function(dynamic)? onNotificationReceived,
    Function(dynamic)? onNotificationOpened,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    try {
      _instance = OneSignalService._();
      _instance!._onNotificationReceived = onNotificationReceived;
      _instance!._onNotificationOpened = onNotificationOpened;

      // Initialize OneSignal with app ID
      // Note: API may vary by SDK version - adjust as needed
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      OneSignal.initialize(_appId);

      // Request permission for iOS
      OneSignal.Notifications.requestPermission(true);

      // Set up notification handlers
      // Note: API methods may vary by SDK version - using dynamic to handle differences
      try {
        // Try to set up foreground notification handler
        final notifications = OneSignal.Notifications;
        try {
          // Try the standard API first
          (notifications as dynamic).addForegroundLifecycleListener?.call((
            OSNotification notification,
          ) {
            debugPrint(
              '📬 OneSignal notification received (foreground): ${notification.notificationId}',
            );
            _instance!._onNotificationReceived?.call(notification);
          });
        } catch (e) {
          debugPrint('⚠️ Foreground listener method not available: $e');
        }
      } catch (e) {
        debugPrint('⚠️ Foreground listener setup failed: $e');
      }

      try {
        // Try to set up click handler
        final notifications = OneSignal.Notifications;
        try {
          // Try the standard API first
          (notifications as dynamic).addClickListener?.call((dynamic result) {
            debugPrint('📬 OneSignal notification opened');
            try {
              final notification = (result as dynamic).notification;
              if (notification != null) {
                debugPrint('Notification ID: ${notification.notificationId}');
              }
            } catch (e) {
              debugPrint('Error accessing notification: $e');
            }
            _instance!._onNotificationOpened?.call(result);
          });
        } catch (e) {
          debugPrint('⚠️ Click listener method not available: $e');
        }
      } catch (e) {
        debugPrint('⚠️ Click listener setup failed: $e');
      }

      // Get player ID (device token) - wait a bit for initialization
      await Future.delayed(const Duration(milliseconds: 1000));
      try {
        final deviceState = await OneSignal.User.pushSubscription.id;
        if (deviceState != null) {
          _instance!._playerId = deviceState;
          debugPrint('✅ OneSignal Player ID: $deviceState');
        }
      } catch (e) {
        debugPrint('⚠️ Error getting initial Player ID: $e');
      }

      // Listen for subscription changes
      try {
        OneSignal.User.pushSubscription.addObserver((state) {
          if (state.current.id != null) {
            _instance!._playerId = state.current.id;
            debugPrint('📱 OneSignal Player ID updated: ${state.current.id}');
          }
        });
      } catch (e) {
        debugPrint('⚠️ Subscription observer setup failed: $e');
      }

      _isInitialized = true;
      debugPrint('✅ OneSignal initialized successfully');

      return _instance!;
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing OneSignal: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get the current player ID (device token)
  Future<String?> getPlayerId() async {
    try {
      final deviceState = await OneSignal.User.pushSubscription.id;
      if (deviceState != null) {
        _playerId = deviceState;
        return deviceState;
      }
      return _playerId;
    } catch (e) {
      debugPrint('❌ Error getting OneSignal Player ID: $e');
      return _playerId;
    }
  }

  /// Set external user ID (for associating notifications with your user)
  Future<void> setExternalUserId(String userId) async {
    try {
      await OneSignal.login(userId);
      debugPrint('✅ OneSignal external user ID set: $userId');
    } catch (e) {
      debugPrint('❌ Error setting OneSignal external user ID: $e');
    }
  }

  /// Remove external user ID (for logout)
  Future<void> removeExternalUserId() async {
    try {
      await OneSignal.logout();
      debugPrint('✅ OneSignal external user ID removed');
    } catch (e) {
      debugPrint('❌ Error removing OneSignal external user ID: $e');
    }
  }

  /// Send a tag (custom data) to OneSignal
  Future<void> sendTag(String key, String value) async {
    try {
      // Try different API methods based on SDK version
      final user = OneSignal.User;
      try {
        // Try addTag method
        await (user as dynamic).addTag?.call(key, value);
      } catch (e) {
        // Fallback: try addTags method with map
        try {
          await (user as dynamic).addTags?.call({key: value});
        } catch (e2) {
          debugPrint('⚠️ Both addTag methods failed: $e, $e2');
          rethrow;
        }
      }
      debugPrint('✅ OneSignal tag sent: $key = $value');
    } catch (e) {
      debugPrint('❌ Error sending OneSignal tag: $e');
    }
  }

  /// Remove a tag
  Future<void> removeTag(String key) async {
    try {
      await OneSignal.User.removeTag(key);
      debugPrint('✅ OneSignal tag removed: $key');
    } catch (e) {
      debugPrint('❌ Error removing OneSignal tag: $e');
    }
  }

  /// Set notification permission status
  Future<void> setNotificationPermission(bool enabled) async {
    try {
      if (enabled) {
        await OneSignal.Notifications.requestPermission(true);
      }
      debugPrint('✅ OneSignal notification permission set: $enabled');
    } catch (e) {
      debugPrint('❌ Error setting OneSignal notification permission: $e');
    }
  }

  /// Check if notifications are enabled
  Future<bool> isNotificationEnabled() async {
    try {
      final permission = await OneSignal.Notifications.permission;
      return permission;
    } catch (e) {
      debugPrint('❌ Error checking OneSignal notification permission: $e');
      return false;
    }
  }
}
