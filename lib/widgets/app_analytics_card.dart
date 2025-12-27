import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Analytics card for doctor dashboard
class AppAnalyticsCard extends StatelessWidget {
  final String label;
  final String value;
  final String? secondaryValue;
  final String? trend; // e.g., "+5%"
  final bool isPositiveTrend;
  final Color? valueColor;

  const AppAnalyticsCard({
    super.key,
    required this.label,
    required this.value,
    this.secondaryValue,
    this.trend,
    this.isPositiveTrend = true,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    final labelColor = isDark ? Colors.grey.shade400 : AppColors.onSurfaceVariant;
    final valueTextColor = valueColor ??
        (isDark ? Colors.white : const Color(0xFF111518));

    return Container(
      constraints: const BoxConstraints(minWidth: 140),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: AppConstants.captionSize,
              fontWeight: FontWeight.w600,
              color: labelColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppConstants.spacing2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: AppConstants.h1SizeSmall,
                  fontWeight: FontWeight.bold,
                  color: valueTextColor,
                  height: 1.0,
                ),
              ),
              if (secondaryValue != null) ...[
                const SizedBox(width: AppConstants.spacing2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    secondaryValue!,
                    style: TextStyle(
                      fontSize: AppConstants.captionSize,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
              if (trend != null) ...[
                const SizedBox(width: AppConstants.spacing2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveTrend ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 10,
                        color: isPositiveTrend
                            ? Colors.green.shade500
                            : Colors.red.shade500,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: AppConstants.captionSize,
                          fontWeight: FontWeight.bold,
                          color: isPositiveTrend
                              ? Colors.green.shade500
                              : Colors.red.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

