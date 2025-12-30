import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shiv_physio_app/core/exceptions/app_exceptions.dart';
// import 'package:safecircle/data/service/amplitude_service.dart';
import 'package:shiv_physio_app/data/service/firebase_service.dart';
import 'package:shiv_physio_app/data/service/navigation_service/navigation_import.dart';
import 'package:shiv_physio_app/data/service/network_service.dart';
import 'package:shiv_physio_app/widgets/app_snackbar.dart';

/// Base controller that provides common functionality for all controllers
/// including app lifecycle callbacks.
///
/// Lifecycle callbacks you can override:
/// - onResumed() - When app returns to foreground
/// - onPaused() - When app goes to background
/// - onInactive() - When app is inactive (e.g., during phone calls)
/// - onDetached() - When controller is about to be destroyed
abstract class BaseController extends GetxController
    with WidgetsBindingObserver {
  static const String baseScreenId = 'base_screen';
  static bool _isServerMaintenanceActive = false;
  static bool get isServerMaintenanceActive => _isServerMaintenanceActive;

  final NavigationService navigationService = Get.find<NavigationService>();
  final NetworkService networkService = Get.find<NetworkService>();

  // Track last known offline state to avoid duplicate notifications
  bool _wasDisconnected = false;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Show loading state
  bool _showLoading = true;
  bool get showLoading => _showLoading;

  // is Data Loading
  bool _isDataLoading = false;
  bool get isDataLoading => _isDataLoading;

  @override
  void onInit() {
    super.onInit();
    _checkAndCallOnGetArgs();
    networkService.addConnectivityListener(handleNetworkChange);
    // Register for lifecycle callbacks
    WidgetsBinding.instance.addObserver(this);
  }

  void _checkAndCallOnGetArgs() {
    if (Get.arguments != null) {
      onGetArgs(Get.arguments);
    }
  }

  void onGetArgs(dynamic args) {
    log('Get arguments: $args', name: 'BaseController');
  }

  @override
  void onClose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    networkService.removeConnectivityListener(handleNetworkChange);
    onDetached();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log('App lifecycle state changed: $state', name: 'BaseController');
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
        onInactive();
        break;
      case AppLifecycleState.paused:
        onPaused();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
      case AppLifecycleState.hidden:
        // Handle hidden state if needed
        break;
    }
  }

  /// Handle network connectivity changes
  ///
  /// [isConnected] `true` if device is connected to network, `false` otherwise
  void handleNetworkChange(bool isConnected);

  /// Default handling for network changes to provide consistent UX
  /// Call this from your controller's handleNetworkChange implementation.
  /// - Shows a single offline warning when connection is lost
  /// - Shows a single online success when connection returns and triggers refresh
  @protected
  Future<void> handleNetworkChangeDefault(bool isConnected) async {
    if (!isConnected) {
      if (!_wasDisconnected) {
        _wasDisconnected = true;
        AppSnackBar.warning(
          title: 'No Internet Connection',
          message: 'Please check your internet connection and try again.',
        );
      }
      return;
    }

    // Connected
    if (_wasDisconnected) {
      _wasDisconnected = false;
      AppSnackBar.success(
        title: 'Back online',
        message: 'Refreshing latest data…',
      );
      try {
        await onReconnectRefresh();
      } catch (e) {
        // Surface error via snackbar to keep user informed
        AppSnackBar.error(title: 'Refresh failed', message: e.toString());
      }
    }
  }

  /// Override in controllers to refresh page data after reconnection
  /// Default: no-op
  @protected
  Future<void> onReconnectRefresh() async {}

  /// Called when the app returns to the foreground
  /// Override this method to handle app resume events
  @mustCallSuper
  void onResumed() {
    log('App Resumed', name: 'BaseController');
  }

  /// Called when the app is inactive (e.g., during phone calls, app switching, etc.)
  /// Override this method to handle app inactive events
  @mustCallSuper
  void onInactive() {
    log('App Inactive', name: 'BaseController');
  }

  /// Called when the app goes to the background
  /// Override this method to handle app pause events
  @mustCallSuper
  void onPaused() {
    log('App Paused', name: 'BaseController');
  }

  /// Called when the controller is about to be destroyed
  /// Override this method to perform cleanup
  @mustCallSuper
  void onDetached() {
    log('Controller Detached', name: 'BaseController');
  }

  /// Set loading state and update UI
  void setLoading(bool value, {bool showLoading = true}) {
    if (_isLoading != value) {
      _isLoading = value;
      _showLoading = showLoading;
      update();
      update([baseScreenId]);
    }
  }

  /// Set data loading state and update UI
  void setDataLoading(bool value) {
    if (_isDataLoading != value) {
      _isDataLoading = value;
      update();
      update([baseScreenId]);
    }
  }

  /// Helper method to handle async operations with loading state
  Future<T> handleAsyncOperation<T>(
    Future<T> Function() operation, {
    bool showLoading = true,
    bool showLoadingIndicator = true,
    bool showSnackBar = true,
    bool showMaintenanceDialog = true,
    VoidCallback? onMaintenanceRetry,
  }) async {
    try {
      if (showLoading) setLoading(true, showLoading: showLoadingIndicator);
      setDataLoading(true);
      final result = await operation();
      _resolveServerMaintenanceMode();
      return result;
    } on NetworkException catch (e) {
      // Record network errors to Crashlytics
      unawaited(
        recordNonFatalError(
          e,
          StackTrace.current,
          information: [
            'operation_type: async_operation',
            'error_code: ${e.code ?? 'unknown'}',
            'error_message: ${e.message}',
          ],
        ),
      );
      final bool handled =
          showMaintenanceDialog && _shouldShowServerMaintenanceDialog(e);
      if (handled) {
        _showServerMaintenanceDialog(onMaintenanceRetry);
      } else if (showSnackBar) {
        AppSnackBar.error(title: 'Error', message: e.message);
      }
      throw e.message;
    } catch (e, stackTrace) {
      final NetworkException? networkError = _extractNetworkException(e);
      final bool handled =
          showMaintenanceDialog &&
          networkError != null &&
          _shouldShowServerMaintenanceDialog(networkError);

      // Prefer clean API/network messages over generic toString()
      final String errorMessage;
      if (e is AppException) {
        errorMessage = e.message;
      } else if (networkError != null) {
        errorMessage = networkError.message;
      } else {
        errorMessage = e.toString();
      }

      // Record all errors to Crashlytics
      unawaited(
        recordNonFatalError(
          e,
          stackTrace,
          information: [
            'operation_type: async_operation',
            'error_message: $errorMessage',
            'is_network_error: ${networkError != null}',
          ],
        ),
      );

      if (handled) {
        _showServerMaintenanceDialog(onMaintenanceRetry);
      } else if (showSnackBar) {
        AppSnackBar.error(title: 'Error', message: errorMessage);
      }
      throw errorMessage;
    } finally {
      if (showLoading) setLoading(false);
      setDataLoading(false);
    }
  }

  /// handle async operation with only error handling
  /// [operation] - the async operation to perform
  /// [showSnackBar] - whether to show a snackbar on error
  Future<T> handleAsyncOperationWithOnlyErrorHandling<T>(
    Future<T> Function() operation, {
    bool showSnackBar = true,
    bool showMaintenanceDialog = true,
    VoidCallback? onMaintenanceRetry,
  }) async {
    try {
      final result = await operation();
      _resolveServerMaintenanceMode();
      return result;
    } on NetworkException catch (e) {
      // Track API errors to Analytics
      trackAnalyticsEvent(
        'api_error',
        parameters: {
          'status_code': e.code ?? 'unknown',
          'message': e.message,
          'operation_type': 'async_operation_error_handling',
        },
      );
      // Record network errors to Crashlytics
      unawaited(
        recordNonFatalError(
          e,
          StackTrace.current,
          information: [
            'operation_type: async_operation_error_handling',
            'error_code: ${e.code ?? 'unknown'}',
            'error_message: ${e.message}',
          ],
        ),
      );
      final bool handled =
          showMaintenanceDialog && _shouldShowServerMaintenanceDialog(e);
      if (handled) {
        _showServerMaintenanceDialog(onMaintenanceRetry);
      } else if (showSnackBar) {
        AppSnackBar.error(title: 'Error', message: e.message);
      }
      throw e.message;
    } catch (e, stackTrace) {
      final NetworkException? networkError = _extractNetworkException(e);
      // Track API errors for network exceptions
      if (networkError != null) {
        trackAnalyticsEvent(
          'api_error',
          parameters: {
            'status_code': networkError.code ?? 'unknown',
            'message': networkError.message,
            'operation_type': 'async_operation_error_handling',
          },
        );
      }
      final bool handled =
          showMaintenanceDialog &&
          networkError != null &&
          _shouldShowServerMaintenanceDialog(networkError);

      final String errorMessage;
      if (e is AppException) {
        errorMessage = e.message;
      } else if (networkError != null) {
        errorMessage = networkError.message;
      } else {
        errorMessage = e.toString();
      }

      // Record all errors to Crashlytics
      unawaited(
        recordNonFatalError(
          e,
          stackTrace,
          information: [
            'operation_type: async_operation_error_handling',
            'error_message: $errorMessage',
            'is_network_error: ${networkError != null}',
          ],
        ),
      );

      if (handled) {
        _showServerMaintenanceDialog(onMaintenanceRetry);
      } else if (showSnackBar) {
        AppSnackBar.error(title: 'Error', message: errorMessage);
      }
      throw errorMessage;
    }
  }

  /// Logs a Firebase Analytics event using the shared [FirebaseAppService].
  /// Note: This only tracks to Firebase. Use trackAmplitudeEvent() separately
  /// for Amplitude with Title Case event names.
  @protected
  void trackAnalyticsEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) {
    _trackFirebaseEvent(name, parameters: parameters);
    // Do not automatically track to Amplitude to avoid duplicate events
    // Amplitude events should be tracked separately with Title Case names
  }

  /// Logs a Firebase Analytics screen view event.
  @protected
  void trackScreenView(String screenName, {String screenClass = 'Screen'}) {
    _trackFirebaseScreen(screenName, screenClass: screenClass);
    // trackAmplitudeScreenView(screenName, screenClass: screenClass);
  }

  /// Logs a Amplitude Analytics event using the shared [AmplitudeService].
  @protected
  void trackAmplitudeEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) {
    // TODO: Implement Amplitude event tracking
  }

  /// Logs a Amplitude Analytics screen view event.
  @protected
  void trackAmplitudeScreenView(
    String screenName, {
    String screenClass = 'Screen',
  }) {
    // if (!AmplitudeService.isInitialized) {
    //   return;
    // }
    // unawaited(
    //   AmplitudeService.instance
    //       .logScreenView(screenName: screenName, screenClass: screenClass)
    //       .catchError((error, _) {
    //         debugPrint(
    //           'Failed to log Amplitude screen view $screenName: $error',
    //         );
    //       }),
    // );
  }

  void _trackFirebaseEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) {
    if (!FirebaseAppService.isInitialized) {
      return;
    }
    unawaited(
      FirebaseAppService.instance
          .logEvent(name, parameters: parameters)
          .catchError((error, _) {
            debugPrint('Failed to log event $name: $error');
          }),
    );
  }

  void _trackFirebaseScreen(
    String screenName, {
    String screenClass = 'Screen',
  }) {
    if (!FirebaseAppService.isInitialized) {
      return;
    }
    unawaited(
      FirebaseAppService.instance
          .logScreenView(screenName: screenName, screenClass: screenClass)
          .catchError((error, _) {
            debugPrint('Failed to log screen view $screenName: $error');
          }),
    );
  }

  /// Records non-fatal error to Crashlytics.
  @protected
  Future<void> recordNonFatalError(
    dynamic exception,
    StackTrace? stackTrace, {
    Iterable<Object>? information,
  }) async {
    if (!FirebaseAppService.isInitialized) {
      return;
    }
    try {
      await FirebaseAppService.instance.recordNonFatalError(
        exception,
        stackTrace,
        information: information,
      );
    } catch (e) {
      debugPrint('Failed to record non-fatal error to Crashlytics: $e');
    }
  }

  /// Records fatal error to Crashlytics.
  @protected
  Future<void> recordFatalError(
    dynamic exception,
    StackTrace? stackTrace, {
    Iterable<Object>? information,
  }) async {
    if (!FirebaseAppService.isInitialized) {
      return;
    }
    try {
      await FirebaseAppService.instance.recordFatalError(
        exception,
        stackTrace,
        information: information,
      );
    } catch (e) {
      debugPrint('Failed to record fatal error to Crashlytics: $e');
    }
  }

  /// Sets Crashlytics user identifier.
  @protected
  Future<void> setCrashlyticsUserId(String? userId) async {
    if (!FirebaseAppService.isInitialized) {
      return;
    }
    try {
      await FirebaseAppService.instance.setCrashlyticsUserId(userId);
    } catch (e) {
      debugPrint('Failed to set Crashlytics user ID: $e');
    }
  }

  /// Sets a custom key in Crashlytics.
  @protected
  Future<void> setCrashlyticsCustomKey(String key, dynamic value) async {
    if (!FirebaseAppService.isInitialized) {
      return;
    }
    try {
      await FirebaseAppService.instance.setCrashlyticsCustomKey(key, value);
    } catch (e) {
      debugPrint('Failed to set Crashlytics custom key: $e');
    }
  }

  /// Logs a message to Crashlytics.
  @protected
  Future<void> logCrashlyticsMessage(String message) async {
    if (!FirebaseAppService.isInitialized) {
      return;
    }
    try {
      await FirebaseAppService.instance.logCrashlyticsMessage(message);
    } catch (e) {
      debugPrint('Failed to log message to Crashlytics: $e');
    }
  }

  /// Sets the analytics user id across providers.
  @protected
  Future<void> setAnalyticsUserId(String? userId) async {
    final futures = <Future<void>>[];
    if (FirebaseAppService.isInitialized) {
      futures.add(FirebaseAppService.instance.setUserId(userId));
    }
    // if (AmplitudeService.isInitialized) {
    //   futures.add(AmplitudeService.instance.setUserId(userId));
    // }
    await Future.wait(futures);
  }

  /// Sets analytics user properties across providers.
  @protected
  Future<void> setAnalyticsUserProperties(
    Map<String, Object?> properties,
  ) async {
    final futures = <Future<void>>[];
    if (FirebaseAppService.isInitialized) {
      for (final entry in properties.entries) {
        futures.add(
          FirebaseAppService.instance.setUserProperty(
            name: entry.key,
            value: entry.value?.toString(),
          ),
        );
      }
    }
    // if (AmplitudeService.isInitialized) {
    //   futures.add(AmplitudeService.instance.setUserProperties(properties));
    // }
    await Future.wait(futures);
  }

  /// Sets analytics user ID and properties from user model.
  /// This is a convenience method to set all analytics properties at once.
  @protected
  Future<void> setUserAnalytics({
    required String userId,
    String? userType,
    String? email,
    bool? hasPhone,
    Map<String, Object?>? additionalProperties,
  }) async {
    await setAnalyticsUserId(userId);
    await setCrashlyticsUserId(userId);

    final properties = <String, Object?>{
      if (userType != null) 'user_type': userType,
      if (email != null) 'email': email,
      if (hasPhone != null) 'has_phone': hasPhone,
      if (additionalProperties != null) ...additionalProperties,
    };

    if (properties.isNotEmpty) {
      await setAnalyticsUserProperties(properties);
    }

    if (userType != null) {
      await setCrashlyticsCustomKey('user_type', userType);
    }
  }

  bool _shouldShowServerMaintenanceDialog(NetworkException error) {
    final int? status = int.tryParse(error.code ?? '0');
    if (status != null && <int>{500, 502, 503, 504}.contains(status)) {
      return true;
    }
    if (status == 400) {
      final String normalized = error.message.toLowerCase();
      if (normalized.contains('<!doctype html') ||
          normalized.contains('ngrok')) {
        return true;
      }
    }
    final String message = error.message.toLowerCase();
    return message.contains('server is temporarily unavailable') ||
        message.contains('maintenance') ||
        message.contains('ngrok') ||
        message.contains('<!doctype html');
  }

  void _showServerMaintenanceDialog(VoidCallback? onRetry) {
    _activateServerMaintenanceMode();
    if (Get.isDialogOpen == true) {
      return;
    }
    // unawaited(
    // AppDialog.showServerMaintenance(
    //   onRetry: () {
    //     onRetry?.call();
    //   },
    // ),
    // );
  }
}

NetworkException? _extractNetworkException(dynamic error) {
  if (error is NetworkException) {
    return error;
  }
  if (error is AppException && error.originalError is NetworkException) {
    return error.originalError as NetworkException;
  }
  return null;
}

void _activateServerMaintenanceMode() {
  if (!BaseController._isServerMaintenanceActive) {
    BaseController._isServerMaintenanceActive = true;
  }
}

void _resolveServerMaintenanceMode() {
  if (BaseController._isServerMaintenanceActive) {
    BaseController._isServerMaintenanceActive = false;
  }
}
