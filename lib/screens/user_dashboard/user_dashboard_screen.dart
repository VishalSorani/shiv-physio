import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../data/base_class/base_screen.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import 'appointments/appointments_screen.dart';
import 'gallery/gallery_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'settings/settings_screen.dart';
import 'user_dashboard_controller.dart';

class UserDashboardScreen extends BaseScreenView<UserDashboardController> {
  const UserDashboardScreen({super.key});

  static const String userDashboardScreen = '/user-dashboard';

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: GetBuilder<UserDashboardController>(
        id: UserDashboardController.contentId,
        builder: (controller) {
          // Show the appropriate screen based on current tab
          Widget currentScreen;
          switch (controller.currentTabIndex) {
            case UserDashboardController.appointmentsTabIndex:
              currentScreen = const AppointmentsScreen();
              break;
            case UserDashboardController.galleryTabIndex:
              currentScreen = const GalleryScreen();
              break;
            case UserDashboardController.profileTabIndex:
              currentScreen = const ProfileScreen();
              break;
            case UserDashboardController.settingsTabIndex:
              currentScreen = const UserSettingsScreen();
              break;
            case UserDashboardController.homeTabIndex:
            default:
              currentScreen = const HomeScreen();
              break;
          }

          return Stack(
            children: [
              currentScreen,
              // Bottom Navigation Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GetBuilder<UserDashboardController>(
                  id: UserDashboardController.bottomNavId,
                  builder: (controller) {
                    return AppBottomNavBar(
                      currentIndex: controller.currentTabIndex,
                      items: UserDashboardController.bottomNavItems,
                      onTap: controller.onBottomNavTap,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
