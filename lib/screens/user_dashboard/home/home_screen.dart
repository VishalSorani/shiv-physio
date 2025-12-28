import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../data/models/content_item.dart';
import '../../../widgets/app_appointment_card.dart';
import '../../../widgets/app_carousel_card.dart';
import '../../../widgets/app_doctor_info_card.dart';
import '../../../widgets/app_quick_action_button.dart';
import '../../../widgets/app_recovery_item.dart';
import '../../../widgets/app_user_top_bar.dart';
import 'home_controller.dart';

class HomeScreen extends BaseScreenView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<HomeController>(
          id: HomeController.contentId,
          builder: (controller) {
            return CustomScrollView(
              slivers: [
                // Top App Bar (Sticky)
                SliverToBoxAdapter(
                  child: AppUserTopBar(
                    userName: controller.userName,
                    avatarUrl: controller.avatarUrl,
                    onNotificationTap: controller.onNotificationTap,
                    onProfileTap: controller.onProfileTap,
                  ),
                ),
                // Main Content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppConstants.spacing6),
                      // Upcoming Appointment Card or Doctor Info Card
                      GetBuilder<HomeController>(
                        id: HomeController.appointmentId,
                        builder: (controller) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacing4,
                            ),
                            child: controller.hasUpcomingAppointment
                                ? AppAppointmentCard(
                                    title: controller.upcomingAppointmentTitle,
                                    doctorName: controller.upcomingDoctorName,
                                    doctorSpecialization:
                                        controller.upcomingDoctorSpecialization,
                                    doctorAvatarUrl: controller.upcomingDoctorAvatarUrl,
                                    time: controller.upcomingTime,
                                    date: controller.upcomingDate,
                                    onReschedule: controller.onRescheduleTap,
                                    onTap: controller.onAppointmentTap,
                                  )
                                : AppDoctorInfoCard(
                                    doctorName: controller.upcomingDoctorName,
                                    doctorSpecialization:
                                        controller.upcomingDoctorSpecialization,
                                    doctorTitle: controller.doctorTitle,
                                    doctorAvatarUrl: controller.upcomingDoctorAvatarUrl,
                                    clinicName: controller.clinicName,
                                    clinicAddress: controller.clinicAddress,
                                    onTap: controller.onAppointmentTap,
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: AppConstants.spacing6),
                      // Quick Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: AppConstants.h4Size,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111518),
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacing4),
                            Row(
                              children: [
                                Expanded(
                                  child: AppQuickActionButton(
                                    icon: Icons.calendar_today,
                                    label: 'Book',
                                    onTap: controller.onBookTap,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.spacing3),
                                Expanded(
                                  child: AppQuickActionButton(
                                    icon: Icons.history,
                                    label: 'History',
                                    onTap: controller.onHistoryTap,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.spacing3),
                                Expanded(
                                  child: AppQuickActionButton(
                                    icon: Icons.chat_bubble_outline,
                                    label: 'Chat',
                                    onTap: controller.onChatTap,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing6),
                      // Clinic Content Carousel
                      GetBuilder<HomeController>(
                        id: HomeController.highlightsId,
                        builder: (controller) {
                          if (controller.contentItems.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spacing5,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Clinic Content',
                                      style: TextStyle(
                                        fontSize: AppConstants.h4Size,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF111518),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: controller.onSeeAllHighlightsTap,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'See All',
                                        style: TextStyle(
                                          fontSize: AppConstants.body2Size,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacing4),
                              SizedBox(
                                // Height calculated: 280 (card width) * 9/16 (aspect ratio) = 157.5, rounded to 180 for padding
                                height: 180,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.spacing5,
                                  ),
                                  itemCount: controller.contentItems.length,
                                  itemBuilder: (context, index) {
                                    final content = controller.contentItems[index];
                                    final imageUrl = controller.getContentImageUrl(content);
                                    return AppCarouselCard(
                                      imageUrl: imageUrl ?? '',
                                      title: content.title,
                                      badge: controller.getContentBadge(content),
                                      badgeColor: controller.getContentBadgeColor(content),
                                      hasPlayButton: content.type == ContentType.video,
                                      onTap: () => controller.onHighlightTap(index),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppConstants.spacing6),
                      // Your Recovery Section
                      GetBuilder<HomeController>(
                        id: HomeController.recoveryId,
                        builder: (controller) {
                          if (controller.recoveryItems.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacing4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Recovery',
                                  style: TextStyle(
                                    fontSize: AppConstants.h4Size,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF111518),
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                Column(
                                  children: controller.recoveryItems
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                        final index = entry.key;
                                        final item = entry.value;
                                        final imageUrl = controller.getContentImageUrl(item);
                                        final duration = controller.getDuration(item) ?? '5 min';
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom:
                                                index <
                                                        controller
                                                                .recoveryItems
                                                                .length -
                                                            1
                                                    ? AppConstants.spacing3
                                                    : 0,
                                          ),
                                          child: AppRecoveryItem(
                                            imageUrl: imageUrl ?? '',
                                            title: item.title,
                                            type: item.type == ContentType.video
                                                ? 'Video'
                                                : 'Article',
                                            duration: duration,
                                            hasPlayButton: item.type == ContentType.video,
                                            onTap: () =>
                                                controller.onRecoveryItemTap(index),
                                          ),
                                        );
                                      })
                                      .toList(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Bottom spacing for nav bar
                      const SizedBox(height: AppConstants.spacing8),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
