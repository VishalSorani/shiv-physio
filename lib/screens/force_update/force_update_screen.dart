import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'force_update_controller.dart';

class ForceUpdateScreen extends StatelessWidget {
  static const String forceUpdateScreen = '/force_update';

  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: GetBuilder<ForceUpdateController>(
          id: ForceUpdateController.contentId,
          builder: (controller) {
            return Column(
              children: [
                // Header spacing
                const SizedBox(height: AppConstants.spacing4),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing6,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppConstants.spacing8),

                        // Icon with pulse animation
                        _buildUpdateIcon(controller, isDark),

                        const SizedBox(height: AppConstants.spacing8),

                        // Text Content
                        _buildTextContent(controller, isDark),

                        const SizedBox(height: AppConstants.spacing8),

                        // Features List
                        _buildFeaturesList(isDark),

                        const SizedBox(height: AppConstants.spacing8),
                      ],
                    ),
                  ),
                ),

                // Footer Action
                _buildFooterAction(controller, isDark),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUpdateIcon(ForceUpdateController controller, bool isDark) {
    return GetBuilder<ForceUpdateController>(
      id: ForceUpdateController.iconId,
      builder: (controller) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse effect
            if (controller.showPulse)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Container(
                    width: 128 + (value * 40),
                    height: 128 + (value * 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2 * (1 - value)),
                        width: 2,
                      ),
                    ),
                  );
                },
                onEnd: () {
                  controller.togglePulse();
                },
              ),

            // Icon container
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
              ),
              child: Icon(
                Icons.system_update,
                color: AppColors.primary,
                size: 64,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextContent(ForceUpdateController controller, bool isDark) {
    return Column(
      children: [
        Text(
          'Time to Update',
          style: TextStyle(
            fontSize: AppConstants.h2Size,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacing3),
        Text(
          'To ensure the best experience and security for your patient data, please update to the latest version.',
          style: TextStyle(
            fontSize: AppConstants.body1Size,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : const Color(0xFF60778A),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacing2),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing3,
            vertical: AppConstants.spacing1,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
          ),
          child: Text(
            'Version ${controller.latestVersion}',
            style: TextStyle(
              fontSize: AppConstants.captionSize,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : const Color(0xFF60778A),
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(bool isDark) {
    final features = [
      'Critical security fixes for data protection',
      'New patient tracking dashboard',
      'Improved appointment scheduling',
    ];

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2630) : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
          width: 1,
        ),
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
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacing3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacing3),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: AppConstants.body2Size,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[200] : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooterAction(ForceUpdateController controller, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacing6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      child: Column(
        children: [
          GetBuilder<ForceUpdateController>(
            id: ForceUpdateController.buttonId,
            builder: (controller) {
              return Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    controller.onUpdateTap();
                  },
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  child: AnimatedContainer(
                    duration: AppConstants.shortAnimation,
                    curve: Curves.easeInOut,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.download,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.spacing2),
                        Text(
                          'Update App Now',
                          style: TextStyle(
                            fontSize: AppConstants.body1Size,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            'Updating is required to continue using the app.',
            style: TextStyle(
              fontSize: AppConstants.captionSize,
              color: isDark ? Colors.grey[500] : const Color(0xFF60778A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

