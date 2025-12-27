import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/base_class/base_screen.dart';
import '../../widgets/app_decorative_blobs.dart';
import '../../widgets/app_rotating_spinner.dart';
import 'splash_controller.dart';

class SplashScreen extends BaseScreenView<SplashController> {
  const SplashScreen({super.key});

  static const String splashScreen = '/splash-screen';

  @override
  Widget buildView(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111518);
    final textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF60778A);
    final metaText = isDark ? const Color(0xFF64748B) : const Color(0xFF60778A);

    // Respect reduced motion where possible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      controller.configureAnimations(
        enabled: !MediaQuery.of(context).disableAnimations,
      );
    });

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative background
            Positioned.fill(
              child: Stack(
                children: [
                  AppDecorativeBlob(
                    alignment: const Alignment(0.95, -0.95),
                    width: MediaQuery.of(context).size.width * 0.70,
                    height: MediaQuery.of(context).size.height * 0.50,
                    color: AppColors.primary,
                    opacity: 0.05,
                    blurRadius: 80,
                  ),
                  AppDecorativeBlob(
                    alignment: const Alignment(-0.95, 0.65),
                    width: MediaQuery.of(context).size.width * 0.60,
                    height: MediaQuery.of(context).size.height * 0.40,
                    color: AppColors.primary,
                    opacity: 0.10,
                    blurRadius: 80,
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing5),
              child: Column(
                children: [
                  // Scrollable main content to avoid overflow on smaller devices.
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo section
                              GetBuilder<SplashController>(
                                id: SplashController.logoId,
                                builder: (c) {
                                  return FadeTransition(
                                    opacity: c.logoOpacity,
                                    child: SlideTransition(
                                      position: c.logoOffset,
                                      child: _SplashLogo(
                                        isDark: isDark,
                                        onTap: c.onLogoTap,
                                        pulseScale: c.logoPulseScale,
                                        primary: AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: AppConstants.spacing6),

                              // Text section
                              GetBuilder<SplashController>(
                                id: SplashController.textId,
                                builder: (c) {
                                  return FadeTransition(
                                    opacity: c.textOpacity,
                                    child: SlideTransition(
                                      position: c.textOffset,
                                      child: Column(
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Shiv Physiotherapy\n',
                                                  style: TextStyle(
                                                    color: textPrimary,
                                                    fontSize: 32,
                                                    height: 1.10,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: -0.6,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: 'Clinic',
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontSize: 32,
                                                    height: 1.10,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: -0.6,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: AppConstants.spacing2,
                                          ),
                                          _GradientDivider(
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(
                                            height: AppConstants.spacing3,
                                          ),
                                          Text(
                                            'Dr. Pradip Chauhan',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: textSecondary,
                                              fontSize: 18,
                                              height: 1.2,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Footer (pinned)
                  GetBuilder<SplashController>(
                    id: SplashController.footerId,
                    builder: (c) {
                      return FadeTransition(
                        opacity: c.footerOpacity,
                        child: SlideTransition(
                          position: c.footerOffset,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppConstants.spacing4,
                            ),
                            child: Column(
                              children: [
                                if (c.animationsEnabled)
                                  AppRotatingSpinner(
                                    turns: c.spinnerTurns,
                                    size: 24,
                                    strokeWidth: 3,
                                    color: AppColors.primary,
                                    trackColor: AppColors.primary.withValues(
                                      alpha: 0.20,
                                    ),
                                  )
                                else
                                  AppRotatingSpinner(
                                    turns: const AlwaysStoppedAnimation(0),
                                    size: 24,
                                    strokeWidth: 3,
                                    color: AppColors.primary,
                                    trackColor: AppColors.primary.withValues(
                                      alpha: 0.20,
                                    ),
                                  ),
                                const SizedBox(height: AppConstants.spacing5),
                                Text(
                                  'v1.0',
                                  style: TextStyle(
                                    color: metaText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  final Animation<double> pulseScale;
  final Color primary;

  const _SplashLogo({
    required this.isDark,
    required this.onTap,
    required this.pulseScale,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.splashCardDark : Colors.white;
    final gradientStart = isDark ? AppColors.splashCardDarkStart : Colors.white;
    final gradientEnd = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseScale,
        builder: (context, child) {
          return Transform.scale(scale: pulseScale.value, child: child);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.30),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.25),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),

            // Card
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [gradientStart, gradientEnd],
                ),
                color: cardBg,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/applogo.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.health_and_safety,
                      size: 64,
                      color: primary,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientDivider extends StatelessWidget {
  final Color color;
  const _GradientDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      width: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            color.withValues(alpha: 0.40),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
