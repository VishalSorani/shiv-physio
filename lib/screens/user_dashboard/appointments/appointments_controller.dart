import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/user.dart';
import '../../../data/modules/appointments_repository.dart';
import '../../../widgets/app_appointment_list_card.dart' as card;
import '../../../widgets/app_snackbar.dart';

class AppointmentsController extends BaseController {
  static const String contentId = 'appointments_content';
  static const String tabsId = 'appointments_tabs';
  static const String listId = 'appointments_list';

  final AppointmentsRepository _appointmentsRepository;

  AppointmentsController(
    this._appointmentsRepository,
  );

  // Tab indices
  static const int upcomingTabIndex = 0;
  static const int completedTabIndex = 1;
  static const int cancelledTabIndex = 2;

  // Tab state
  int _currentTabIndex = upcomingTabIndex;
  int get currentTabIndex => _currentTabIndex;

  // Appointment data
  List<Appointment> _allAppointments = [];
  User? _doctorInfo;

  List<Appointment> get appointments {
    final now = DateTime.now();
    switch (_currentTabIndex) {
      case upcomingTabIndex:
        return _allAppointments
            .where((a) {
              final isUpcoming = a.startAt.isAfter(now);
              final isPendingOrConfirmed = a.status == AppointmentStatus.pending ||
                  a.status == AppointmentStatus.confirmed;
              return isUpcoming && isPendingOrConfirmed;
            })
            .toList()
          ..sort((a, b) => a.startAt.compareTo(b.startAt));
      case completedTabIndex:
        return _allAppointments
            .where((a) => a.status == AppointmentStatus.completed)
            .toList()
          ..sort((a, b) => b.startAt.compareTo(a.startAt)); // Most recent first
      case cancelledTabIndex:
        return _allAppointments
            .where((a) => a.status == AppointmentStatus.cancelled)
            .toList()
          ..sort((a, b) => b.startAt.compareTo(a.startAt)); // Most recent first
      default:
        return [];
    }
  }

  bool get isEmpty => appointments.isEmpty;

  String get doctorName => _doctorInfo?.fullName ?? 'Dr. Pradip Chauhan';
  String get doctorSpecialization =>
      _doctorInfo?.specializations ??
      _doctorInfo?.title ??
      'Physiotherapist';
  String? get clinicAddress => _doctorInfo?.clinicAddress;

  @override
  void onInit() {
    super.onInit();
    _loadAppointments();
    _loadDoctorInfo();
  }

  Future<void> _loadAppointments() async {
    await handleAsyncOperation(() async {
      _allAppointments = await _appointmentsRepository.getPatientAppointments();
      update([listId]);
    });
  }

  Future<void> _loadDoctorInfo() async {
    try {
      final doctorInfoMap = await _appointmentsRepository.getDoctorInfo();
      if (doctorInfoMap != null) {
        _doctorInfo = User.fromJson(doctorInfoMap);
      }
    } catch (e) {
      // Error handled by repository
    }
  }

  void onTabChanged(int index) {
    if (_currentTabIndex != index) {
      HapticFeedback.selectionClick();
      _currentTabIndex = index;
      update([tabsId, listId]);
    }
  }

  void onBackTap() {
    navigationService.goBack();
  }

  void onAddAppointmentTap() {
    navigationService.navigateToRoute('/book-appointment');
  }

  void onRescheduleTap(Appointment appointment) {
    // TODO: Implement reschedule functionality
    AppSnackBar.info(
      title: 'Coming Soon',
      message: 'Reschedule functionality will be available soon',
    );
  }

  Future<void> onCancelTap(Appointment appointment) async {
    HapticFeedback.lightImpact();
    
    // Show confirmation dialog
    final shouldCancel = await _showCancelConfirmation(appointment);
    if (!shouldCancel) return;

    await handleAsyncOperation(() async {
      await _appointmentsRepository.cancelAppointment(
        appointmentId: appointment.id,
        cancelReason: 'Cancelled by patient',
      );
      
      // Reload appointments
      await _loadAppointments();
      
      AppSnackBar.success(
        title: 'Appointment Cancelled',
        message: 'Your appointment has been cancelled successfully',
      );
    });
  }

  Future<bool> _showCancelConfirmation(Appointment appointment) async {
    // This will be handled by the screen using Get.dialog
    // For now, return true to proceed
    return true;
  }

  void onViewPrescriptionTap(Appointment appointment) {
    // TODO: Implement view prescription
    AppSnackBar.info(
      title: 'Coming Soon',
      message: 'Prescription viewing will be available soon',
    );
  }

  void onViewTreatmentPlanTap(Appointment appointment) {
    // TODO: Implement view treatment plan
    AppSnackBar.info(
      title: 'Coming Soon',
      message: 'Treatment plan viewing will be available soon',
    );
  }

  void onAppointmentTap(Appointment appointment) {
    // Handle appointment tap - could navigate to details screen
  }

  void onBookAppointmentTap() {
    navigationService.navigateToRoute('/book-appointment');
  }

  // Helper methods to convert Appointment to card format
  String getMonth(Appointment appointment) {
    return DateFormat('MMM').format(appointment.startAt.toLocal());
  }

  int getDay(Appointment appointment) {
    return appointment.startAt.toLocal().day;
  }

  String getTime(Appointment appointment) {
    final localStart = appointment.startAt.toLocal();
    return DateFormat('hh:mm a').format(localStart);
  }

  // Map database AppointmentStatus to card widget AppointmentStatus
  card.AppointmentStatus getCardStatus(Appointment appointment) {
    // Map database status enum to card widget status enum
    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        return card.AppointmentStatus.confirmed;
      case AppointmentStatus.pending:
        return card.AppointmentStatus.pending;
      case AppointmentStatus.completed:
        return card.AppointmentStatus.completed;
      case AppointmentStatus.cancelled:
        return card.AppointmentStatus.cancelled;
      case AppointmentStatus.noShow:
        return card.AppointmentStatus.cancelled; // Treat no-show as cancelled for UI
    }
  }

  card.AppointmentType getAppointmentType(Appointment appointment) {
    // For now, all appointments are clinic type
    // Could be enhanced to check appointment type field if added to DB
    return card.AppointmentType.clinic;
  }

  @override
  void handleNetworkChange(bool isConnected) {
    handleNetworkChangeDefault(isConnected);
    if (isConnected) {
      _loadAppointments();
    }
  }
}
