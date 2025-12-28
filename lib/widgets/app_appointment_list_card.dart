import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Appointment status enum
enum AppointmentStatus { confirmed, pending, completed, cancelled }

/// Appointment type enum
enum AppointmentType { online, clinic }

/// Reusable appointment list card for appointments screen
class AppAppointmentListCard extends StatelessWidget {
  final String doctorName;
  final String specialization;
  final String month;
  final int day;
  final String time;
  final AppointmentStatus status;
  final AppointmentType type;
  final String? location; // For clinic appointments
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
  final VoidCallback? onViewPrescription;
  final VoidCallback? onViewTreatmentPlan;
  final VoidCallback? onTap;

  const AppAppointmentListCard({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.month,
    required this.day,
    required this.time,
    required this.status,
    required this.type,
    this.location,
    this.onReschedule,
    this.onCancel,
    this.onViewPrescription,
    this.onViewTreatmentPlan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacing4),
        padding: const EdgeInsets.all(AppConstants.spacing4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date box, Doctor info, Status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Box
                _buildDateBox(context, isDark),
                const SizedBox(width: AppConstants.spacing3),
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: TextStyle(
                          fontSize: AppConstants.body1Size,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111518),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing1),
                      Text(
                        specialization,
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
                // Status Badge
                _buildStatusBadge(context, isDark),
              ],
            ),
            const SizedBox(height: AppConstants.spacing4),
            // Time & Location Details
            Padding(
              padding: const EdgeInsets.only(
                left: 64.0,
              ), // Align with doctor info
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time slot
                  _buildDetailItem(context, Icons.schedule, time, isDark),
                  // Location/Address below time
                  if (type == AppointmentType.clinic && location != null && location!.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spacing2),
                    _buildAddressItem(context, location!, isDark),
                  ] else if (type == AppointmentType.online) ...[
                    const SizedBox(height: AppConstants.spacing2),
                    _buildDetailItem(
                      context,
                      Icons.videocam,
                      'Online Call',
                      isDark,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing4),
            // Actions
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: _buildActions(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox(BuildContext context, bool isDark) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case AppointmentStatus.confirmed:
        bgColor = isDark
            ? AppColors.primary.withOpacity(0.2)
            : AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        break;
      case AppointmentStatus.pending:
        bgColor = isDark
            ? Colors.orange.withOpacity(0.2)
            : Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        break;
      case AppointmentStatus.completed:
      case AppointmentStatus.cancelled:
        bgColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
        textColor = isDark ? Colors.grey.shade300 : Colors.grey.shade600;
        break;
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            month.toUpperCase(),
            style: TextStyle(
              fontSize: AppConstants.captionSize,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            day.toString(),
            style: TextStyle(
              fontSize: AppConstants.h3Size,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isDark) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status) {
      case AppointmentStatus.confirmed:
        bgColor = isDark
            ? Colors.green.withOpacity(0.3)
            : Colors.green.shade100;
        textColor = isDark ? Colors.green.shade400 : Colors.green.shade700;
        icon = Icons.check_circle;
        label = 'Confirmed';
        break;
      case AppointmentStatus.pending:
        bgColor = isDark
            ? Colors.amber.withOpacity(0.3)
            : Colors.amber.shade100;
        textColor = isDark ? Colors.amber.shade400 : Colors.amber.shade700;
        icon = Icons.schedule;
        label = 'Pending';
        break;
      case AppointmentStatus.completed:
        bgColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
        textColor = isDark ? Colors.grey.shade300 : Colors.grey.shade600;
        icon = Icons.check;
        label = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        bgColor = isDark ? Colors.red.withOpacity(0.3) : Colors.red.shade100;
        textColor = isDark ? Colors.red.shade400 : Colors.red.shade700;
        icon = Icons.cancel;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing3,
        vertical: AppConstants.spacing1,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: AppConstants.spacing1),
          Text(
            label,
            style: TextStyle(
              fontSize: AppConstants.captionSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String text,
    bool isDark,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppConstants.iconSizeMedium,
          color: isDark ? Colors.grey.shade400 : AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: AppConstants.spacing2),
        Text(
          text,
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            color: isDark ? Colors.grey.shade300 : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressItem(
    BuildContext context,
    String address,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.location_on,
          size: AppConstants.iconSizeMedium,
          color: isDark ? Colors.grey.shade400 : AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: AppConstants.spacing2),
        Expanded(
          child: Text(
            address,
            style: TextStyle(
              fontSize: AppConstants.body2Size,
              color: isDark ? Colors.grey.shade300 : AppColors.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Reschedule',
                isDark,
                onPressed: onReschedule,
                isOutlined: true,
              ),
            ),
            const SizedBox(width: AppConstants.spacing3),
            _buildIconButton(
              context,
              Icons.close,
              Colors.red,
              isDark,
              onPressed: onCancel,
            ),
          ],
        );
      case AppointmentStatus.pending:
        return _buildActionButton(
          context,
          'Awaiting Confirmation',
          isDark,
          onPressed: null, // Disabled
          isDisabled: true,
        );
      case AppointmentStatus.completed:
        return Column(
          children: [
            _buildActionButton(
              context,
              'View Prescription',
              isDark,
              onPressed: onViewPrescription,
              isPrimary: true,
              icon: Icons.description,
            ),
            const SizedBox(height: AppConstants.spacing2),
            _buildActionButton(
              context,
              'View Treatment Plan',
              isDark,
              onPressed: onViewTreatmentPlan,
              isOutlined: true,
            ),
          ],
        );
      case AppointmentStatus.cancelled:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    bool isDark, {
    VoidCallback? onPressed,
    bool isPrimary = false,
    bool isOutlined = false,
    bool isDisabled = false,
    IconData? icon,
  }) {
    final bgColor = isPrimary
        ? AppColors.primary.withOpacity(0.1)
        : (isDisabled
              ? (isDark ? Colors.grey.shade700 : Colors.grey.shade100)
              : Colors.transparent);
    final textColor = isPrimary
        ? AppColors.primary
        : (isDisabled
              ? (isDark ? Colors.grey.shade500 : Colors.grey.shade400)
              : (isDark ? Colors.grey.shade200 : AppColors.onSurfaceVariant));
    final borderColor = isOutlined
        ? (isDark ? Colors.grey.shade600 : Colors.grey.shade200)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed?.call();
              },
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing4,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppConstants.iconSizeMedium, color: textColor),
                const SizedBox(width: AppConstants.spacing2),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    Color color,
    bool isDark, {
    VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade200,
            ),
          ),
          child: Icon(icon, size: AppConstants.iconSizeMedium, color: color),
        ),
      ),
    );
  }
}
