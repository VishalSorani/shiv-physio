import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shiv_physio_app/data/models/enums.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/modules/doctor_home_repository.dart';
import '../../../data/models/appointment_request.dart';
import '../../../widgets/app_snackbar.dart';
import '../patients/patients_screen.dart';
import '../patients/patients_binding.dart';
import '../content/content_screen.dart';
import '../content/content_binding.dart';
import '../notifications/notifications_screen.dart';
import '../notifications/notifications_binding.dart';
import '../doctor_dashboard_controller.dart';

class DoctorHomeController extends BaseController {
  static const String contentId = 'doctor_home_content';
  static const String pendingRequestsId = 'pending_requests';
  static const String scheduleId = 'schedule';
  static const String analyticsId = 'analytics';

  final DoctorHomeRepository _homeRepository;

  DoctorHomeController(this._homeRepository);

  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Doctor info
  String _doctorName = 'Dr. Pradip';
  String get doctorName => _doctorName;
  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;
  bool _hasNotifications = false;
  bool get hasNotifications => _hasNotifications;

  // Loading states for buttons
  bool _isApproving = false;
  bool get isApproving => _isApproving;

  bool _isDeclining = false;
  bool get isDeclining => _isDeclining;

  // Decline state
  bool _showDeclineDialog = false;
  bool get showDeclineDialog => _showDeclineDialog;
  String _declineReason = '';
  String get declineReason => _declineReason;

  // Pending requests
  List<AppointmentRequest> _pendingRequests = [];
  List<Map<String, dynamic>> get pendingRequests {
    return _pendingRequests.map((request) {
      return {
        'id': request.appointment.id,
        'appointment': request.appointment,
        'patientName': request.patient.fullName ?? 'Unknown Patient',
        'treatmentType': request.appointment.patientNote ?? 'General Consultation',
        'dateTime': _formatAppointmentDateTime(request.appointment.startAt),
        'avatarUrl': request.patient.avatarUrl,
        'isNew': request.isNew,
      };
    }).toList();
  }

  // Today's schedule
  List<AppointmentRequest> _todaysSchedule = [];
  List<Map<String, dynamic>> get scheduleItems {
    final items = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (final request in _todaysSchedule) {
      final appointmentTime = request.appointment.startAt;
      final isActive =
          appointmentTime.isBefore(now) &&
          request.appointment.endAt.isAfter(now) &&
          request.appointment.status == AppointmentStatus.confirmed;

      items.add({
        'id': request.appointment.id,
        'appointment': request.appointment,
        'time': _formatTime(appointmentTime),
        'patientInitials': _getInitials(request.patient.fullName ?? ''),
        'patientName': request.patient.fullName ?? 'Unknown Patient',
        'treatmentType': request.appointment.patientNote ?? 'General Consultation',
        'isActive': isActive,
        'isBreak': false,
        'isOnline': false, // Can be determined from appointment type if available
      });
    }

    return items;
  }

  // Analytics
  Map<String, dynamic> _analytics = {};
  List<Map<String, dynamic>> get analytics {
    final totalPatients = _analytics['totalPatients'] ?? 0;
    final totalAppointments = _analytics['totalAppointments'] ?? 0;
    final completionRate = _analytics['completionRate'] ?? 0.0;

    return [
      {
        'label': 'Total Patients',
        'value': _formatNumber(totalPatients),
        'trend': '+5%', // TODO: Calculate trend from previous month
        'isPositiveTrend': true,
      },
      {
        'label': 'Appointments',
        'value': totalAppointments.toString(),
        'secondaryValue':
            '/ ${totalAppointments + 15}', // TODO: Get target from settings
      },
      {
        'label': 'Completion',
        'value': '${completionRate.toStringAsFixed(0)}%',
        'valueColor': AppColors.primary,
      },
    ];
  }

  // Quick actions (static)
  List<Map<String, dynamic>> get quickActions => [
    {
      'icon': Icons.diversity_1,
      'label': 'Patient\nManagement',
      'color': AppColors.primary,
    },
    {
      'icon': Icons.upload_file,
      'label': 'Upload\nContent',
      'color': AppColors.privacyPurple,
    },
  ];

