import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/modules/appointments_repository.dart';
import '../../../data/modules/content_repository.dart';
import '../../../data/modules/notification_repository.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/content_item.dart';
import '../../../data/service/storage_service.dart';
import '../../doctor_dashboard/content/content_viewer_dialogs.dart' as viewer;
import '../../user_dashboard/book_appointment/book_appointment_screen.dart';
import '../../user_dashboard/content/content_screen.dart';
import '../../user_dashboard/notifications/notifications_screen.dart';
import '../../user_dashboard/notifications/notifications_binding.dart';
import '../../user_dashboard/user_dashboard_controller.dart';
import '../../user_dashboard/user_dashboard_screen.dart';

class HomeController extends BaseController {
  static const String contentId = 'home_content';
  static const String appointmentId = 'home_appointment';
  static const String highlightsId = 'home_highlights';
  static const String recoveryId = 'home_recovery';
  static const String notificationBadgeId = 'notification_badge';

  final StorageService _storageService;
  final AppointmentsRepository _appointmentsRepository;
  final ContentRepository _contentRepository;
  final NotificationRepository _notificationRepository;

  HomeController(
    this._storageService,
    this._appointmentsRepository,
    this._contentRepository,
    this._notificationRepository,
  );

  // User info
  String? get userName => _storageService.getUser()?.fullName;
  String? get avatarUrl => _storageService.getUser()?.avatarUrl;

  // Upcoming appointment data
  Appointment? _upcomingAppointment;
  Appointment? get upcomingAppointment => _upcomingAppointment;

  // Doctor info data
  Map<String, dynamic>? _doctorInfo;
  Map<String, dynamic>? get doctorInfo => _doctorInfo;

  bool get hasUpcomingAppointment => _upcomingAppointment != null;

  String get upcomingAppointmentTitle => 'Physiotherapy Session';
  String get upcomingDoctorName {
    if (_upcomingAppointment != null) {
      // Get from appointment doctor info if available
      return 'Dr. Pradip Chauhan'; // TODO: Get from appointment
    }
    // Get from doctor info
    return _doctorInfo?['full_name']?.toString() ?? 'Dr. Pradip Chauhan';
  }

  String get upcomingDoctorSpecialization {
    if (_upcomingAppointment != null) {
      return 'Senior Physiotherapist'; // TODO: Get from appointment
    }
    return _doctorInfo?['specializations']?.toString() ??
        _doctorInfo?['title']?.toString() ??
        'Senior Physiotherapist';
  }

  String? get upcomingDoctorAvatarUrl {
    if (_upcomingAppointment != null) {
      return null; // TODO: Get from appointment
    }
    return _doctorInfo?['avatar_url']?.toString();
  }

  String? get doctorTitle => _doctorInfo?['title']?.toString();
  String? get clinicName => _doctorInfo?['clinic_name']?.toString();
  String? get clinicAddress => _doctorInfo?['clinic_address']?.toString();

