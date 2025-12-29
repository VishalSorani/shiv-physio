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

  // Date filter
  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  // Rejection state
  int? _rejectingIndex;
  int? get rejectingIndex => _rejectingIndex;

  final Map<int, String> _rejectionReasons = {};
  String? rejectionReasons(int index) => _rejectionReasons[index];

  // Loading states for buttons
  int? _acceptingIndex;
  int? get acceptingIndex => _acceptingIndex;

  int? _confirmingRejectIndex;
  int? get confirmingRejectIndex => _confirmingRejectIndex;

  // Appointment requests
  List<AppointmentRequest> _appointmentRequests = [];
  List<AppointmentRequest> get appointmentRequests {
    // Apply filter based on selectedFilterIndex
    var filtered = List<AppointmentRequest>.from(_appointmentRequests);

    switch (_selectedFilterIndex) {
      case 0: // All
        // Show all appointments
        break;
      case 1: // Accepted (Confirmed)
        filtered = filtered.where((r) => 
          r.appointment.status == AppointmentStatus.confirmed
        ).toList();
        break;
      case 2: // Rejected (Cancelled by doctor)
        filtered = filtered.where((r) => 
          r.appointment.status == AppointmentStatus.cancelled &&
          r.appointment.cancelledBy != null
        ).toList();
        break;
      case 3: // Date filter
        if (_selectedDate != null) {
          filtered = filtered.where((r) {
            final appointmentDate = r.appointment.startAt.toLocal();
            return appointmentDate.year == _selectedDate!.year &&
                   appointmentDate.month == _selectedDate!.month &&
                   appointmentDate.day == _selectedDate!.day;
          }).toList();
        }
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
      if (index != 3) {
        // Clear date filter if not selecting date filter
        _selectedDate = null;
      }
      update([filtersId, listId]);
    }
  }

  void onDateSelected(DateTime? date) {
    _selectedDate = date;
    update([filtersId, listId]);
  }

  void clearDateFilter() {
    _selectedDate = null;
    update([filtersId, listId]);
  }

  Future<void> onAcceptRequest(int index) async {
    final request = appointmentRequests[index];
    _acceptingIndex = index;
    update([listId]);
    
    try {
      await handleAsyncOperation(() async {
        await _appointmentsRepository.approveAppointment(request.appointment.id);
        // Reload requests to update the list
        await loadAppointmentRequests();
        AppSnackBar.success(
          title: 'Success',
          message: 'Appointment approved successfully',
        );
      });
    } finally {
      _acceptingIndex = null;
      update([listId]);
    }
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
    _confirmingRejectIndex = index;
    update([listId]);
    
    try {
      await handleAsyncOperation(() async {
        await _appointmentsRepository.rejectAppointment(
          request.appointment.id,
          reason: reason,
        );
        // Reload requests to update the list
        await loadAppointmentRequests();
        _rejectingIndex = null;
        _rejectionReasons.remove(index);
        AppSnackBar.success(
          title: 'Success',
          message: 'Appointment rejected',
        );
      });
    } finally {
      _confirmingRejectIndex = null;
      update([listId]);
    }
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
