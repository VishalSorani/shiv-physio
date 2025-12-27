import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import 'chat_controller.dart';

class DoctorChatScreen extends BaseScreenView<DoctorChatController> {
  const DoctorChatScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.group,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  'Patients',
                  style: TextStyle(
                    fontSize: AppConstants.h2Size,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF111518),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing2),
                Text(
                  'Your patients will appear here',
                  textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}

