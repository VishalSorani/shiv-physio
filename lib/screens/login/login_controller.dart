import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import '../../data/base_class/base_controller.dart';
import '../../data/modules/auth_repository.dart';
import '../doctor_dashboard/doctor_dashboard_screen.dart';
import '../user_dashboard/user_dashboard_screen.dart';

class LoginController extends BaseController with GetTickerProviderStateMixin {
  // GetBuilder IDs
  static const String headerId = 'login_header';
  static const String buttonId = 'login_google_button';
  static const String footerId = 'login_footer';

  final AuthRepository _authRepository;

  LoginController(this._authRepository);

  // Animations
  late final AnimationController _entranceController;
  late final AnimationController _logoPulseController;
  late final AnimationController _buttonPressController;

  late final Animation<double> headerOpacity;
  late final Animation<Offset> headerOffset;

  late final Animation<double> buttonOpacity;
  late final Animation<Offset> buttonOffset;

  late final Animation<double> logoPulseScale;
  late final Animation<double> buttonScale;

  bool _animationsEnabled = true;
  bool get animationsEnabled => _animationsEnabled;

  bool _isSigningIn = false;
  bool get isSigningIn => _isSigningIn;

  @override
  void onInit() {
    super.onInit();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _logoPulseController = AnimationController(
      vsync: this,
      duration: AppConstants.shortAnimation,
    );

    _buttonPressController = AnimationController(
      vsync: this,
      duration: AppConstants.microAnimation,
      lowerBound: 0,
      upperBound: 1,
    );

    headerOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    headerOffset = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    buttonOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
    );
    buttonOffset = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
          ),
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

    buttonScale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _buttonPressController, curve: Curves.easeOut),
    );

    _startEntrance();
  }

  void configureAnimations({required bool enabled}) {
    if (_animationsEnabled == enabled) return;
    _animationsEnabled = enabled;
    if (!_animationsEnabled) {
      _entranceController.value = 1.0;
      update([headerId, buttonId, footerId]);
      return;
    }
    _startEntrance();
  }

  Future<void> _startEntrance() async {
    if (!_animationsEnabled) return;
    await _safeHaptic(() => HapticFeedback.lightImpact());
    await _entranceController.forward(from: 0);
  }

  Future<void> onLogoTap() async {
    await _safeHaptic(() => HapticFeedback.selectionClick());
    if (_animationsEnabled) {
      await _logoPulseController.forward(from: 0);
    }
  }

  Future<void> onGooglePressDown() async {
    if (!_animationsEnabled) return;
    await _buttonPressController.forward();
    update([buttonId]);
  }

  Future<void> onGooglePressUp() async {
    if (!_animationsEnabled) return;
    await _buttonPressController.reverse();
    update([buttonId]);
  }

  Future<void> onGoogleSignIn() async {
    if (_isSigningIn) return;
    await _safeHaptic(() => HapticFeedback.selectionClick());

    _isSigningIn = true;
    update([buttonId]);

    try {
      final bool isDoctor = await handleAsyncOperationWithOnlyErrorHandling(
        () async {
          return await _authRepository.signInWithGoogle();
        },
        showMaintenanceDialog: false,
      );

      await _safeHaptic(() => HapticFeedback.lightImpact());

      navigationService.offAllToRoute(
        isDoctor
            ? DoctorDashboardScreen.doctorDashboardScreen
            : UserDashboardScreen.userDashboardScreen,
        requireNetwork: false,
      );
    } finally {
      _isSigningIn = false;
      update([buttonId]);
    }
  }

  Future<void> onTermsTap() async {
    await _safeHaptic(() => HapticFeedback.selectionClick());
    // TODO: open Terms URL
  }

  Future<void> onPrivacyTap() async {
    await _safeHaptic(() => HapticFeedback.selectionClick());
    // TODO: open Privacy URL
  }

  Future<void> _safeHaptic(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {}
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // Login should be usable offline, but sign-in needs network.
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
  }

  @override
  void onClose() {
    _entranceController.dispose();
    _logoPulseController.dispose();
    _buttonPressController.dispose();
    super.onClose();
  }
}
