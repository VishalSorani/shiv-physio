import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Fully customizable app bar with centered title
/// Can be used as PreferredSizeWidget in Scaffold.appBar
class AppCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text (centered by default)
  final String? title;

  /// Custom title widget (if provided, overrides title text)
  final Widget? titleWidget;

  /// Leading widget (typically back button)
  final Widget? leading;

  /// Action widgets (typically buttons on the right)
  final List<Widget>? actions;

  /// Single action widget (convenience for single action)
  final Widget? action;

  /// Background color (null uses theme-based default)
  final Color? backgroundColor;

  /// Border color (null uses theme-based default)
  final Color? borderColor;

  /// Whether to show border
  final bool showBorder;

  /// Whether to show shadow
  final bool showShadow;

  /// Custom elevation/shadow
  final double? elevation;

  /// Custom height
  final double? height;

  /// Padding for content
  final EdgeInsets? padding;

  /// Whether to automatically handle SafeArea
  final bool automaticallyImplyLeading;

  /// Center title flag (default: true)
  final bool centerTitle;

  /// Custom decoration
  final BoxDecoration? decoration;

  const AppCustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.action,
    this.backgroundColor,
    this.borderColor,
    this.showBorder = true,
    this.showShadow = true,
    this.elevation,
    this.height,
    this.padding,
    this.automaticallyImplyLeading = false,
    this.centerTitle = true,
    this.decoration,
  }) : assert(
         title != null || titleWidget != null,
         'Either title or titleWidget must be provided',
       );

  @override
  Size get preferredSize => Size.fromHeight(height ?? kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        backgroundColor ?? (isDark ? AppColors.surfaceDark : Colors.white);
    final borderColorValue =
        borderColor ?? (isDark ? Colors.grey.shade800 : Colors.grey.shade100);

    return Container(
      decoration:
          decoration ??
          BoxDecoration(
            color: bgColor,
            border: showBorder
                ? Border(bottom: BorderSide(color: borderColorValue, width: 1))
                : null,
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        elevation != null ? elevation! / 10 : 0.05,
                      ),
                      blurRadius: elevation ?? 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: height ?? kToolbarHeight,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
          child: Stack(
            children: [
              // Title (centered) - positioned absolutely for true centering
              if (centerTitle)
                Positioned.fill(
                  child: Center(
                    child:
                        titleWidget ??
                        Text(
                          title ?? '',
                          style: TextStyle(
                            fontSize: AppConstants.h4Size,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF111518),
                            letterSpacing: -0.015,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                  ),
                ),
              // Leading and Actions row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Leading widget
                  SizedBox(
                    width: 48,
                    child:
                        leading ??
                        (automaticallyImplyLeading
                            ? _buildDefaultLeading(context, isDark)
                            : null),
                  ),
                  // Spacer to balance layout when title is centered
                  if (centerTitle) const Spacer(),
                  // Title (left-aligned when not centered)
                  if (!centerTitle)
                    Expanded(
                      child:
                          titleWidget ??
                          Text(
                            title ?? '',
                            style: TextStyle(
                              fontSize: AppConstants.h4Size,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF111518),
                              letterSpacing: -0.015,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                    ),
                  // Actions
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (action != null) action!,
                        if (actions != null) ...actions!,
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildDefaultLeading(BuildContext context, bool isDark) {
    if (Navigator.of(context).canPop()) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : const Color(0xFF111518),
            ),
          ),
        ),
      );
    }
    return null;
  }
}
