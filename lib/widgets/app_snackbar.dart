import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shiv_physio_app/core/constants/app_colors.dart';


class AppSnackBar {
  AppSnackBar._();

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    Color textColor = AppColors.background,
    IconData? icon,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
    EdgeInsets margin = const EdgeInsets.all(16),
    double borderRadius = 12,
  }) {
    if (Get.isSnackbarOpen) {
      try {
        Get.closeAllSnackbars();
      } catch (error) {
        // When the previous snackbar is already disposed, GetX can throw.
        debugPrint('Failed to close snackbar: $error');
      }
    }

    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      margin: margin,
      borderRadius: borderRadius,
      snackStyle: SnackStyle.FLOATING,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOut,
      overlayBlur: 0,
      icon: icon != null ? Icon(icon, color: textColor) : null,
      titleText: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
        ),
      ),
    );
  }

  static void success({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.check_circle_rounded,
  }) {
    _show(
      title: title,
      message: message,
      backgroundColor: Colors.green.shade600,
      position: position,
      duration: duration,
      icon: icon,
    );
  }

  static void error({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 4),
    IconData icon = Icons.error_rounded,
  }) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.danger,
      position: position,
      duration: duration,
      icon: icon,
    );
  }

  static void warning({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 4),
    IconData icon = Icons.warning_amber_rounded,
  }) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.warning,
      position: position,
      duration: duration,
      icon: icon,
    );
  }

  static void info({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.info_rounded,
  }) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.info,
      position: position,
      duration: duration,
      icon: icon,
    );
  }
}
