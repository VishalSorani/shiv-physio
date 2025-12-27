import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Bottom navigation bar item data
class BottomNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final int index;

  const BottomNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.index,
  });
}

/// Reusable bottom navigation bar
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavItem> items;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isSelected = currentIndex == item.index;
              final icon = isSelected
                  ? (item.selectedIcon ?? item.icon)
                  : item.icon;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(item.index);
                    },
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusSmall,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 28,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade400),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade400),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
