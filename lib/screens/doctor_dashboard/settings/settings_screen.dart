import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../widgets/app_custom_app_bar.dart';
import 'settings_controller.dart';

class DoctorSettingsScreen extends BaseScreenView<DoctorSettingsController> {
  const DoctorSettingsScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppCustomAppBar(title: 'Settings', centerTitle: true),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Content
            Expanded(
              child: GetBuilder<DoctorSettingsController>(
                id: DoctorSettingsController.settingsId,
                builder: (controller) => SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: AppConstants.spacing4,
                    bottom: AppConstants.spacing8 + 64, // Space for bottom nav
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notifications Section
                      _buildSectionHeader(context, 'Notifications', isDark),
                      _buildNotificationSettings(context, controller, isDark),
                      const SizedBox(height: AppConstants.spacing6),
                      // Preferences Section
                      _buildSectionHeader(context, 'Preferences', isDark),
                      _buildPreferencesSettings(context, controller, isDark),
                      const SizedBox(height: AppConstants.spacing6),
                      // Account Section
                      _buildSectionHeader(context, 'Account', isDark),
                      _buildAccountSettings(context, controller, isDark),
                      const SizedBox(height: AppConstants.spacing6),
                      // Support Section
                      _buildSectionHeader(context, 'Support', isDark),
                      _buildSupportSettings(context, controller, isDark),
                      const SizedBox(height: AppConstants.spacing6),
                      // Logout Section
                      _buildLogoutButton(context, controller, isDark),
                      const SizedBox(height: AppConstants.spacing4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing4,
        vertical: AppConstants.spacing2,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppConstants.body2Size,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(
    BuildContext context,
    DoctorSettingsController controller,
    bool isDark,
  ) {
    final surfaceColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive notifications about appointments and messages',
            trailing: Switch(
              value: controller.notificationsEnabled,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                controller.toggleNotifications(value);
              },
              activeColor: AppColors.primary,
            ),
            isDark: isDark,
            showDivider: true,
          ),
          _buildSettingItem(
            context,
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            subtitle: 'Receive email updates about your practice',
            trailing: Switch(
              value: controller.emailNotificationsEnabled,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                controller.toggleEmailNotifications(value);
              },
              activeColor: AppColors.primary,
            ),
            isDark: isDark,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSettings(
    BuildContext context,
    DoctorSettingsController controller,
    bool isDark,
  ) {
    final surfaceColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: borderColor),
      ),
      child: _buildSettingItem(
        context,
        icon: Icons.dark_mode_outlined,
        title: 'Dark Mode',
        subtitle: 'Switch between light and dark theme',
        trailing: Switch(
          value: controller.darkModeEnabled,
          onChanged: (value) {
            HapticFeedback.selectionClick();
            controller.toggleDarkMode(value);
          },
          activeColor: AppColors.primary,
        ),
        isDark: isDark,
        showDivider: false,
      ),
    );
  }

  Widget _buildAccountSettings(
    BuildContext context,
    DoctorSettingsController controller,
    bool isDark,
  ) {
    final surfaceColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            context,
            icon: Icons.account_circle_outlined,
            title: 'Account Settings',
            subtitle: 'Manage your account information',
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
              controller.onAccountSettings();
            },
            showDivider: true,
          ),
          _buildSettingItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            subtitle: 'Manage your privacy settings',
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
              controller.onPrivacySettings();
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSettings(
    BuildContext context,
    DoctorSettingsController controller,
    bool isDark,
  ) {
    final surfaceColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with using the app',
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
              controller.onHelpSupport();
            },
            showDivider: true,
          ),
          _buildSettingItem(
            context,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
              controller.onAbout();
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required bool isDark,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacing4),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppConstants.spacing4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppConstants.body1Size,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF111518),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing1 / 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: AppConstants.body2Size,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacing2),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    DoctorSettingsController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            controller.onLogout();
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacing4,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.red, size: 20),
                const SizedBox(width: AppConstants.spacing2),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: AppConstants.body1Size,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
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
