import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Reusable top app bar with user profile picture, greeting, and notification button
class AppUserTopBar extends StatelessWidget {
  final String? userName;
  final String? avatarUrl;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final int unreadNotificationCount;

  const AppUserTopBar({
    super.key,
    this.userName,
    this.avatarUrl,
    this.onNotificationTap,
    this.onProfileTap,
    this.unreadNotificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Container(
      padding: EdgeInsets.only(
        left: AppConstants.spacing4,
        right: AppConstants.spacing4,
        top: AppConstants.spacing5,
        bottom: AppConstants.spacing2,
      ),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.9),
      ),
      child: Row(
        children: [
          // Profile picture and greeting
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.backgroundDark
                            : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: avatarUrl != null && avatarUrl!.isNotEmpty
                          ? Image.network(
                              avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultAvatar(context),
                            )
                          : _buildDefaultAvatar(context),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: AppConstants.body2Size,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userName ?? 'User',
                        style: TextStyle(
                          fontSize: AppConstants.h4Size,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111518),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Notification button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onNotificationTap,
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? Colors.white : const Color(0xFF111518),
                      size: AppConstants.iconSizeMedium,
                    ),
                  ),
                  // Unread notification badge
                  if (unreadNotificationCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.backgroundDark
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadNotificationCount > 99
                              ? '99+'
                              : unreadNotificationCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
      child: Icon(
        Icons.person,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        size: 24,
      ),
    );
  }
}

