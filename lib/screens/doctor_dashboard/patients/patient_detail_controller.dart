import '../../../data/base_class/base_controller.dart';
import '../../../data/modules/patients_repository.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/user.dart' as app_models;
import '../../../data/models/enums.dart';

class PatientDetailController extends BaseController {
  static const String contentId = 'patient_detail_content';
  static const String profileId = 'patient_profile';
  static const String tabsId = 'appointment_tabs';
  static const String appointmentsId = 'appointments_list';

  final PatientsRepository _patientsRepository;
  final String patientId;

  PatientDetailController(this._patientsRepository, this.patientId);

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Patient data
  app_models.User? _patient;
  app_models.User? get patient => _patient;

  // Tab state
  int _selectedTabIndex = 0; // 0: All, 1: Upcoming, 2: Past
  int get selectedTabIndex => _selectedTabIndex;

  // Appointments
  List<Appointment> _allAppointments = [];
  List<Appointment> get appointments {
    final now = DateTime.now();
    switch (_selectedTabIndex) {
      case 1: // Upcoming
        return _allAppointments
            .where((apt) =>
                apt.startAt.isAfter(now) &&
                (apt.status == AppointmentStatus.pending ||
                    apt.status == AppointmentStatus.confirmed))
            .toList();
      case 2: // Past
        return _allAppointments
            .where((apt) =>
                apt.startAt.isBefore(now) ||
                apt.status == AppointmentStatus.completed ||
                apt.status == AppointmentStatus.cancelled)
            .toList();
      case 0: // All
      default:
        return _allAppointments;
    }
  }

  /// Load patient details and appointments
  Future<void> loadPatientData({bool showLoading = true}) async {
    await handleAsyncOperation(() async {
      if (showLoading) {
        _isLoading = true;
        update([contentId]);
      }

      try {
        // Load patient details
        _patient = await _patientsRepository.getPatientById(patientId);

        // Load appointments
        _allAppointments =
            await _patientsRepository.getPatientAppointments(patientId);

        update([profileId, appointmentsId]);
      } finally {
        if (showLoading) {
          _isLoading = false;
          update([contentId]);
        }
      }
    });
  }

  /// Refresh patient data (for pull-to-refresh)
  Future<void> refreshPatientData() async {
    await loadPatientData(showLoading: false);
  }

  /// Change selected tab
  void onTabChanged(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      update([tabsId, appointmentsId]);
    }
  }

  /// Get formatted patient name
  String get patientName => _patient?.fullName ?? 'Unknown Patient';

  /// Get formatted patient info (gender, age, phone)
  String get patientInfo {
    final parts = <String>[];
    if (_patient?.age != null) {
      parts.add('${_patient!.age} Years');
    }
    if (_patient?.phone != null) {
      parts.add(_patient!.phone!);
    }
    return parts.join(' • ');
  }

  @override
  void onInit() {
    super.onInit();
    loadPatientData();
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
    if (isConnected) {
      loadPatientData();
    }
  }
}

