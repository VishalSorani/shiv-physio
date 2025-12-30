import '../../../data/base_class/base_controller.dart';
import '../../../data/modules/chat_repository.dart';
import '../../../data/modules/patients_repository.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/treatment_plan.dart';
import '../../../data/models/user.dart' as app_models;
import '../../../data/models/enums.dart';
import '../../../screens/doctor_dashboard/chat/chat_conversation_screen.dart';

class PatientDetailController extends BaseController {
  static const String contentId = 'patient_detail_content';
  static const String profileId = 'patient_profile';
  static const String tabsId = 'appointment_tabs';
  static const String appointmentsId = 'appointments_list';
  static const String treatmentPlansId = 'treatment_plans';

  final PatientsRepository _patientsRepository;
  final ChatRepository _chatRepository;
  final String patientId;

  PatientDetailController(
    this._patientsRepository,
    this._chatRepository,
    this.patientId,
  );

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Chat button loading state
  static const String chatButtonId = 'chat_button';
  bool _isStartingChat = false;
  bool get isStartingChat => _isStartingChat;

  // Patient data
  app_models.User? _patient;
  app_models.User? get patient => _patient;

  // Tab state
  int _selectedTabIndex = 0; // 0: All, 1: Upcoming, 2: Past
  int get selectedTabIndex => _selectedTabIndex;

  // Treatment Plans
  List<TreatmentPlan> _treatmentPlans = [];
  List<TreatmentPlan> get treatmentPlans => _treatmentPlans;
  TreatmentPlan? get activeTreatmentPlan {
    if (_treatmentPlans.isEmpty) return null;
    try {
      return _treatmentPlans.firstWhere((plan) => plan.isActive);
    } catch (e) {
      // No active plan found, return the most recent one
      return _treatmentPlans.first;
    }
  }

  // Expanded plans state - only one plan can be expanded at a time
  String? _expandedPlanId;
  bool isPlanExpanded(String planId) => _expandedPlanId == planId;
  void togglePlanExpansion(String planId) {
    if (_expandedPlanId == planId) {
      // If clicking the same plan, collapse it
      _expandedPlanId = null;
    } else {
      // Expand the clicked plan (this automatically closes any previously expanded plan)
      _expandedPlanId = planId;
    }
    update([treatmentPlansId]);
  }

  // Appointments
  List<Appointment> _allAppointments = [];
  List<Appointment> get appointments {
    final now = DateTime.now();
    switch (_selectedTabIndex) {
      case 1: // Upcoming
        return _allAppointments
            .where(
              (apt) =>
                  apt.startAt.isAfter(now) &&
                  (apt.status == AppointmentStatus.pending ||
                      apt.status == AppointmentStatus.confirmed),
            )
            .toList();
      case 2: // Past
        return _allAppointments
            .where(
              (apt) =>
                  apt.startAt.isBefore(now) ||
                  apt.status == AppointmentStatus.completed ||
                  apt.status == AppointmentStatus.cancelled,
            )
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
        _allAppointments = await _patientsRepository.getPatientAppointments(
          patientId,
        );

        // Load treatment plans
        _treatmentPlans = await _patientsRepository.getPatientTreatmentPlans(
          patientId,
        );

        update([profileId, appointmentsId, treatmentPlansId]);
      } finally {
        if (showLoading) {
          _isLoading = false;
          update([contentId]);
        }
      }
    }, showLoadingIndicator: false);
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

  /// Create a new treatment plan
  Future<void> createTreatmentPlan({
    String? diagnosis,
    List<String>? medicalConditions,
    String? treatmentGoals,
    required String treatmentPlan,
    int? durationWeeks,
    int? frequencyPerWeek,
    String? notes,
  }) async {
    await handleAsyncOperation(() async {
      final createdPlan = await _patientsRepository.createTreatmentPlan(
        patientId: patientId,
        diagnosis: diagnosis,
        medicalConditions: medicalConditions,
        treatmentGoals: treatmentGoals,
        treatmentPlan: treatmentPlan,
        durationWeeks: durationWeeks,
        frequencyPerWeek: frequencyPerWeek,
        notes: notes,
      );

      _treatmentPlans.insert(0, createdPlan);
      update([treatmentPlansId]);
    });
  }

  /// Update an existing treatment plan
  Future<void> updateTreatmentPlan({
    required String treatmentPlanId,
    String? diagnosis,
    List<String>? medicalConditions,
    String? treatmentGoals,
    String? treatmentPlan,
    int? durationWeeks,
    int? frequencyPerWeek,
    String? notes,
    String? status,
  }) async {
    await handleAsyncOperation(() async {
      final updatedPlan = await _patientsRepository.updateTreatmentPlan(
        treatmentPlanId: treatmentPlanId,
        diagnosis: diagnosis,
        medicalConditions: medicalConditions,
        treatmentGoals: treatmentGoals,
        treatmentPlan: treatmentPlan,
        durationWeeks: durationWeeks,
        frequencyPerWeek: frequencyPerWeek,
        notes: notes,
        status: status,
      );

      final index = _treatmentPlans.indexWhere((p) => p.id == treatmentPlanId);
      if (index != -1) {
        _treatmentPlans[index] = updatedPlan;
        update([treatmentPlansId]);
      }
    });
  }

  /// Delete a treatment plan
  Future<void> deleteTreatmentPlan(String treatmentPlanId) async {
    await handleAsyncOperation(() async {
      await _patientsRepository.deleteTreatmentPlan(treatmentPlanId);
      _treatmentPlans.removeWhere((p) => p.id == treatmentPlanId);
      update([treatmentPlansId]);
    });
  }

  @override
  void onInit() {
    super.onInit();
    loadPatientData();
  }

  /// Start chat conversation with patient
  Future<void> startChatWithPatient() async {
    if (patientId.isEmpty || _isStartingChat) {
      return;
    }

    _isStartingChat = true;
    update([chatButtonId]);

    try {
      await handleAsyncOperation(() async {
        // Get or create conversation with patient
        final conversation = await _chatRepository
            .getOrCreatePatientConversation(patientId);

        // Get BaseConversationModel with rich user data
        final baseConversation = await _chatRepository.getConversation(
          conversation.id,
        );

        // Navigate to chat conversation screen
        navigationService.navigateToRoute(
          DoctorChatConversationScreen.chatConversationScreen,
          arguments: {
            'conversationId': conversation.id,
            'conversation': baseConversation,
          },
        );

        // Track analytics
        trackAnalyticsEvent(
          'chat_started_from_patient_detail',
          parameters: {
            'patient_id': patientId,
            'conversation_id': conversation.id,
          },
        );
      });
    } catch (e) {
      // Error is already logged in repository
      // Reset loading state on error
      _isStartingChat = false;
      update([chatButtonId]);
      rethrow;
    } finally {
      // Reset loading state after navigation
      _isStartingChat = false;
      update([chatButtonId]);
    }
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
