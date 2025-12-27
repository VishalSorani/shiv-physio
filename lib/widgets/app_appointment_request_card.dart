import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../data/models/enums.dart';

/// Reusable appointment request card for doctor appointments screen
class AppAppointmentRequestCard extends StatelessWidget {
  final String patientName;
  final String patientAgeGender; // e.g., "32 years, Male"
  final String? patientAvatarUrl;
  final RequestStatus? status;
  final String date;
  final String time;
  final String reasonForVisit;
  final bool isRejecting; // Shows rejection input area
  final String? rejectionReason;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancelReject;
  final ValueChanged<String>? onRejectionReasonChanged;
  final VoidCallback? onConfirmReject;

  const AppAppointmentRequestCard({
    super.key,
    required this.patientName,
    required this.patientAgeGender,
    this.patientAvatarUrl,
    this.status,
    required this.date,
    required this.time,
    required this.reasonForVisit,
    this.isRejecting = false,
    this.rejectionReason,
    this.onAccept,
    this.onReject,
    this.onCancelReject,
    this.onRejectionReasonChanged,
    this.onConfirmReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A2632) : Colors.white;
    final borderColor = isRejecting
        ? (isDark
            ? Colors.red.shade900.withOpacity(0.3)
            : Colors.red.shade100)
        : (isDark ? Colors.grey.shade800 : Colors.transparent);
    final hasUrgency = status == RequestStatus.urgent;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: borderColor,
          width: isRejecting ? 2 : 1,
        ),
        boxShadow: isRejecting
            ? [
                BoxShadow(
                  color: Colors.red.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Stack(
        children: [
          // Urgency indicator bar
          if (hasUrgency)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusLarge),
                    bottomLeft: Radius.circular(AppConstants.radiusLarge),
                  ),
                ),
              ),
            ),
          // Content
          Padding(
            padding: EdgeInsets.only(
              left: hasUrgency ? AppConstants.spacing2 : 0,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          image: patientAvatarUrl != null &&
                                  patientAvatarUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(patientAvatarUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: patientAvatarUrl == null ||
                                patientAvatarUrl!.isEmpty
                            ? Icon(
                                Icons.person,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : AppColors.onSurfaceVariant,
                              )
                            : null,
                      ),
                      const SizedBox(width: AppConstants.spacing4),
                      // Patient Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        patientName,
                                        style: TextStyle(
                                          fontSize: AppConstants.body1Size,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF111518),
                                        ),
                                      ),
                                      Text(
                                        patientAgeGender,
                                        style: TextStyle(
                                          fontSize: AppConstants.body2Size,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Colors.grey.shade400
                                              : const Color(0xFF60778A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (status != null) _buildStatusBadge(context, isDark),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  // Date & Time
                  Row(
                    children: [
                      _buildDateTimeItem(
                        context,
                        Icons.event,
                        date,
                        isDark,
                      ),
                      const SizedBox(width: AppConstants.spacing4),
                      _buildDateTimeItem(
                        context,
                        Icons.schedule,
                        time,
                        isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  // Divider
                  Divider(
                    color: isDark ? Colors.grey.shade700 : const Color(0xFFF0F2F5),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  // Reason for Visit
                  Text(
                    'REASON FOR VISIT',
                    style: TextStyle(
                      fontSize: AppConstants.captionSize,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.grey.shade500
                          : const Color(0xFF60778A),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing1),
                  Text(
                    reasonForVisit,
                    style: TextStyle(
                      fontSize: AppConstants.body2Size,
                      color: isDark
                          ? Colors.grey.shade300
                          : const Color(0xFF111518),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  // Rejection Input Area (if rejecting)
                  if (isRejecting) ...[
                    _buildRejectionInput(context, isDark),
                    const SizedBox(height: AppConstants.spacing4),
                  ],
                  // Actions
                  if (!isRejecting)
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            'Reject',
                            Icons.close,
                            isDark,
                            onPressed: onReject,
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacing3),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            'Accept',
                            Icons.check,
                            isDark,
                            onPressed: onAccept,
                            isPrimary: true,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isDark) {
    if (status == RequestStatus.urgent) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing2,
          vertical: AppConstants.spacing1,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.red.withOpacity(0.3)
              : Colors.red.shade50,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: Border.all(
            color: isDark
                ? Colors.red.shade700.withOpacity(0.3)
                : Colors.red.shade600.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.priority_high,
              size: 14,
              color: isDark ? Colors.red.shade400 : Colors.red.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              'Urgent',
              style: TextStyle(
                fontSize: AppConstants.captionSize,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.red.shade400 : Colors.red.shade600,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing2,
          vertical: AppConstants.spacing1,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: Border.all(
            color: isDark
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          'New',
          style: TextStyle(
            fontSize: AppConstants.captionSize,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      );
    }
  }

  Widget _buildDateTimeItem(
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
          color: AppColors.primary,
        ),
        const SizedBox(width: AppConstants.spacing2),
        Text(
          text,
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade200 : const Color(0xFF111518),
          ),
        ),
      ],
    );
  }

  Widget _buildRejectionInput(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.red.shade900.withOpacity(0.1)
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
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
                'Reject Appointment',
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
            'Reason for rejection',
            style: TextStyle(
              fontSize: AppConstants.captionSize,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.red.shade400 : Colors.red.shade700,
            ),
          ),
          const SizedBox(height: AppConstants.spacing2),
          TextField(
            onChanged: onRejectionReasonChanged,
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
                    onCancelReject?.call();
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
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onConfirmReject?.call();
                    },
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacing2,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Confirm Reject',
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

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isDark, {
    VoidCallback? onPressed,
    bool isPrimary = false,
    bool isOutlined = false,
  }) {
    final bgColor = isPrimary
        ? AppColors.primary
        : Colors.transparent;
    final textColor = isPrimary
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF111518));
    final borderColor = isOutlined
        ? (isDark ? Colors.grey.shade600 : Colors.grey.shade200)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: borderColor),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppConstants.iconSizeMedium, color: textColor),
              const SizedBox(width: AppConstants.spacing2),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

