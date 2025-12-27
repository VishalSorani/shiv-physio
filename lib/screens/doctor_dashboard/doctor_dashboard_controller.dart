import 'package:flutter/material.dart';
import '../../data/base_class/base_controller.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_snackbar.dart';

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
  ];

  void onBottomNavTap(int index) {
    if (_currentTabIndex == index) return;

    // Allow Home, Appointments, and Profile tabs; Chat shows "Coming soon"
    if (index != homeTabIndex &&
        index != appointmentsTabIndex &&
        index != profileTabIndex) {
      AppSnackBar.comingSoon();
      return;
    }

    _currentTabIndex = index;
    update([bottomNavId, contentId]);
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
  }
}
