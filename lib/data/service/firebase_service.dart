import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shiv_physio_app/firebase_options.dart';

// import 'package:shiv_physio_app/firebase_options.dart';

/// Centralised entry point for Firebase Analytics and Crashlytics.
///
/// This service is responsible for initialising Firebase, exposing the shared
/// instances and providing a consistent API that the rest of the app can rely
/// on. All Firebase related calls should be routed through here.
class FirebaseAppService {
  FirebaseAppService._({
    required FirebaseAnalytics analytics,
    required FirebaseCrashlytics crashlytics,
  }) : _analytics = analytics,
       _crashlytics = crashlytics,
       _observer = FirebaseAnalyticsObserver(analytics: analytics);

  static FirebaseAppService? _instance;
  static bool _isInitialized = false;

  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;
  final FirebaseAnalyticsObserver _observer;

  /// Ensures Firebase is initialised and returns a singleton instance of the service.
  static Future<FirebaseAppService> initialize({
    bool enableInDebug = false,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final analytics = FirebaseAnalytics.instance;
    final crashlytics = FirebaseCrashlytics.instance;

    final shouldEnable = !kDebugMode || enableInDebug;

    await analytics.setAnalyticsCollectionEnabled(shouldEnable);
    await crashlytics.setCrashlyticsCollectionEnabled(shouldEnable);

    _configureErrorHandling(crashlytics);

    _instance = FirebaseAppService._(
      analytics: analytics,
      crashlytics: crashlytics,
    );
    _isInitialized = true;
    return _instance!;
  }

  /// Access the initialised instance. Throws if called before [initialize].
  static FirebaseAppService get instance {
    if (_instance == null) {
      throw StateError(
        'FirebaseAppService has not been initialized. Call initialize() before accessing instance.',
      );
    }
    return _instance!;
  }

  /// Whether Firebase has been initialised via this service.
  static bool get isInitialized => _isInitialized;

  FirebaseAnalytics get analytics => _analytics;

  FirebaseCrashlytics get crashlytics => _crashlytics;

  FirebaseAnalyticsObserver get observer => _observer;

  /// Logs a custom event to Firebase Analytics.
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    final Map<String, Object>? sanitisedParameters = _sanitizeParameters(
      parameters,
    );
    debugPrint('===========Log Event======');
    debugPrint('- name: $name');
    debugPrint('- parameters: $sanitisedParameters');
    debugPrint('===========================');
    await _analytics.logEvent(name: name, parameters: sanitisedParameters);
  }

  /// Logs screen view events to Firebase Analytics.
  Future<void> logScreenView({
    required String screenName,
    String screenClass = 'Screen',
  }) async {
    debugPrint('===========Log Screen View======');
    debugPrint('- screenName: $screenName');
    debugPrint('- screenClass: $screenClass');
    debugPrint('================================');
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// Sets the analytics user ID for tracking.
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Sets a custom user property for analytics segmentation.
  Future<void> setUserProperty({required String name, String? value}) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// Sets default parameters that are attached to every analytics event.
  Future<void> setDefaultEventParameters(
    Map<String, Object?> defaultParameters,
  ) async {
    final Map<String, Object>? sanitisedParameters = _sanitizeParameters(
      defaultParameters,
    );
    await _analytics.setDefaultEventParameters(sanitisedParameters);
  }

  /// Records non-fatal errors to Crashlytics.
  Future<void> recordNonFatalError(
    dynamic exception,
    StackTrace? stackTrace, {
    Iterable<Object>? information,
  }) async {
    await _crashlytics.recordError(
      exception,
      stackTrace,
      fatal: false,
      information: information ?? const <Object>[],
    );
  }

  /// Records fatal errors to Crashlytics.
  Future<void> recordFatalError(
    dynamic exception,
    StackTrace? stackTrace, {
    Iterable<Object>? information,
  }) async {
    await _crashlytics.recordError(
      exception,
      stackTrace,
      fatal: true,
      information: information ?? const <Object>[],
    );
  }

  /// Adds a custom key/value pair to Crashlytics logs.
  Future<void> setCrashlyticsCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// Adds a log entry to Crashlytics diagnostics.
  Future<void> logCrashlyticsMessage(String message) async {
    await _crashlytics.log(message);
  }

  /// Forces a test crash (only when analytics/crashlytics enabled).
  Future<void> crash() async {
    if (!isInitialized) return;
    _crashlytics.crash();
  }

  /// Updates the current user identifier in Crashlytics.
  Future<void> setCrashlyticsUserId(String? userId) async {
    await _crashlytics.setUserIdentifier(userId ?? '');
  }

  /// Resets analytics data (useful when logging out).
  Future<void> resetAnalyticsData() async {
    await _analytics.resetAnalyticsData();
  }

  Map<String, Object>? _sanitizeParameters(Map<String, Object?> parameters) {
    if (parameters.isEmpty) {
      return null;
    }

    final Map<String, Object> sanitised = {};
    parameters.forEach((key, value) {
      if (value == null) return;
      // Firebase Analytics only accepts String or num
      // Convert bool to String
      if (value is bool) {
        sanitised[key] = value.toString();
      } else if (value is num || value is String) {
        sanitised[key] = value;
      } else {
        sanitised[key] = value.toString();
      }
    });

    return sanitised.isEmpty ? null : sanitised;
  }

  static void _configureErrorHandling(FirebaseCrashlytics crashlytics) {
    FlutterError.onError = crashlytics.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }
}
