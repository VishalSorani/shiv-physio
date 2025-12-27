import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../widgets/app_analytics_card.dart';
import '../../../widgets/app_pending_request_card.dart';
import '../../../widgets/app_schedule_timeline_item.dart';
import 'home_controller.dart';

class DoctorHomeScreen extends BaseScreenView<DoctorHomeController> {
  const DoctorHomeScreen({super.key});

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
        child: GetBuilder<DoctorHomeController>(
          id: DoctorHomeController.contentId,
          builder: (controller) {
            if (controller.isLoading && !controller.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: AppConstants.spacing4),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: AppConstants.body2Size,
                          color: isDark
                              ? Colors.grey.shade400
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.refreshHomeData(),
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: _buildHeader(context, controller, isDark),
                  ),
                  // Main Content
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppConstants.spacing6),
                        // Pending Requests
                        _buildPendingRequests(context, controller, isDark),
                        const SizedBox(height: AppConstants.spacing6),
                        // Today's Schedule
                        _buildTodaysSchedule(context, controller, isDark),
                        const SizedBox(height: AppConstants.spacing6),
                        // Quick Actions
                        _buildQuickActions(context, controller, isDark),
                        const SizedBox(height: AppConstants.spacing6),
                        // Analytics
                        _buildAnalytics(context, controller, isDark),
                        // Bottom spacing for nav bar
                        const SizedBox(height: AppConstants.radiusCircular),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    DoctorHomeController controller,
    bool isDark,
  ) {
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.currentDate,
                  style: TextStyle(
                    fontSize: AppConstants.body2Size,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.grey.shade400
                        : AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing1),
                Text(
                  controller.greeting,
                  style: TextStyle(
                    fontSize: AppConstants.h2Size,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF111518),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // Profile Avatar with Notification Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      controller.avatarUrl != null &&
                          controller.avatarUrl!.isNotEmpty
                      ? Image.network(
                          controller.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultAvatar(isDark),
                        )
                      : _buildDefaultAvatar(isDark),
                ),
              ),
              // Notification Badge
              if (controller.hasNotifications)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      shape: BoxShape.circle,
                      border: Border.all(color: bgColor, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(bool isDark) {
    return Container(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      child: Icon(
        Icons.person,
        color: isDark ? Colors.grey.shade400 : AppColors.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPendingRequests(
    BuildContext context,
    DoctorHomeController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Requests',
                style: TextStyle(
                  fontSize: AppConstants.h4Size,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111518),
                ),
              ),
              if (controller.hasPendingRequests)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      controller.onViewAllRequestsTap();
                    },
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusSmall,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing2,
                        vertical: AppConstants.spacing1,
                      ),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontSize: AppConstants.body2Size,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing3),
          if (controller.hasPendingRequests)
            AppPendingRequestCard(
              patientName:
                  controller.pendingRequests.first['patientName'] as String,
              treatmentType:
                  controller.pendingRequests.first['treatmentType'] as String,
              dateTime: controller.pendingRequests.first['dateTime'] as String,
              patientAvatarUrl:
                  controller.pendingRequests.first['avatarUrl'] as String?,
              isNew:
                  controller.pendingRequests.first['isNew'] as bool? ?? false,
              onApprove: () =>
                  controller.onApproveRequest(controller.pendingRequests.first),
              onDecline: () =>
                  controller.onDeclineRequest(controller.pendingRequests.first),
            )
          else
            _buildEmptyState(
              context,
              isDark,
              icon: Icons.pending_actions_outlined,
              title: 'No Pending Requests',
              message: 'All appointment requests have been reviewed',
            ),
        ],
      ),
    );
  }

  Widget _buildTodaysSchedule(
    BuildContext context,
    DoctorHomeController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Schedule",
            style: TextStyle(
              fontSize: AppConstants.h4Size,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111518),
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          if (controller.hasTodaysSchedule)
            ...controller.scheduleItems.map((item) {
              return AppScheduleTimelineItem(
                time: item['time'] as String,
                patientInitials: item['patientInitials'] as String?,
                patientName: item['patientName'] as String?,
                treatmentType: item['treatmentType'] as String?,
                isActive: item['isActive'] as bool? ?? false,
                isBreak: item['isBreak'] as bool? ?? false,
                breakLabel: item['breakLabel'] as String?,
                isOnline: item['isOnline'] as bool? ?? false,
                onTap: () => controller.onScheduleItemTap(item),
              );
            })
          else
            _buildEmptyState(
              context,
              isDark,
              icon: Icons.calendar_today_outlined,
              title: 'No Appointments Today',
              message: 'You have no scheduled appointments for today',
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    DoctorHomeController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing5),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppConstants.spacing4,
        crossAxisSpacing: AppConstants.spacing4,
        childAspectRatio: 1.2,
        children: controller.quickActions.map((action) {
          return _buildQuickActionCard(
            context,
            action['icon'] as IconData,
            action['label'] as String,
            action['color'] as Color,
            isDark,
            () => controller.onQuickActionTap(action),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    bool isDark,
    VoidCallback onTap,
  ) {
    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.transparent;
    final iconBgColor = isDark
        ? color.withOpacity(0.2)
        : color.withOpacity(0.1);
    final iconColor = isDark ? color.withOpacity(0.8) : color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacing4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing2),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: AppConstants.iconSizeLarge,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111518),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalytics(
    BuildContext context,
    DoctorHomeController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "This Month's Insights",
            style: TextStyle(
              fontSize: AppConstants.h4Size,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111518),
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          if (controller.hasAnalytics && controller.analytics.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.analytics.map((analytics) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      right: AppConstants.spacing4,
                    ),
                    child: AppAnalyticsCard(
                      label: analytics['label'] as String,
                      value: analytics['value'] as String,
                      secondaryValue: analytics['secondaryValue'] as String?,
                      trend: analytics['trend'] as String?,
                      isPositiveTrend:
                          analytics['isPositiveTrend'] as bool? ?? true,
                      valueColor: analytics['valueColor'] as Color?,
                    ),
                  );
                }).toList(),
              ),
            )
          else
            _buildEmptyState(
              context,
              isDark,
              icon: Icons.analytics_outlined,
              title: 'No Analytics Data',
              message: 'Analytics will appear here once you have appointments',
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: AppConstants.spacing3),
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstants.body1Size,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppConstants.spacing2),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppConstants.body2Size,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