  String get upcomingTime {
    if (_upcomingAppointment == null) return 'No upcoming appointment';
    final time = _upcomingAppointment!.startAt;
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get upcomingDate {
    if (_upcomingAppointment == null) return '';
    final now = DateTime.now();
    final appointmentDate = _upcomingAppointment!.startAt;

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
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    if (appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day) {
      return 'Today, ${appointmentDate.day} ${months[appointmentDate.month - 1]}';
    } else if (appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day + 1) {
      return 'Tomorrow, ${appointmentDate.day} ${months[appointmentDate.month - 1]}';
    } else {
      return '${weekdays[appointmentDate.weekday - 1]}, ${appointmentDate.day} ${months[appointmentDate.month - 1]}';
    }
  }

  // Content items (replaces clinic highlights)
  List<ContentItem> _contentItems = [];
  List<ContentItem> get contentItems => _contentItems;

  // Recovery items (content items for recovery section)
  List<ContentItem> _recoveryItems = [];
  List<ContentItem> get recoveryItems => _recoveryItems;

  // Unread notification count
  int _unreadNotificationCount = 0;
  int get unreadNotificationCount => _unreadNotificationCount;
  bool get hasUnreadNotifications => _unreadNotificationCount > 0;

  @override
  void onInit() {
    super.onInit();
    loadData();
    loadUnreadNotificationCount();
  }

  Future<void> loadData() async {
    await handleAsyncOperation(() async {
      await Future.wait([loadAppointment(), loadContent()]);
    });
  }

  /// Refresh data (for pull-to-refresh, doesn't show loading screen)
  Future<void> refreshData() async {
    await Future.wait([
      loadAppointment(),
      loadContent(),
      loadUnreadNotificationCount(),
    ]);
  }

  Future<void> loadUnreadNotificationCount() async {
    try {
      _unreadNotificationCount =
          await _notificationRepository.getUnreadNotificationCount();
      update([notificationBadgeId]);
    } catch (e) {
      // Error handled by repository
    }
  }

  Future<void> loadAppointment() async {
    try {
      _upcomingAppointment = await _appointmentsRepository.getNextAppointment();

      // If no appointment, load doctor info
      if (_upcomingAppointment == null) {
        await loadDoctorInfo();
      }

      update([appointmentId]);
    } catch (e) {
      // Error handled by repository
      // Still try to load doctor info if appointment failed
      if (_upcomingAppointment == null) {
        await loadDoctorInfo();
        update([appointmentId]);
      }
    }
  }

  Future<void> loadDoctorInfo() async {
    try {
      _doctorInfo = await _appointmentsRepository.getDoctorInfo();
    } catch (e) {
      // Error handled by repository
    }
  }

  Future<void> loadContent() async {
    try {
      final allContent = await _contentRepository.getContentItemsForPatients();

      // Get first 3 items for highlights
      _contentItems = allContent.take(3).toList();

      // Get recovery items (exercise category)
      _recoveryItems = allContent
          .where((item) => item.category == ContentCategory.exercise)
          .take(2)
          .toList();

      update([highlightsId, recoveryId]);
    } catch (e) {
      // Error handled by repository
    }
  }

  void onNotificationTap() {
    Get.to(
      () => const NotificationsScreen(),
      binding: NotificationsBinding(),
    )?.then((_) {
      // Refresh unread count when returning from notifications screen
      loadUnreadNotificationCount();
    });
  }

  void onProfileTap() {
    // TODO: Navigate to profile
  }

  void onAppointmentTap() {
    // TODO: Navigate to appointment details
  }

  void onRescheduleTap() {
    // TODO: Navigate to reschedule
  }

  void onBookTap() {
    navigationService.navigateToRoute(
      BookAppointmentScreen.bookAppointmentScreen,
    );
  }

  void onHistoryTap() {
    // Navigate to appointments tab (Schedule tab)
    try {
      final dashboardController = Get.find<UserDashboardController>();
      dashboardController.onBottomNavTap(UserDashboardController.appointmentsTabIndex);
    } catch (e) {
      // If UserDashboardController is not found, navigate using navigation service
      // This handles cases where we're not in the dashboard context
      navigationService.navigateToRoute(UserDashboardScreen.userDashboardScreen);
    }
  }

  void onChatTap() {
    // TODO: Navigate to chat
  }

  void onSeeAllHighlightsTap() {
    navigationService.navigateToRoute(ContentScreen.contentScreen);
  }

  void onHighlightTap(int index) {
    if (index < 0 || index >= _contentItems.length) return;
    final content = _contentItems[index];
    _showContent(content);
  }

  void onRecoveryItemTap(int index) {
    if (index < 0 || index >= _recoveryItems.length) return;
    final content = _recoveryItems[index];
    _showContent(content);
  }

  void _showContent(ContentItem content) {
    if (content.type == ContentType.video) {
      // Show video player dialog
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: viewer.VideoPlayerDialog(item: content),
        ),
        barrierDismissible: true,
      );
    } else {
      // Show image viewer dialog
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: viewer.ImageViewerDialog(item: content),
        ),
        barrierDismissible: true,
      );
    }
  }

  String? getContentImageUrl(ContentItem content) {
    if (content.type == ContentType.video) {
      return content.thumbnailUrl ?? content.fileUrl;
    }
    return content.fileUrl;
  }

  String? getContentBadge(ContentItem content) {
    switch (content.category) {
      case ContentCategory.exercise:
        if (content.description?.toLowerCase().contains('beginner') == true) {
          return 'Beginner';
        } else if (content.description?.toLowerCase().contains('advanced') ==
            true) {
          return 'Advanced';
        }
        return null;
      case ContentCategory.promotional:
        return 'New';
      default:
        return null;
    }
  }

  Color? getContentBadgeColor(ContentItem content) {
    final badge = getContentBadge(content);
    if (badge == 'Beginner') {
      return Colors.white;
    } else if (badge == 'Advanced') {
      return AppColors.primary;
    } else if (badge == 'New') {
      return AppColors.primary;
    }
    return null;
  }

  String? getDuration(ContentItem content) {
    if (content.duration != null) {
      final minutes = content.duration! ~/ 60;
      final seconds = content.duration! % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return null;
  }

  @override
  void handleNetworkChange(bool isConnected) {
    handleNetworkChangeDefault(isConnected);
    if (isConnected) {
      loadData();
    }
  }
}
