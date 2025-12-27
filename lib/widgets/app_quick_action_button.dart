import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Reusable quick action button for dashboard grid
class AppQuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const AppQuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        backgroundColor ?? (isDark ? AppColors.surfaceDark : Colors.white);
    final iconBgColor = iconColor ?? AppColors.primary;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

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
          curve: Curves.easeInOut,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing3),
                decoration: BoxDecoration(
                  color: isDark
                      ? iconBgColor.withOpacity(0.3)
                      : iconBgColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconBgColor, size: 24),
              ),
              const SizedBox(height: AppConstants.spacing3),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.grey.shade200
                      : const Color(0xFF111518),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
