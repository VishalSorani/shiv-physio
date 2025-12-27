part of 'navigation_import.dart';

class NavigationService {
  //  extends GetxService

  // ignore: unused_field
  final NetworkService _networkService;
  final FirebaseAppService? _firebaseService;
  // final AmplitudeService? _amplitudeService;

  final bool _enableLogging;

  NavigationService({
    required NetworkService networkService,
    bool enableLogging = true,
    FirebaseAppService? firebaseService,
    // AmplitudeService? amplitudeService,
  }) : _enableLogging = enableLogging,
       // _amplitudeService = amplitudeService,
       _firebaseService = firebaseService,
       _networkService = networkService;

  /// Private method to navigate to a new screen
  Future<dynamic> _navigateTo(String route, {dynamic arguments}) async {
    try {
      await _networkService.checkInternetConnection();
      _logNavigation('navigate_to', route, arguments);
      return await Get.toNamed(route, arguments: arguments);
    } catch (e) {
      AppSnackBar.error(title: 'Error', message: e.toString());
      return;
    }
  }

  Future<dynamic> navigateToRoute(String route, {dynamic arguments}) {
    return _navigateTo(route, arguments: arguments);
  }

  /// Navigate to a route and remove all previous screens from the navigation stack
  Future<dynamic> offAllToRoute(String route, {dynamic arguments}) {
    return _navigateToAndRemoveUntil(route, arguments: arguments);
  }

  /// Private method to navigate to a new screen and remove the previous screen
  // ignore: unused_element
  Future<dynamic> _navigateToAndRemove(
    String route, {
    dynamic arguments,
  }) async {
    try {
      await _networkService.checkInternetConnection();
      _logNavigation('navigate_to_and_remove', route, arguments);
      return await Get.offAndToNamed(route, arguments: arguments);
    } catch (e) {
      AppSnackBar.error(title: 'Error', message: e.toString());
      return;
    }
  }

  /// Private method to navigate to a new screen and remove all previous screens
  // ignore: unused_element
  Future<dynamic> _navigateToAndRemoveUntil(
    String route, {
    dynamic arguments,
  }) async {
    try {
      await _networkService.checkInternetConnection();
      _logNavigation('navigate_to_and_remove_until', route, arguments);
      return await Get.offAllNamed(route, arguments: arguments);
    } catch (e) {
      AppSnackBar.error(title: 'Error', message: e.toString());
      return;
    }
  }

  //offAll
  Future<dynamic> offAll(String route, {dynamic arguments}) async {
    try {
      await _networkService.checkInternetConnection();
      _logNavigation('off_all', route, arguments);
      return await Get.offAllNamed(route, arguments: arguments);
    } catch (e) {
      AppSnackBar.error(title: 'Error', message: e.toString());
      return;
    }
  }

  /// Go back to the previous screen
  void goBack({dynamic arguments}) {
    _logNavigation('go_back', Get.currentRoute);
    Get.back(result: arguments);
  }

  bool canGoBack() {
    return Get.key.currentState?.canPop() ?? false;
  }

  /// Log navigation events to analytics
  void _logNavigation(String action, String route, [dynamic arguments]) {
    // Log to console if enabled
    if (_enableLogging) {
      logger('Navigation: $action - $route, Arguments: $arguments');
    }

    // Log to analytics if client is available
    try {
      _firebaseService?.logEvent(
        'navigation',
        parameters: {
          'action': action,
          'route': route,
          'arguments': arguments?.toString() ?? '',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (_isScreenNavigationAction(action)) {
        _firebaseService?.logScreenView(
          screenName: route,
          screenClass: 'Screen',
        );
      }

      // _amplitudeService?.logEvent(
      //   'navigation',
      //   parameters: {
      //     'action': action,
      //     'route': route,
      //     'arguments': arguments?.toString() ?? '',
      //     'timestamp': DateTime.now().toIso8601String(),
      //   },
      // );

      // if (_isScreenNavigationAction(action)) {
      //   _amplitudeService?.logScreenView(
      //     screenName: route,
      //     screenClass: 'Screen',
      //   );
      // }
    } catch (e) {
      logger('Error logging navigation to analytics: $e');
    }
  }

  bool _isScreenNavigationAction(String action) {
    return action == 'navigate_to' ||
        action == 'navigate_to_and_remove' ||
        action == 'navigate_to_and_remove_until';
  }

  // logger
  void logger(String message) {
    log('NavigationService: $message');
  }
}
