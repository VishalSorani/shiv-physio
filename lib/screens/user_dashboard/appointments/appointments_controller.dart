import '../../../data/base_class/base_controller.dart';
import '../../../widgets/app_appointment_list_card.dart';

/// Appointment data model
class AppointmentData {
  final String doctorName;
  final String specialization;
  final String month;
  final int day;
  final String time;
  final AppointmentStatus status;
  final AppointmentType type;
  final String? location;

  AppointmentData({
    required this.doctorName,
    required this.specialization,
    required this.month,
    required this.day,
    required this.time,
    required this.status,
    required this.type,
    this.location,
  });
}

class AppointmentsController extends BaseController {
  static const String contentId = 'appointments_content';
  static const String tabsId = 'appointments_tabs';
  static const String listId = 'appointments_list';

  // Tab indices
  static const int upcomingTabIndex = 0;
  static const int completedTabIndex = 1;
  static const int cancelledTabIndex = 2;

  // Tab state
  int _currentTabIndex = upcomingTabIndex;
  int get currentTabIndex => _currentTabIndex;

  // Appointment data (mock data for now)
  final List<AppointmentData> _allAppointments = [
    AppointmentData(
      doctorName: 'Dr. Pradip Chauhan',
      specialization: 'Physiotherapy • Assessment',
      month: 'Oct',
      day: 24,
      time: '10:00 AM',
      status: AppointmentStatus.confirmed,
      type: AppointmentType.online,
    ),
    AppointmentData(
      doctorName: 'Dr. Sarah Lee',
      specialization: 'Manual Therapy',
      month: 'Nov',
      day: 1,
      time: '09:00 AM',
      status: AppointmentStatus.pending,
      type: AppointmentType.clinic,
      location: 'Clinic Room 3',
    ),
    AppointmentData(
      doctorName: 'Dr. Pradip Chauhan',
      specialization: 'Post-Surgery Rehab',
      month: 'Sep',
      day: 15,
      time: '02:30 PM',
      status: AppointmentStatus.completed,
      type: AppointmentType.clinic,
      location: 'Clinic Room 1',
    ),
  ];

  List<AppointmentData> get appointments {
    switch (_currentTabIndex) {
      case upcomingTabIndex:
        return _allAppointments
            .where((a) =>
                a.status == AppointmentStatus.confirmed ||
                a.status == AppointmentStatus.pending)
            .toList();
      case completedTabIndex:
        return _allAppointments
            .where((a) => a.status == AppointmentStatus.completed)
            .toList();
      case cancelledTabIndex:
        return _allAppointments
            .where((a) => a.status == AppointmentStatus.cancelled)
            .toList();
      default:
        return [];
    }
  }

  bool get isEmpty => appointments.isEmpty;

  void onTabChanged(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      update([tabsId, listId]);
    }
  }

  void onBackTap() {
    // Navigate back or pop
  }

  void onAddAppointmentTap() {
    // Navigate to book appointment screen
  }

  void onRescheduleTap(AppointmentData appointment) {
    // Handle reschedule
  }

  void onCancelTap(AppointmentData appointment) {
    // Handle cancel
  }

  void onViewPrescriptionTap(AppointmentData appointment) {
    // Handle view prescription
  }

  void onViewTreatmentPlanTap(AppointmentData appointment) {
    // Handle view treatment plan
  }

  void onAppointmentTap(AppointmentData appointment) {
    // Handle appointment tap
  }

  void onBookAppointmentTap() {
    // Navigate to book appointment screen
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
  }
}
