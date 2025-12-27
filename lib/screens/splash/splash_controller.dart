import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import '../../data/base_class/base_controller.dart';
import '../../data/service/storage_service.dart';
import '../doctor_dashboard/doctor_dashboard_screen.dart';
import '../login/login_screen.dart';
import '../user_dashboard/user_dashboard_screen.dart';

class SplashController extends BaseController with GetTickerProviderStateMixin {
  // GetBuilder IDs
  static const String logoId = 'splash_logo';
  static const String textId = 'splash_text';
  static const String footerId = 'splash_footer';

  final StorageService _storageService;

  SplashController(this._storageService);

  // Animations
  late final AnimationController _entranceController;
  late final AnimationController _spinnerController;
  late final AnimationController _logoPulseController;

  late final Animation<double> logoOpacity;
  late final Animation<Offset> logoOffset;

  late final Animation<double> textOpacity;
  late final Animation<Offset> textOffset;

  late final Animation<double> footerOpacity;
  late final Animation<Offset> footerOffset;

  late final Animation<double> spinnerTurns;
  late final Animation<double> logoPulseScale;

  bool _animationsEnabled = true;
  bool get animationsEnabled => _animationsEnabled;

  Timer? _navTimer;

  @override
  void onInit() {
    super.onInit();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoPulseController = AnimationController(
      vsync: this,
      duration: AppConstants.shortAnimation,
    );

    logoOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );
    logoOffset = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
          ),
        );

    textOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.12, 0.80, curve: Curves.easeOut),
    );
    textOffset = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.12, 0.80, curve: Curves.easeOutCubic),
          ),
        );

    footerOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.24, 1.0, curve: Curves.easeOut),
    );
    footerOffset = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.24, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    spinnerTurns = CurvedAnimation(
      parent: _spinnerController,
      curve: Curves.linear,
    );

    logoPulseScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.96,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.96,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_logoPulseController);

    _startAnimations();

    // Check if user is already logged in and navigate accordingly
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() {
    _navTimer?.cancel();
    _navTimer = Timer(const Duration(seconds: 3), () {
      final user = _storageService.getUser();
      if (user != null) {
        // User is logged in, navigate to appropriate dashboard
        navigationService.offAllToRoute(
          user.isDoctor
              ? DoctorDashboardScreen.doctorDashboardScreen
              : UserDashboardScreen.userDashboardScreen,
          requireNetwork: false,
        );
      } else {
        // No user in storage, go to Login
        navigationService.offAllToRoute(
          LoginScreen.loginScreen,
          requireNetwork: false,
        );
      }
    });
  }

  void configureAnimations({required bool enabled}) {
    if (_animationsEnabled == enabled) return;
    _animationsEnabled = enabled;
    if (!_animationsEnabled) {
      _spinnerController.stop();
      _entranceController.value = 1.0;
      update([logoId, textId, footerId]);
      return;
    }
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    if (!_animationsEnabled) return;

    // One gentle haptic at start (ignore unsupported platforms).
    await _safeHaptic(() => HapticFeedback.lightImpact());

    _spinnerController.repeat();
    await _entranceController.forward(from: 0);
  }

  Future<void> onLogoTap() async {
    // Micro interaction to make the splash feel alive.
    await _safeHaptic(() => HapticFeedback.selectionClick());
    if (_animationsEnabled) {
      await _logoPulseController.forward(from: 0);
    }
  }

  Future<void> _safeHaptic(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // No-op (e.g., web/desktop).
    }
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // Splash is mostly offline-safe; keep default behavior (snackbar once).
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
  }

  @override
  void onClose() {
    _navTimer?.cancel();
    _entranceController.dispose();
    _spinnerController.dispose();
    _logoPulseController.dispose();
    super.onClose();
  }
}
