import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Dialog shown when service is not available in user's city
class ServiceUnavailableDialog extends StatelessWidget {
  const ServiceUnavailableDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xFF101A22).withOpacity(0.7),
      builder: (context) => const ServiceUnavailableDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing6),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2228) : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppConstants.spacing6),
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
              ),
              child: Icon(
                Icons.location_off,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppConstants.spacing5),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing6,
              ),
              child: Text(
                'Service Unavailable',
                style: TextStyle(
                  fontSize: AppConstants.h3Size,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppConstants.spacing3),
            // Message
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing6,
              ),
              child: Text(
                'Shiv Physiotherapy services currently not available in your current city. We will be available soon, thanks for connecting us.',
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  fontWeight: FontWeight.normal,
                  color: isDark ? Colors.grey[400] : const Color(0xFF60778A),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            // Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing6,
              ),
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          fontSize: AppConstants.body2Size,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing6),
          ],
        ),
      ),
    );
  }
}

