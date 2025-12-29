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
          // Notification Button and Profile Avatar
          Row(
            children: [
              // Notification Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    controller.onNotificationTap();
                  },
                  borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: isDark ? Colors.white : const Color(0xFF111518),
                          size: AppConstants.iconSizeMedium,
                        ),
                      ),
                      // Notification Badge
                      if (controller.hasNotifications)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red.shade500,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacing3),
              // Profile Avatar
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
            GetBuilder<DoctorHomeController>(
              id: DoctorHomeController.pendingRequestsId,
              builder: (controller) {
                final request = controller.pendingRequests.first;
                return Column(
                  children: [
                    AppPendingRequestCard(
                      patientName: request['patientName'] as String,
                      treatmentType: request['treatmentType'] as String,
                      dateTime: request['dateTime'] as String,
                      patientAvatarUrl: request['avatarUrl'] as String?,
                      isNew: request['isNew'] as bool? ?? false,
                      isApproving: controller.isApproving,
                      isDeclining: controller.isDeclining,
                      onApprove: () => controller.onApproveRequest(request),
                      onDecline: () => controller.onDeclineRequest(request),
                    ),
                    // Decline Dialog
                    if (controller.showDeclineDialog)
                      _buildDeclineDialog(context, controller, request, isDark),
                  ],
                );
              },
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

  Widget _buildDeclineDialog(
    BuildContext context,
    DoctorHomeController controller,
    Map<String, dynamic> request,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: AppConstants.spacing4),
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.red.shade900.withOpacity(0.1)
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark ? Colors.red.shade800 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                size: AppConstants.iconSizeMedium,
                color: isDark ? Colors.red.shade300 : Colors.red.shade800,
              ),
              const SizedBox(width: AppConstants.spacing2),
              Text(
                'Decline Appointment',
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.red.shade300 : Colors.red.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing3),
          Text(
            'Reason for declining',
            style: TextStyle(
              fontSize: AppConstants.captionSize,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.red.shade400 : Colors.red.shade700,
            ),
          ),
          const SizedBox(height: AppConstants.spacing2),
          TextField(
            onChanged: controller.onDeclineReasonChanged,
            maxLines: 2,
            style: TextStyle(
              fontSize: AppConstants.body2Size,
              color: isDark ? Colors.white : const Color(0xFF111518),
            ),
            decoration: InputDecoration(
              hintText: 'E.g., Schedule conflict, out of office...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF111518) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                borderSide: BorderSide(
                  color: isDark ? Colors.red.shade800 : Colors.red.shade200,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                borderSide: BorderSide(
                  color: isDark ? Colors.red.shade800 : Colors.red.shade200,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                borderSide: BorderSide(
                  color: Colors.red.shade500,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing3),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    controller.onCancelDecline();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: AppConstants.body2Size,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Material(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  child: InkWell(
                    onTap: controller.isDeclining
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            controller.onConfirmDecline(request);
                          },
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacing2,
                      ),
                      alignment: Alignment.center,
                      child: controller.isDeclining
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Confirm Decline',
                              style: TextStyle(
                                fontSize: AppConstants.body2Size,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
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
              title: 'No Schedule',
              message: 'You have no appointments scheduled for today',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: AppConstants.h4Size,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111518),
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          GridView.count(
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
        ],
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
            'Analytics',
            style: TextStyle(
              fontSize: AppConstants.h4Size,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111518),
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          if (controller.hasAnalytics)
            GetBuilder<DoctorHomeController>(
              id: DoctorHomeController.analyticsId,
              builder: (controller) {
                return SingleChildScrollView(
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
                );
              },
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
      padding: const EdgeInsets.all(AppConstants.spacing8),
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
          const SizedBox(height: AppConstants.spacing4),
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstants.h4Size,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111518),
            ),
          ),
          const SizedBox(height: AppConstants.spacing2),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppConstants.body2Size,
              color: isDark
                  ? Colors.grey.shade400
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