  String get currentDate {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,\n$doctorName';
    } else if (hour < 17) {
      return 'Good Afternoon,\n$doctorName';
    } else {
      return 'Good Evening,\n$doctorName';
    }
  }

  bool get hasPendingRequests => _pendingRequests.isNotEmpty;
  bool get hasTodaysSchedule => _todaysSchedule.isNotEmpty;
  bool get hasAnalytics => _analytics.isNotEmpty;
  bool get hasData => !_isLoading; // Used to determine if we should show loading screen

  String _formatAppointmentDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    if (appointmentDate == today) {
      return 'Today, ${_formatTime(dateTime)}';
    } else if (appointmentDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${_formatTime(dateTime)}';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 2 ? 2 : name.length).toUpperCase();
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }


  Future<void> loadHomeData({bool showLoading = true}) async {
    await handleAsyncOperation(() async {
      if (showLoading) {
        _isLoading = true;
        update([contentId]);
      }

      try {
        // Load all data in parallel
        final results = await Future.wait([
          _homeRepository.getDoctorInfo(),
          _homeRepository.getPendingRequests(),
          _homeRepository.getTodaysSchedule(),
          _homeRepository.getAnalytics(),
        ]);

        // Update doctor info
        final doctorInfo = results[0] as Map<String, dynamic>?;
        if (doctorInfo != null) {
          _doctorName = doctorInfo['full_name'] ?? _doctorName;
          _avatarUrl = doctorInfo['avatar_url'];
        }

        // Update pending requests
        _pendingRequests = results[1] as List<AppointmentRequest>;
        _hasNotifications = _pendingRequests.isNotEmpty;

        // Update today's schedule
        _todaysSchedule = results[2] as List<AppointmentRequest>;

        // Update analytics
        _analytics = results[3] as Map<String, dynamic>;

        update([contentId, pendingRequestsId, scheduleId, analyticsId]);
      } finally {
        if (showLoading) {
          _isLoading = false;
          update([contentId]);
        }
      }
    });
  }

  /// Refresh home data (for pull-to-refresh, doesn't show loading screen)
  Future<void> refreshHomeData() async {
    await loadHomeData(showLoading: false);
  }

  void onViewAllRequestsTap() {
    // Navigate to appointments tab in doctor dashboard
    try {
      final dashboardController = Get.find<DoctorDashboardController>();
      dashboardController.onBottomNavTap(DoctorDashboardController.appointmentsTabIndex);
    } catch (e) {
      // If DoctorDashboardController is not found, navigate using navigation service
      // This handles cases where we're not in the dashboard context
      // TODO: Implement navigation service fallback if needed
    }
  }

  Future<void> onApproveRequest(Map<String, dynamic> request) async {
    final appointmentId = request['id'] as String;
    _isApproving = true;
    update([pendingRequestsId]);
    
    try {
      await handleAsyncOperation(() async {
        await _homeRepository.approveAppointment(appointmentId);
        // Reload data
        await loadHomeData();
        AppSnackBar.success(
          title: 'Success',
          message: 'Appointment approved successfully',
        );
      });
    } finally {
      _isApproving = false;
      update([pendingRequestsId]);
    }
  }

  void onDeclineRequest(Map<String, dynamic> request) {
    _showDeclineDialog = true;
    _declineReason = '';
    update([pendingRequestsId]);
  }

  void onCancelDecline() {
    _showDeclineDialog = false;
    _declineReason = '';
    update([pendingRequestsId]);
  }

  void onDeclineReasonChanged(String reason) {
    _declineReason = reason;
  }

  Future<void> onConfirmDecline(Map<String, dynamic> request) async {
    if (_declineReason.isEmpty) {
      AppSnackBar.error(
        title: 'Error',
        message: 'Please provide a reason for declining',
      );
      return;
    }

    final appointmentId = request['id'] as String;
    _isDeclining = true;
    update([pendingRequestsId]);
    
    try {
      await handleAsyncOperation(() async {
        await _homeRepository.declineAppointment(
          appointmentId,
          reason: _declineReason,
        );
        // Reload data
        await loadHomeData();
        _showDeclineDialog = false;
        _declineReason = '';
        AppSnackBar.success(
          title: 'Success',
          message: 'Appointment declined',
        );
      });
    } finally {
      _isDeclining = false;
      update([pendingRequestsId]);
    }
  }

  void onScheduleItemTap(Map<String, dynamic> item) {
    // Navigate to appointment details
    // TODO: Implement navigation
  }

  void onQuickActionTap(Map<String, dynamic> action) {
    final label = action['label'] as String;
    if (label.contains('Patient')) {
      // Navigate to patient management screen
      Get.to(
        () => const PatientManagementScreen(),
        binding: PatientManagementBinding(),
      );
    } else if (label.contains('Upload') || label.contains('Content')) {
      // Navigate to content management screen
      Get.to(
        () => const ContentManagementScreen(),
        binding: ContentManagementBinding(),
      );
    } else {
      // Handle other quick actions
      // TODO: Implement navigation for other actions
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Track screen view
    trackScreenView('doctor_home_screen');
    loadHomeData();
  }

  void onNotificationTap() {
    Get.to(
      () => const DoctorNotificationsScreen(),
      binding: DoctorNotificationsBinding(),
    );
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
    if (isConnected) {
      loadHomeData();
    }
  }
}
