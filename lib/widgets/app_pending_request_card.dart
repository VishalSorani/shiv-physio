import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Reusable pending request card for doctor dashboard
class AppPendingRequestCard extends StatelessWidget {
  final String patientName;
  final String treatmentType;
  final String dateTime;
  final String? patientAvatarUrl;
  final bool isNew;
  final bool isApproving;
  final bool isDeclining;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;

  const AppPendingRequestCard({
    super.key,
    required this.patientName,
    required this.treatmentType,
    required this.dateTime,
    this.patientAvatarUrl,
    this.isNew = false,
    this.isApproving = false,
    this.isDeclining = false,
    this.onApprove,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.transparent;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  image:
                      patientAvatarUrl != null && patientAvatarUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(patientAvatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: patientAvatarUrl == null || patientAvatarUrl!.isEmpty
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
                          child: Text(
                            patientName,
                            style: TextStyle(
                              fontSize: AppConstants.h4Size,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF111518),
                            ),
                          ),
                        ),
                        if (isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacing2,
                              vertical: AppConstants.spacing1 / 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusCircular,
                              ),
                            ),
                            child: Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacing1),
                    Text(
                      treatmentType,
                      style: TextStyle(
                        fontSize: AppConstants.body2Size,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.grey.shade400
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing2),
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          size: AppConstants.iconSizeSmall,
                          color: isDark
                              ? Colors.grey.shade400
                              : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppConstants.spacing2),
                        Text(
                          dateTime,
                          style: TextStyle(
                            fontSize: AppConstants.captionSize,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey.shade400
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing4),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Decline',
                  Icons.close,
                  isDark,
                  onPressed: onDecline,
                  isOutlined: true,
                  isLoading: isDeclining,
                ),
              ),
              const SizedBox(width: AppConstants.spacing3),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Approve',
                  Icons.check,
                  isDark,
                  onPressed: onApprove,
                  isPrimary: true,
                  isLoading: isApproving,
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
    bool isLoading = false,
  }) {
    final bgColor = isPrimary ? AppColors.primary : Colors.transparent;
    final textColor = isPrimary
        ? Colors.white
        : (isDark ? Colors.grey.shade300 : AppColors.onSurfaceVariant);
    final borderColor = isOutlined
        ? (isDark ? Colors.grey.shade700 : Colors.grey.shade100)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed?.call();
              },
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isLoading ? bgColor.withOpacity(0.7) : bgColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isPrimary && !isLoading
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: isLoading
                ? [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    ),
                  ]
                : [
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
