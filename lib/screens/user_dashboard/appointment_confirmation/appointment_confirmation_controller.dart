import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/user.dart';
import '../../../data/modules/appointments_repository.dart';
import '../../../data/service/storage_service.dart';

class AppointmentConfirmationController extends BaseController {
  static const String contentId = 'confirmation_content';
  static const String doctorInfoId = 'doctor_info';

  final StorageService _storageService;
  final AppointmentsRepository _appointmentsRepository;
  final Appointment appointment;

  AppointmentConfirmationController(
    this._storageService,
    this._appointmentsRepository,
    this.appointment,
  );

  User? _doctorInfo;
  User? get doctorInfo => _doctorInfo;

  String? get userName => _storageService.getUser()?.fullName;

  String get doctorName => _doctorInfo?.fullName ?? 'Dr. Pradip Chauhan';
  String get doctorSpecialization =>
      _doctorInfo?.specializations ?? _doctorInfo?.title ?? 'Physiotherapist';
  String? get doctorAvatarUrl => _doctorInfo?.avatarUrl;

  String get appointmentDate {
    // Ensure we're working with UTC DateTime, then convert to local
    final utcStart = appointment.startAt.isUtc
        ? appointment.startAt
        : appointment.startAt.toUtc();
    final localStart = utcStart.toLocal();
    return DateFormat('MMM dd, yyyy').format(localStart);
  }

  String get appointmentTime {
    // Ensure we're working with UTC DateTime, then convert to local
    final utcStart = appointment.startAt.isUtc
        ? appointment.startAt
        : appointment.startAt.toUtc();
    final utcEnd = appointment.endAt.isUtc
        ? appointment.endAt
        : appointment.endAt.toUtc();

    final localStart = utcStart.toLocal();
    final localEnd = utcEnd.toLocal();

    final startTime = DateFormat('hh:mm a').format(localStart);
    final endTime = DateFormat('hh:mm a').format(localEnd);
    return '$startTime - $endTime';
  }

  String get reason => appointment.reason ?? 'Not specified';
  String get reasonDetail {
    // Extract first part as main reason, rest as detail
    final parts = reason.split(',');
    if (parts.length > 1) {
      return parts.sublist(1).join(',').trim();
    }
    return '';
  }

  String get mainReason {
    final parts = reason.split(',');
    return parts.first.trim();
  }

  String get clinicName => _doctorInfo?.clinicName ?? 'Physio Center';
  String get clinicAddress =>
      _doctorInfo?.clinicAddress ?? '123 Wellness Blvd, Physio Center';

  @override
  void onInit() {
    super.onInit();
    _loadDoctorInfo();
  }

  Future<void> _loadDoctorInfo() async {
    try {
      final doctorInfoMap = await _appointmentsRepository.getDoctorInfo();
      if (doctorInfoMap != null) {
        _doctorInfo = User.fromJson(doctorInfoMap);
        update([doctorInfoId]);
      }
    } catch (e) {
      // Error handled by repository
    }
  }

  void onBack() {
    navigationService.offAllToRoute('/user-dashboard');
  }

  void onAddToCalendar() {
    HapticFeedback.lightImpact();
    // TODO: Implement add to calendar functionality
  }

  void onViewAppointments() {
    HapticFeedback.lightImpact();
    // Navigate to appointments screen
    navigationService.offAllToRoute('/user-dashboard');
  }

  @override
  void handleNetworkChange(bool isConnected) {
    handleNetworkChangeDefault(isConnected);
  }
}
