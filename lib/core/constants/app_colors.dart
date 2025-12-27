import 'package:flutter/material.dart';

/// App color palette following SafeCircle UI/UX Spec
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2094F3); // Blue - Trust, Safety
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);

  // Accent Colors
  static const Color accent = Color(0xFF4CAF50); // Green - Safe, Active
  static const Color accentLight = Color(0xFF81C784);
  static const Color accentDark = Color(0xFF388E3C);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color danger = Color(0xFFFF5252);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color surfaceVariant = Color(0xFFE0E0E0);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);

  // App backgrounds (used by Splash and other marketing-style screens)
  static const Color backgroundLight = Color(0xFFF5F7F8);
  static const Color backgroundDark = Color(0xFF101A22);

  // Splash card surfaces
  static const Color splashCardDark = Color(0xFF1A2630);
  static const Color splashCardDarkStart = Color(0xFF1E2A35);

  // Dashboard surfaces
  static const Color surfaceDark = Color(0xFF1C2B36);

  // Privacy Mode
  static const Color privacyPurple = Color(0xFF9C27B0);
  static const Color privacyLight = Color(0xFFBA68C8);

  // Emergency
  static const Color sosDanger = Color(0xFFFF1744);
  static const Color sosBackground = Color(0xFFFFEBEE);

  // Text Colors
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textOnPrimary = Colors.white;
}
