import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../data/models/notification.dart' as notification_model;
import '../../../widgets/app_custom_app_bar.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends BaseScreenView<NotificationsController> {
  const NotificationsScreen({super.key});

  static const String notificationsScreen = '/notifications';

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppCustomAppBar(
        title: 'Notifications',
        centerTitle: true,
        leading: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacing2),
              child: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : const Color(0xFF111518),
              ),
            ),
          ),
        ),
        action: GetBuilder<NotificationsController>(
          id: NotificationsController.listId,
          builder: (controller) {
            if (controller.unreadCount == 0) {
              return const SizedBox.shrink();
            }
            return TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.markAllAsRead();
              },
              child: Text(
                'Mark all read',
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: GetBuilder<NotificationsController>(
          id: NotificationsController.contentId,
          builder: (controller) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return GetBuilder<NotificationsController>(
              id: NotificationsController.listId,
              builder: (controller) {
                if (controller.isEmpty) {
                  return GetBuilder<NotificationsController>(
                    id: NotificationsController.emptyStateId,
                    builder: (_) => _buildEmptyState(context, isDark),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshNotifications,
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: AppConstants.spacing4,
                      bottom:
                          AppConstants.spacing8 + 64, // Space for bottom nav
                    ),
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = controller.notifications[index];
                      return _buildNotificationItem(
                        context,
                        notification,
                        controller,
                        isDark,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              'No Notifications',
              style: TextStyle(
                fontSize: AppConstants.h3Size,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111518),
              ),
            ),
            const SizedBox(height: AppConstants.spacing2),
            Text(
              'You\'ll see notifications about your appointments here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.body2Size,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    notification_model.Notification notification,
    NotificationsController controller,
    bool isDark,
  ) {
    final surfaceColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    return Container(
      margin: EdgeInsets.only(
        left: AppConstants.spacing4,
        right: AppConstants.spacing4,
        bottom: AppConstants.spacing3,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            controller.onNotificationTap(notification);
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(
                      notification.notificationType,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusCircular,
                    ),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.notificationType),
                    color: _getNotificationColor(notification.notificationType),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing4),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: AppConstants.body1Size,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111518),
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing1),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: AppConstants.body2Size,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.spacing2),
                      Text(
                        _formatDateTime(notification.sentAt),
                        style: TextStyle(
                          fontSize: AppConstants.captionSize,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String notificationType) {
    switch (notificationType) {
      case 'appointment_booked':
        return Icons.calendar_today;
      case 'appointment_approved':
        return Icons.check_circle;
      case 'appointment_cancelled':
        return Icons.cancel;
      case 'appointment_rejected':
        return Icons.close;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String notificationType) {
    switch (notificationType) {
      case 'appointment_booked':
        return Colors.blue;
      case 'appointment_approved':
        return Colors.green;
      case 'appointment_cancelled':
      case 'appointment_rejected':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final localTime = dateTime.toLocal();
    final difference = now.difference(localTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(localTime);
    }
  }
}
