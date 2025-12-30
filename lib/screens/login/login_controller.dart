import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../data/base_class/base_controller.dart';
import '../../data/modules/auth_repository.dart';
import '../../data/service/remote_config_service.dart';
import '../../data/service/storage_service.dart';
import '../../widgets/app_snackbar.dart';
import '../doctor_dashboard/doctor_dashboard_screen.dart';
import '../user_dashboard/user_dashboard_screen.dart';
import '../user_dashboard/profile_setup/profile_setup_screen.dart';

class LoginController extends BaseController with GetTickerProviderStateMixin {
  // GetBuilder IDs
  static const String headerId = 'login_header';
  static const String buttonId = 'login_google_button';
  static const String footerId = 'login_footer';

  final AuthRepository _authRepository;
  final StorageService _storageService;
  final RemoteConfigService _remoteConfigService;

  LoginController(
    this._authRepository,
    this._storageService,
    this._remoteConfigService,
  );

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
    // Track screen view
    trackScreenView('login_screen');

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

    // Track login attempt
    trackAnalyticsEvent('login_attempt', parameters: {
      'method': 'google',
    });

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

      // Get user from storage and set analytics
      final user = _storageService.getUser();
      if (user != null) {
        await setUserAnalytics(
          userId: user.id,
          userType: isDoctor ? 'doctor' : 'patient',
          email: user.email,
          hasPhone: user.phone != null && user.phone!.isNotEmpty,
        );
      } else {
        // Fallback: set basic analytics if user not found
        await setAnalyticsUserProperties({
          'user_type': isDoctor ? 'doctor' : 'patient',
        });
        await setCrashlyticsCustomKey('user_type', isDoctor ? 'doctor' : 'patient');
      }

      // Track successful login
      trackAnalyticsEvent('login_success', parameters: {
        'method': 'google',
        'user_type': isDoctor ? 'doctor' : 'patient',
      });

      // Check if user is a doctor or patient
      if (isDoctor) {
        navigationService.offAllToRoute(
          DoctorDashboardScreen.doctorDashboardScreen,
          requireNetwork: false,
        );
      } else {
        // For patients, check if profile is complete
        final isProfileComplete = await _authRepository.isUserProfileComplete();
        if (isProfileComplete) {
          navigationService.offAllToRoute(
            UserDashboardScreen.userDashboardScreen,
            requireNetwork: false,
          );
        } else {
          // Navigate to profile setup if profile is incomplete
          navigationService.offAllToRoute(
            ProfileSetupScreen.profileSetupScreen,
            requireNetwork: false,
          );
        }
      }
    } catch (e) {
      // Track login failure
      trackAnalyticsEvent('login_failure', parameters: {
        'method': 'google',
        'error': e.toString(),
      });
      rethrow;
    } finally {
      _isSigningIn = false;
      update([buttonId]);
    }
  }

  Future<void> onTermsTap() async {
    await _safeHaptic(() => HapticFeedback.selectionClick());
    try {
      final termsUrl = _remoteConfigService.getTermsOfServiceUrl();
      
      if (termsUrl.isEmpty) {
        AppSnackBar.error(
          title: 'Error',
          message: 'Terms of Service URL is not configured',
        );
        return;
      }

      final uri = Uri.parse(termsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        // Track analytics
        trackAnalyticsEvent('terms_of_service_opened', parameters: {
          'source': 'login_screen',
        });
      } else {
        AppSnackBar.error(
          title: 'Error',
          message: 'Could not open Terms of Service URL',
        );
      }
    } catch (e) {
      debugPrint('Error opening Terms of Service: $e');
      AppSnackBar.error(
        title: 'Error',
        message: 'Failed to open Terms of Service',
      );
    }
  }

  Future<void> onPrivacyTap() async {
    await _safeHaptic(() => HapticFeedback.selectionClick());
    try {
      final privacyUrl = _remoteConfigService.getPrivacyPolicyUrl();
      
      if (privacyUrl.isEmpty) {
        AppSnackBar.error(
          title: 'Error',
          message: 'Privacy Policy URL is not configured',
        );
        return;
      }

      final uri = Uri.parse(privacyUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        // Track analytics
        trackAnalyticsEvent('privacy_policy_opened', parameters: {
          'source': 'login_screen',
        });
      } else {
        AppSnackBar.error(
          title: 'Error',
          message: 'Could not open Privacy Policy URL',
        );
      }
    } catch (e) {
      debugPrint('Error opening Privacy Policy: $e');
      AppSnackBar.error(
        title: 'Error',
        message: 'Failed to open Privacy Policy',
      );
    }
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
