import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/models/available_slot.dart';
import '../../../data/modules/appointments_repository.dart';
import '../../../widgets/app_snackbar.dart';
import '../appointment_confirmation/appointment_confirmation_screen.dart';

class BookAppointmentController extends BaseController {
  static const String calendarId = 'calendar';
  static const String timeSlotsId = 'time_slots';
  static const String doctorInfoId = 'doctor_info';
  static const String buttonId = 'book_button';
  static const String bookingFormId = 'booking_form';

  final AppointmentsRepository _appointmentsRepository;

  BookAppointmentController(this._appointmentsRepository);

  // Doctor info
  Map<String, dynamic>? _doctorInfo;
  Map<String, dynamic>? get doctorInfo => _doctorInfo;

  String get doctorName =>
      _doctorInfo?['full_name']?.toString() ?? 'Dr. Pradip Chauhan';
  String get doctorSpecialization =>
      _doctorInfo?['specializations']?.toString() ??
      _doctorInfo?['title']?.toString() ??
      'Physiotherapist';
  String? get doctorAvatarUrl => _doctorInfo?['avatar_url']?.toString();

  // Calendar state
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  DateTime _currentMonth = DateTime.now();
  DateTime get currentMonth => _currentMonth;

  String get currentMonthDisplay =>
      DateFormat('MMMM yyyy').format(_currentMonth);
  String get currentMonthShort => DateFormat('MMM yyyy').format(_currentMonth);

  // Time slots
  List<AvailableSlot> _availableSlots = [];
  List<AvailableSlot> get availableSlots => _availableSlots;

  DateTime? _selectedTimeSlot;
  DateTime? get selectedTimeSlot => _selectedTimeSlot;

  bool _isLoadingSlots = false;
  bool get isLoadingSlots => _isLoadingSlots;

  bool _isBooking = false;
  bool get isBooking => _isBooking;

  // Booking form state
  String _bookedFor = 'self'; // 'self' or 'other'
  String get bookedFor => _bookedFor;
  bool get isBookingForOther => _bookedFor == 'other';

  // Other person details (only used when booking for other)
  final TextEditingController _otherPersonNameController =
      TextEditingController();
  final TextEditingController _otherPersonPhoneController =
      TextEditingController();
  final TextEditingController _otherPersonAgeController =
      TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  TextEditingController get otherPersonNameController =>
      _otherPersonNameController;
  TextEditingController get otherPersonPhoneController =>
      _otherPersonPhoneController;
  TextEditingController get otherPersonAgeController =>
      _otherPersonAgeController;
  TextEditingController get reasonController => _reasonController;

  bool get canBook {
    if (_selectedTimeSlot == null || _isBooking) return false;
    if (_bookedFor == 'other') {
      // Validate other person details
      return _otherPersonNameController.text.trim().isNotEmpty &&
          _otherPersonPhoneController.text.trim().isNotEmpty;
    }
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    _loadDoctorInfo();
    _loadAvailableSlots();
  }

  @override
  void onClose() {
    _otherPersonNameController.dispose();
    _otherPersonPhoneController.dispose();
    _otherPersonAgeController.dispose();
    _reasonController.dispose();
    super.onClose();
  }

  Future<void> _loadDoctorInfo() async {
    try {
      _doctorInfo = await _appointmentsRepository.getDoctorInfo();
      update([doctorInfoId]);
    } catch (e) {
      // Error handled by repository
    }
  }

  Future<void> _loadAvailableSlots() async {
    await handleAsyncOperation(() async {
      _isLoadingSlots = true;
      update([timeSlotsId]);

      try {
        _availableSlots = await _appointmentsRepository
            .getAvailableSlotsForDate(_selectedDate);
        update([timeSlotsId]);
      } finally {
        _isLoadingSlots = false;
        update([timeSlotsId]);
      }
    });
  }

