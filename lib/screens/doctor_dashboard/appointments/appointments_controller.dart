import '../../../data/base_class/base_controller.dart';
import '../../../data/modules/appointments_repository.dart';
import '../../../data/models/appointment_request.dart';
import '../../../data/models/enums.dart';
import '../../../widgets/app_snackbar.dart';

class DoctorAppointmentsController extends BaseController {
  static const String contentId = 'doctor_appointments_content';
  static const String filtersId = 'appointments_filters';
  static const String listId = 'appointments_list';

  final AppointmentsRepository _appointmentsRepository;

  DoctorAppointmentsController(this._appointmentsRepository);

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Filter state
  int _selectedFilterIndex = 0;
  int get selectedFilterIndex => _selectedFilterIndex;

  // Rejection state
  int? _rejectingIndex;
  int? get rejectingIndex => _rejectingIndex;

  final Map<int, String> _rejectionReasons = {};
  String? rejectionReasons(int index) => _rejectionReasons[index];

  // Appointment requests
  List<AppointmentRequest> _appointmentRequests = [];
  List<AppointmentRequest> get appointmentRequests {
    // Apply filter based on selectedFilterIndex
    var filtered = List<AppointmentRequest>.from(_appointmentRequests);

    switch (_selectedFilterIndex) {
      case 0: // All
        break;
      case 1: // Urgency
        filtered = filtered.where((r) => r.requestStatus == RequestStatus.urgent).toList();
        break;
      case 2: // Date
        // Sort by date (already sorted by repository)
        break;
      case 3: // Newest
        // Sort by created_at descending (already sorted by repository)
        break;
    }

    return filtered;
  }

  /// Load appointment requests from Supabase
  Future<void> loadAppointmentRequests() async {
    await handleAsyncOperation(() async {
      _isLoading = true;
      update([contentId, listId]);

      try {
        // Fetch all appointments (pending, confirmed, completed, cancelled)
        final requests = await _appointmentsRepository.getAppointmentRequests();
        _appointmentRequests = requests;
        update([listId]);
      } finally {
        _isLoading = false;
        update([contentId]);
      }
    });
  }

  /// Refresh appointment requests (for pull-to-refresh)
  Future<void> refreshAppointmentRequests() async {
    await loadAppointmentRequests();
  }

  void onFilterChanged(int index) {
    if (_selectedFilterIndex != index) {
      _selectedFilterIndex = index;
      update([filtersId, listId]);
    }
  }

  Future<void> onAcceptRequest(int index) async {
    final request = appointmentRequests[index];
    await handleAsyncOperation(() async {
      await _appointmentsRepository.approveAppointment(request.appointment.id);
      // Reload requests
      await loadAppointmentRequests();
      AppSnackBar.success(
        title: 'Success',
        message: 'Appointment approved successfully',
      );
    });
  }

  void onRejectRequest(int index) {
    _rejectingIndex = index;
    _rejectionReasons[index] = '';
    update([listId]);
  }

  void onCancelReject(int index) {
    _rejectingIndex = null;
    _rejectionReasons.remove(index);
    update([listId]);
  }

  void onRejectionReasonChanged(int index, String reason) {
    _rejectionReasons[index] = reason;
  }

  Future<void> onConfirmReject(int index) async {
    final reason = _rejectionReasons[index] ?? '';
    if (reason.isEmpty) {
      AppSnackBar.error(
        title: 'Error',
        message: 'Please provide a reason for rejection',
      );
      return;
    }

    final request = appointmentRequests[index];
    await handleAsyncOperation(() async {
      await _appointmentsRepository.rejectAppointment(
        request.appointment.id,
        reason: reason,
      );
      // Reload requests
      await loadAppointmentRequests();
      _rejectingIndex = null;
      _rejectionReasons.remove(index);
      AppSnackBar.success(
        title: 'Success',
        message: 'Appointment rejected',
      );
    });
  }

  @override
  void onInit() {
    super.onInit();
    loadAppointmentRequests();
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
    if (isConnected) {
      loadAppointmentRequests();
    }
  }
}
