import 'package:flutter/material.dart';
import '../../data/base_class/base_controller.dart';
import '../../widgets/app_bottom_nav_bar.dart';

class DoctorDashboardController extends BaseController {
  static const String contentId = 'doctor_dashboard_content';
  static const String bottomNavId = 'bottom_nav';

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  // Tab indices
  static const int homeTabIndex = 0;
  static const int appointmentsTabIndex = 1;
  static const int chatTabIndex = 2;
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
      label: 'Appointments',
      index: appointmentsTabIndex,
    ),
    BottomNavItem(
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble,
      label: 'Chat',
      index: chatTabIndex,
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

  void onBottomNavTap(int index) {
    if (_currentTabIndex == index) return;

    // Allow all tabs including Chat
    _currentTabIndex = index;
    update([bottomNavId, contentId]);
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
  }
}
