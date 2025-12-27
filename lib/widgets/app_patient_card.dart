import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../data/models/patient_display.dart';

/// Reusable patient card for patient management screen
class AppPatientCard extends StatelessWidget {
  final PatientDisplay patient;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const AppPatientCard({
    super.key,
    required this.patient,
    this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: AnimatedContainer(
          duration: AppConstants.shortAnimation,
          padding: const EdgeInsets.all(AppConstants.spacing4),
          decoration: BoxDecoration(
            color: bgColor,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient info row
              Row(
                children: [
                  // Avatar
                  _buildAvatar(isDark),
                  const SizedBox(width: AppConstants.spacing3),
                  // Patient details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.patient.fullName ?? 'Unknown Patient',
                          style: TextStyle(
                            fontSize: AppConstants.body1Size,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF111518),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing1),
                        Row(
                          children: [
                            Text(
                              patient.formattedId,
                              style: TextStyle(
                                fontSize: AppConstants.captionSize,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : const Color(0xFF60778A),
                              ),
                            ),
                            if (patient.ageString != null) ...[
                              Text(
                                ' • ${patient.ageString}',
                                style: TextStyle(
                                  fontSize: AppConstants.captionSize,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : const Color(0xFF60778A),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (patient.condition != null) ...[
                          const SizedBox(height: AppConstants.spacing2),
                          _buildConditionChip(patient.condition!, isDark),
                        ],
                      ],
                    ),
                  ),
                  // More button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onMoreTap?.call();
                      },
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusCircular,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacing2),
                        child: Icon(
                          Icons.more_vert,
                          size: AppConstants.iconSizeMedium,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Bottom info row
              if (patient.nextAppointment != null ||
                  patient.lastAppointment != null ||
                  patient.progressPercentage != null) ...[
                const SizedBox(height: AppConstants.spacing4),
                Divider(
                  height: 1,
                  color: borderColor,
                ),
                const SizedBox(height: AppConstants.spacing3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Next appointment or last visit
                    if (patient.nextAppointment != null)
                      _buildInfoItem(
                        Icons.calendar_month,
                        'Next: ${patient.nextAppointmentString}',
                        isDark,
                      )
                    else if (patient.lastAppointment != null)
                      _buildInfoItem(
                        Icons.history,
                        'Last Visit: ${patient.lastVisitString}',
                        isDark,
                      )
                    else if (patient.status == 'pending_review')
                      _buildInfoItem(
                        Icons.pending_actions,
                        'Pending Review',
                        isDark,
                        color: Colors.orange,
                      ),
                    // Progress or action button
                    if (patient.progressPercentage != null &&
                        patient.status != 'pending_review')
                      _buildProgressIndicator(
                        patient.progressPercentage!,
                        isDark,
                      )
                    else if (patient.status == 'pending_review')
                      _buildUpdatePlanButton(isDark),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    final hasAvatar = patient.patient.avatarUrl != null &&
        patient.patient.avatarUrl!.isNotEmpty;
    final statusColor = _getStatusColor();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasAvatar ? Colors.transparent : _getAvatarColor(),
            border: hasAvatar
                ? null
                : Border.all(
                    color: _getAvatarBorderColor(),
                    width: 1,
                  ),
          ),
          child: hasAvatar
              ? ClipOval(
                  child: Image.network(
                    patient.patient.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildInitialsAvatar();
                    },
                  ),
                )
              : _buildInitialsAvatar(),
        ),
        if (statusColor != null)
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  width: 2,
                ),
              ),
              child: Icon(
                _getStatusIcon(),
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        patient.initials,
        style: TextStyle(
          fontSize: AppConstants.body1Size,
          fontWeight: FontWeight.bold,
          color: _getAvatarTextColor(),
        ),
      ),
    );
  }

  Color _getAvatarColor() {
    final hash = patient.patient.id.hashCode;
    final colors = [
      Colors.purple.shade100,
      Colors.teal.shade100,
      Colors.blue.shade100,
      Colors.orange.shade100,
    ];
    return colors[hash.abs() % colors.length];
  }

  Color _getAvatarBorderColor() {
    final hash = patient.patient.id.hashCode;
    final colors = [
      Colors.purple.shade200,
      Colors.teal.shade200,
      Colors.blue.shade200,
      Colors.orange.shade200,
    ];
    return colors[hash.abs() % colors.length];
  }

  Color _getAvatarTextColor() {
    final hash = patient.patient.id.hashCode;
    final colors = [
      Colors.purple.shade600,
      Colors.teal.shade600,
      Colors.blue.shade600,
      Colors.orange.shade600,
    ];
    return colors[hash.abs() % colors.length];
  }

  Color? _getStatusColor() {
    switch (patient.statusBadgeColor) {
      case 'green':
        return Colors.green.shade500;
      case 'yellow':
        return Colors.yellow.shade500;
      case 'blue':
        return Colors.blue.shade500;
      default:
        return null;
    }
  }

  IconData _getStatusIcon() {
    switch (patient.statusBadgeColor) {
      case 'green':
        return Icons.check;
      case 'yellow':
        return Icons.priority_high;
      case 'blue':
        return Icons.check_circle;
      default:
        return Icons.circle;
    }
  }

  Widget _buildConditionChip(String condition, bool isDark) {
    Color bgColor;
    Color textColor;

    // Determine colors based on condition
    final lowerCondition = condition.toLowerCase();
    if (lowerCondition.contains('acl') || lowerCondition.contains('post-op')) {
      bgColor = isDark
          ? Colors.blue.shade900.withOpacity(0.3)
          : Colors.blue.shade100;
      textColor = isDark ? Colors.blue.shade300 : Colors.blue.shade600;
    } else if (lowerCondition.contains('frozen') ||
        lowerCondition.contains('shoulder')) {
      bgColor = isDark
          ? Colors.orange.shade900.withOpacity(0.3)
          : Colors.orange.shade100;
      textColor = isDark ? Colors.orange.shade300 : Colors.orange.shade600;
    } else {
      bgColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
      textColor = isDark ? Colors.grey.shade300 : Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing2,
        vertical: AppConstants.spacing1 / 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Text(
        condition,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, bool isDark, {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? (isDark ? Colors.grey.shade300 : Colors.grey.shade600),
        ),
        const SizedBox(width: AppConstants.spacing1),
        Text(
          text,
          style: TextStyle(
            fontSize: AppConstants.captionSize,
            color: color ??
                (isDark ? Colors.grey.shade300 : Colors.grey.shade600),
            fontWeight: color != null ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(int percentage, bool isDark) {
    final isHighProgress = percentage >= 70;
    final color = isHighProgress ? Colors.green : Colors.grey;

    return Row(
      children: [
        Icon(
          isHighProgress ? Icons.trending_up : Icons.trending_flat,
          size: 16,
          color: isDark ? color.shade400 : color.shade600,
        ),
        const SizedBox(width: AppConstants.spacing1),
        Text(
          '$percentage% Progress',
          style: TextStyle(
            fontSize: AppConstants.captionSize,
            fontWeight: FontWeight.w500,
            color: isDark ? color.shade400 : color.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildUpdatePlanButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // TODO: Handle update plan
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing3,
            vertical: AppConstants.spacing1,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
          ),
          child: Text(
            'Update Plan',
            style: TextStyle(
              fontSize: AppConstants.captionSize,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

