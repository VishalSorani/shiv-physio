import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../data/base_class/base_screen.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import 'appointments/appointments_screen.dart';
import 'chat/chat_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'doctor_dashboard_controller.dart';

class DoctorDashboardScreen extends BaseScreenView<DoctorDashboardController> {
  const DoctorDashboardScreen({super.key});

  static const String doctorDashboardScreen = '/doctor-dashboard';

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: GetBuilder<DoctorDashboardController>(
        id: DoctorDashboardController.contentId,
        builder: (controller) {
          // Show the appropriate screen based on current tab
          Widget currentScreen;
          switch (controller.currentTabIndex) {
            case DoctorDashboardController.appointmentsTabIndex:
              currentScreen = const DoctorAppointmentsScreen();
              break;
            case DoctorDashboardController.chatTabIndex:
              currentScreen = const DoctorChatScreen();
              break;
            case DoctorDashboardController.profileTabIndex:
              currentScreen = const DoctorProfileScreen();
              break;
            case DoctorDashboardController.homeTabIndex:
            default:
              currentScreen = const DoctorHomeScreen();
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
                child: GetBuilder<DoctorDashboardController>(
                  id: DoctorDashboardController.bottomNavId,
                  builder: (controller) {
                    return AppBottomNavBar(
                      currentIndex: controller.currentTabIndex,
                      items: DoctorDashboardController.bottomNavItems,
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