  void onPreviousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    update([calendarId]);
  }

  void onNextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    update([calendarId]);
  }

  void onDateSelected(DateTime date) {
    // Don't allow past dates
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDateOnly = DateTime(date.year, date.month, date.day);

    if (selectedDateOnly.isBefore(todayDate)) {
      AppSnackBar.error(
        title: 'Invalid Date',
        message: 'Cannot select past dates',
      );
      return;
    }

    _selectedDate = date;
    _selectedTimeSlot = null; // Reset time slot selection
    update([calendarId, timeSlotsId]);
    _loadAvailableSlots();
  }

  void onTimeSlotSelected(DateTime slotStart) {
    HapticFeedback.lightImpact();
    _selectedTimeSlot = slotStart;
    update([timeSlotsId, buttonId]);
  }

  void onBookedForChanged(String value) {
    HapticFeedback.lightImpact();
    _bookedFor = value;
    update([bookingFormId, buttonId]);
  }

  bool isDateSelected(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  bool isDateDisabled(DateTime date) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.isBefore(todayDate);
  }

  bool isTimeSlotBooked(DateTime slotStart) {
    // All slots shown are from available slots, so none are booked
    // This method is kept for future use if we need to show all slots
    return false;
  }

  bool isTimeSlotSelected(DateTime slotStart) {
    if (_selectedTimeSlot == null) return false;
    // Compare in local time
    final selectedLocal = _selectedTimeSlot!.toLocal();
    final slotLocal = slotStart.toLocal();
    return selectedLocal.year == slotLocal.year &&
        selectedLocal.month == slotLocal.month &&
        selectedLocal.day == slotLocal.day &&
        selectedLocal.hour == slotLocal.hour &&
        selectedLocal.minute == slotLocal.minute;
  }

  List<DateTime> getTimeSlotsForDate() {
    // Group slots by time of day
    final morningSlots = <DateTime>[];
    final afternoonSlots = <DateTime>[];
    final eveningSlots = <DateTime>[];

    for (final slot in _availableSlots) {
      // Convert UTC time to local time
      final localStartTime = slot.slotStartAt.toLocal();
      
      // Extract hour and minute from local time
      final hour = localStartTime.hour;
      final minute = localStartTime.minute;
      
      // Create slot time in local timezone for the selected date
      final slotTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
        minute,
      );

      if (hour < 12) {
        morningSlots.add(slotTime);
      } else if (hour < 17) {
        afternoonSlots.add(slotTime);
      } else {
        eveningSlots.add(slotTime);
      }
    }

    return [...morningSlots, ...afternoonSlots, ...eveningSlots];
  }

  String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  Future<void> onBookAppointment() async {
    if (_selectedTimeSlot == null) {
      AppSnackBar.error(
        title: 'Validation Error',
        message: 'Please select a time slot',
      );
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      AppSnackBar.error(
        title: 'Validation Error',
        message: 'Please provide a reason for the appointment',
      );
      return;
    }

    if (_bookedFor == 'other') {
      if (_otherPersonNameController.text.trim().isEmpty) {
        AppSnackBar.error(
          title: 'Validation Error',
          message: 'Please enter the person\'s name',
        );
        return;
      }
      if (_otherPersonPhoneController.text.trim().isEmpty) {
        AppSnackBar.error(
          title: 'Validation Error',
          message: 'Please enter the person\'s phone number',
        );
        return;
      }
    }

    await HapticFeedback.lightImpact();

    _isBooking = true;
    update([buttonId]);

    try {
      await handleAsyncOperation(() async {
        // Convert local time to UTC for database storage
        // The selected time slot is in local time, but database expects UTC
        final startAtUtc = _selectedTimeSlot!.toUtc();
        
        // Calculate end time (each slot is 1 hour / 60 minutes)
        final endTimeUtc = startAtUtc.add(const Duration(hours: 1));

        final appointment = await _appointmentsRepository.createAppointment(
          startAt: startAtUtc,
          endAt: endTimeUtc,
          bookedFor: _bookedFor,
          otherPersonName: _bookedFor == 'other'
              ? _otherPersonNameController.text.trim()
              : null,
          otherPersonPhone: _bookedFor == 'other'
              ? _otherPersonPhoneController.text.trim()
              : null,
          otherPersonAge:
              _bookedFor == 'other' &&
                  _otherPersonAgeController.text.trim().isNotEmpty
              ? int.tryParse(_otherPersonAgeController.text.trim())
              : null,
          reason: _reasonController.text.trim(),
        );

        // Navigate to confirmation screen
        Get.offAllNamed(
          AppointmentConfirmationScreen.appointmentConfirmationScreen,
          arguments: appointment,
        );
      });
    } finally {
      _isBooking = false;
      update([buttonId]);
    }
  }

  void onBack() {
    navigationService.goBack();
  }

  @override
  void handleNetworkChange(bool isConnected) {
    handleNetworkChangeDefault(isConnected);
    if (isConnected) {
      _loadAvailableSlots();
    }
  }
}
