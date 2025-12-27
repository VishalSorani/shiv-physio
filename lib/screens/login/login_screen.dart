import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/base_class/base_screen.dart';
import '../../widgets/app_rotating_spinner.dart';
import 'login_controller.dart';

class LoginScreen extends BaseScreenView<LoginController> {
  const LoginScreen({super.key});

  static const String loginScreen = '/login-screen';

  @override
  Widget buildView(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final titleColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final subtitleColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final bodyColor = isDark
        ? const Color(0xFFD1D5DB)
        : const Color(0xFF475569);

    final buttonBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final buttonBorder = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final buttonText = isDark ? Colors.white : const Color(0xFF334155);

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
            // Decorative top background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 260,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.10 : 0.05,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(48),
                    bottomRight: Radius.circular(48),
                  ),
                ),
              ),
            ),

            // Content
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing5,
                        vertical: AppConstants.spacing6,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GetBuilder<LoginController>(
                                id: LoginController.headerId,
                                builder: (c) {
                                  return FadeTransition(
                                    opacity: c.headerOpacity,
                                    child: SlideTransition(
                                      position: c.headerOffset,
                                      child: Column(
                                        children: [
                                          _LoginLogo(
                                            isDark: isDark,
                                            pulseScale: c.logoPulseScale,
                                            onTap: c.onLogoTap,
                                          ),
                                          const SizedBox(
                                            height: AppConstants.spacing5,
                                          ),
                                          Text(
                                            'Shiv Physiotherapy Clinic',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: titleColor,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.4,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: AppConstants.spacing1,
                                          ),
                                          Text(
                                            'Dr. Pradip Chauhan',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: subtitleColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: AppConstants.spacing6,
                                          ),
                                          Text(
                                            'Welcome back! Manage your recovery journey seamlessly.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: bodyColor,
                                              fontSize: 16,
                                              height: 1.4,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: AppConstants.spacing6),

                              GetBuilder<LoginController>(
                                id: LoginController.buttonId,
                                builder: (c) {
                                  return FadeTransition(
                                    opacity: c.buttonOpacity,
                                    child: SlideTransition(
                                      position: c.buttonOffset,
                                      child: AnimatedBuilder(
                                        animation: c.buttonScale,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: c.buttonScale.value,
                                            child: child,
                                          );
                                        },
                                        child: _GoogleSignInButton(
                                          isDark: isDark,
                                          backgroundColor: buttonBg,
                                          borderColor: buttonBorder,
                                          textColor: buttonText,
                                          isLoading: c.isSigningIn,
                                          onTap: c.onGoogleSignIn,
                                          onTapDown: c.onGooglePressDown,
                                          onTapUp: c.onGooglePressUp,
                                          onTapCancel: c.onGooglePressUp,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: AppConstants.spacing3),
                              Text(
                                'Only Google sign-in is supported for security.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: AppConstants.spacing7),

                              GetBuilder<LoginController>(
                                id: LoginController.footerId,
                                builder: (c) {
                                  return _LoginFooter(
                                    linkColor: AppColors.primary,
                                    textColor: subtitleColor,
                                    badgeColor: isDark
                                        ? const Color(0xFF475569)
                                        : const Color(0xFFCBD5E1),
                                    onTermsTap: c.onTermsTap,
                                    onPrivacyTap: c.onPrivacyTap,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginLogo extends StatelessWidget {
  final bool isDark;
  final Animation<double> pulseScale;
  final VoidCallback onTap;

  const _LoginLogo({
    required this.isDark,
    required this.pulseScale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseScale,
        builder: (context, child) =>
            Transform.scale(scale: pulseScale.value, child: child),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow gradient
            Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: card,
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/applogo.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.health_and_safety,
                      size: 52,
                      color: AppColors.primary,
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

class _GoogleSignInButton extends StatelessWidget {
  final bool isDark;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isLoading;
  final VoidCallback onTap;
  final Future<void> Function() onTapDown;
  final Future<void> Function() onTapUp;
  final Future<void> Function() onTapCancel;

  const _GoogleSignInButton({
    required this.isDark,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.isLoading,
    required this.onTap,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sign in with Google',
      enabled: !isLoading,
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        onTapDown: (_) => onTapDown(),
        onTapUp: (_) => onTapUp(),
        onTapCancel: () => onTapCancel(),
        child: AnimatedContainer(
          duration: AppConstants.shortAnimation,
          curve: Curves.easeInOut,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                blurRadius: isLoading ? 6 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                AppRotatingSpinner(
                  turns: const AlwaysStoppedAnimation(0.0),
                  size: 22,
                  strokeWidth: 3,
                  color: AppColors.primary,
                  trackColor: AppColors.primary.withValues(alpha: 0.20),
                )
              else
                const _GoogleMark(size: 22),
              const SizedBox(width: 12),
              Text(
                isLoading ? 'Signing in…' : 'Sign in with Google',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple Google mark (4-color) without extra dependencies.
class _GoogleMark extends StatelessWidget {
  final double size;
  const _GoogleMark({required this.size});

  @override
  Widget build(BuildContext context) {
    final s = size;
    return SizedBox(
      width: s,
      height: s,
      child: CustomPaint(painter: _GoogleMarkPainter()),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: r);
    final stroke = r * 0.45;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // Blue arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.2, 1.5, false, paint);

    // Red arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 1.35, 1.2, false, paint);

    // Yellow arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.45, 1.1, false, paint);

    // Green arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 3.35, 1.1, false, paint);

    // Small blue "bar" to hint the G shape
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(center.dx + r * 0.05, center.dy),
      Offset(center.dx + r * 0.65, center.dy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoginFooter extends StatelessWidget {
  final Color textColor;
  final Color linkColor;
  final Color badgeColor;
  final Future<void> Function() onTermsTap;
  final Future<void> Function() onPrivacyTap;

  const _LoginFooter({
    required this.textColor,
    required this.linkColor,
    required this.badgeColor,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  @override
  Widget build(BuildContext context) {
    final termsRecognizer = TapGestureRecognizer()..onTap = () => onTermsTap();
    final privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => onPrivacyTap();

    return Column(
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
            children: [
              const TextSpan(text: 'By signing in, you agree to our '),
              TextSpan(
                text: 'Terms of Service',
                style: TextStyle(color: linkColor, fontWeight: FontWeight.w700),
                recognizer: termsRecognizer,
              ),
              const TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(color: linkColor, fontWeight: FontWeight.w700),
                recognizer: privacyRecognizer,
              ),
              const TextSpan(text: '.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacing4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 16, color: badgeColor),
            const SizedBox(width: 6),
            Text(
              'Secure Login',
              style: TextStyle(
                color: badgeColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
