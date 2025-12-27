import 'package:flutter/material.dart';

/// App-wide constants following SafeCircle UI/UX Spec
class AppConstants {
  // Animation Durations
  static const Duration microAnimation = Duration(
    milliseconds: 100,
  ); // Instant feedback
  static const Duration shortAnimation = Duration(
    milliseconds: 200,
  ); // Buttons, toggles
  static const Duration mediumAnimation = Duration(
    milliseconds: 350,
  ); // Cards, slides
  static const Duration longAnimation = Duration(
    milliseconds: 500,
  ); // Screen transitions

  // Animation Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideCurve = Curves.easeOutCubic;
  static const Curve fadeCurve = Curves.easeIn;

  // Spacing System (8pt grid)
  static const double spacing1 = 4.0; // Micro spacing
  static const double spacing2 = 8.0; // Small spacing
  static const double spacing3 = 12.0; // Medium-small
  static const double spacing4 = 16.0; // Standard spacing (most common)
  static const double spacing5 = 24.0; // Large spacing
  static const double spacing6 = 32.0; // Extra large
  static const double spacing7 = 48.0; // Section spacing
  static const double spacing8 = 64.0; // Screen padding

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircular = 100.0;

  // Button Heights
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 40.0;

  // Icon Sizes
  static const double iconSizeXSmall = 16.0;
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // FAB Sizes
  static const double fabSize = 56.0;
  static const double fabMiniSize = 40.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 6.0;
  static const double elevationXHigh = 8.0;
  static const double elevationModal = 24.0;

  // App Bar
  static const double appBarHeight = 56.0;
  static const double bottomNavBarHeight = 84.0;

  // Typography Scale
  static const double h1Size = 32.0;
  static const double h1SizeSmall = 28.0;
  static const double h2Size = 24.0;
  static const double h3Size = 20.0;
  static const double h4Size = 18.0;
  static const double body1Size = 16.0;
  static const double body2Size = 14.0;
  static const double captionSize = 12.0;
  static const double buttonTextSize = 16.0;
  static const double labelSize = 14.0;

  // Touch Targets
  static const double minTouchTarget = 48.0;

  // App Strings
  static const String appName = 'SafeCircle';
  static const String appTagline = 'Keep Your Family\nSafe & Connected';
}
