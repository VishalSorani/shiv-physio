import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Schedule timeline item for doctor dashboard
class AppScheduleTimelineItem extends StatelessWidget {
  final String time;
  final String? patientInitials;
  final String? patientName;
  final String? treatmentType;
  final bool isActive; // Current/upcoming appointment
  final bool isBreak; // Break/lunch time
  final String? breakLabel;
  final bool isOnline;
  final VoidCallback? onTap;

  const AppScheduleTimelineItem({
    super.key,
    required this.time,
    this.patientInitials,
    this.patientName,
    this.treatmentType,
    this.isActive = false,
    this.isBreak = false,
    this.breakLabel,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column
          SizedBox(
            width: 48,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: AppConstants.captionSize,
                    fontWeight: isBreak
                        ? FontWeight.w500
                        : FontWeight.bold,
                    color: isBreak
                        ? (isDark ? Colors.grey.shade500 : Colors.grey.shade400)
                        : (isDark ? Colors.white : const Color(0xFF111518)),
                  ),
                ),
                if (!isBreak) ...[
                  const SizedBox(height: AppConstants.spacing2),
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacing3),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacing6),
              child: isBreak
                  ? _buildBreakCard(context, isDark)
                  : _buildAppointmentCard(context, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakCard(BuildContext context, bool isDark) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Center(
        child: Text(
          breakLabel ?? 'Break',
          style: TextStyle(
            fontSize: AppConstants.captionSize,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, bool isDark) {
    final bgColor = isActive
        ? AppColors.primary
        : (isDark ? AppColors.surfaceDark : Colors.white);
    final textColor = isActive
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF111518));
    final secondaryTextColor = isActive
        ? Colors.white.withOpacity(0.8)
        : (isDark ? Colors.grey.shade400 : AppColors.onSurfaceVariant);
    final avatarBgColor = isActive
        ? Colors.white.withOpacity(0.2)
        : (isDark
            ? Colors.orange.withOpacity(0.3)
            : Colors.orange.withOpacity(0.1));
    final avatarTextColor = isActive
        ? Colors.white
        : (isDark ? Colors.orange.shade400 : Colors.orange.shade700);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacing4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: isActive
                  ? Colors.transparent
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: avatarBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        patientInitials ?? '??',
                        style: TextStyle(
                          fontSize: AppConstants.body2Size,
                          fontWeight: FontWeight.bold,
                          color: avatarTextColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing3),
                  // Patient Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        patientName ?? 'Unknown',
                        style: TextStyle(
                          fontSize: AppConstants.body2Size,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        treatmentType ?? '',
                        style: TextStyle(
                          fontSize: AppConstants.captionSize,
                          fontWeight: FontWeight.w500,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Online indicator or chevron
              if (isOnline && isActive)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.videocam,
                    size: AppConstants.iconSizeSmall,
                    color: Colors.white,
                  ),
                )
              else if (!isActive)
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

