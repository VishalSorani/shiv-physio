import 'package:flutter/material.dart';

import '../../data/base_class/base_controller.dart';
import '../../data/service/location_service.dart';
import '../../data/service/remote_config_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/service_unavailable_dialog.dart';

class UserDashboardController extends BaseController {
  static const String contentId = 'user_dashboard_content';
  static const String bottomNavId = 'bottom_nav';

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  // City availability
  bool? _isCityAvailable;
  bool? get isCityAvailable => _isCityAvailable;
  String? _userCity;
  String? get userCity => _userCity;

  // Tab indices
  static const int homeTabIndex = 0;
  static const int appointmentsTabIndex = 1;
  static const int galleryTabIndex = 2;
  static const int profileTabIndex = 3;
  static const int settingsTabIndex = 4;

  // Bottom nav items
  static const List<BottomNavItem> bottomNavItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      index: homeTabIndex,
    ),
    BottomNavItem(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      label: 'Schedule',
      index: appointmentsTabIndex,
    ),
    BottomNavItem(
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble,
      label: 'Messages',
      index: galleryTabIndex,
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
      index: profileTabIndex,
    ),
    BottomNavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
      index: settingsTabIndex,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    // Track screen view
    trackScreenView('user_dashboard_screen');
    // Check city availability on dashboard load
    _checkCityAvailability();
  }

  /// Check if user's city is in allowed cities list
  Future<void> _checkCityAvailability() async {
    try {
      // Get user's city from IP API
      final city = await LocationService.instance.getCity();
      _userCity = city;

      if (city == null || city.isEmpty) {
        // If city cannot be determined, allow access (graceful degradation)
        _isCityAvailable = true;
        return;
      }

      // Check if city is in allowed cities from Remote Config
      if (RemoteConfigService.isInitialized) {
        final remoteConfigService = RemoteConfigService.instance;
        _isCityAvailable = remoteConfigService.isCityAllowed(city);

        // Track analytics event
        trackAnalyticsEvent(
          'city_availability_checked',
          parameters: {
            'city': city,
            'is_available': (_isCityAvailable ?? false).toString(),
          },
        );
      } else {
        // If Remote Config not initialized, allow access
        _isCityAvailable = true;
      }
    } catch (e) {
      debugPrint('Error checking city availability: $e');
      // On error, allow access (graceful degradation)
      _isCityAvailable = true;
    }
  }

  /// Check if booking is allowed and show dialog if not
  bool canBookAppointment(BuildContext context) {
    if (_isCityAvailable == false) {
      // Show service unavailable dialog
      ServiceUnavailableDialog.show(context);

      // Track analytics event
      trackAnalyticsEvent(
        'booking_blocked_city_unavailable',
        parameters: {'city': _userCity ?? 'unknown'},
      );

      return false;
    }
    return true;
  }

  void onBottomNavTap(int index) {
    if (_currentTabIndex == index) return;

    // Just switch tabs. Do NOT auto-navigate to chat conversation.
    // Chat conversation should open only on explicit user action
    // (e.g., tapping a conversation in the list, or tapping "Chat" button).
    _currentTabIndex = index;
    update([bottomNavId, contentId]);
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
  }
}
