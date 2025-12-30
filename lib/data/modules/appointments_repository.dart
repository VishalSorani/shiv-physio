import 'package:shiv_physio_app/data/models/enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_class/base_repository.dart';
import '../models/appointment.dart';
import '../models/appointment_request.dart';
import '../models/available_slot.dart';
import '../models/user.dart' as model;
import '../service/storage_service.dart';
import 'package:get/get.dart';
import 'notification_repository.dart';

/// Repository for managing doctor appointments
class AppointmentsRepository extends BaseRepository {
  final SupabaseClient _supabase;
  final StorageService _storageService;
  NotificationRepository? _notificationRepository;

  AppointmentsRepository({
    required SupabaseClient supabase,
    required StorageService storageService,
    NotificationRepository? notificationRepository,
  }) : _supabase = supabase,
       _storageService = storageService {
    // Get notification repository from DI if not provided
    try {
      _notificationRepository =
          notificationRepository ?? Get.find<NotificationRepository>();
    } catch (e) {
      logW('NotificationRepository not available: $e');
      _notificationRepository = null;
    }
  }

  /// Get current doctor ID from storage
  String? _getDoctorId() {
    final user = _storageService.getUser();
    return user?.id;
  }

  /// Get all appointment requests for the doctor
  /// Filters by status: pending, confirmed, completed, cancelled
  Future<List<AppointmentRequest>> getAppointmentRequests({
    AppointmentStatus? statusFilter,
    int? limit,
  }) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        logW('No doctor ID found in storage');
        return [];
      }

      logD('Fetching appointment requests for doctor: $doctorId');

      // Build query with proper chaining
      dynamic query = _supabase
          .from('appointments')
          .select('''
            *,
            patient:patient_id (
              id,
              full_name,
              avatar_url,
              email,
              phone,
              age,
              is_doctor,
              created_at,
              updated_at
            )
          ''')
          .eq('doctor_id', doctorId);

      // Apply status filter if provided
      if (statusFilter != null) {
        query = query.eq('status', statusFilter.toDb());
      }

      // Order by start_at descending (newest first)
      query = query.order('start_at', ascending: false);

      // Apply limit if provided
      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      if (response.isEmpty) {
        logD('No appointment requests found');
        return [];
      }

      final requests = (response as List)
          .map((json) => AppointmentRequest.fromJson(json))
          .toList();

      logI('Fetched ${requests.length} appointment requests');
      return requests;
    } catch (e) {
      logE('Error fetching appointment requests', error: e);
      handleRepositoryError(e);
    }
  }

  /// Approve an appointment (change status from pending to confirmed)
  Future<void> approveAppointment(String appointmentId) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Approving appointment: $appointmentId');

      final response = await _supabase
          .from('appointments')
          .update({'status': 'confirmed'})
          .eq('id', appointmentId)
          .eq('doctor_id', doctorId)
          .select()
          .single();

      final appointment = Appointment.fromJson(response);

      // Get patient info for notification
      model.User? patient;
      try {
        final patientResponse = await _supabase
            .from('users')
            .select()
            .eq('id', appointment.patientId)
            .maybeSingle();

        if (patientResponse != null) {
          patient = model.User.fromJson(patientResponse);
        }
      } catch (e) {
        logW('Error fetching patient for notification: $e');
      }

      logI('Appointment approved successfully');

      // Send notification
      try {
        if (_notificationRepository != null && patient != null) {
          await _notificationRepository!.sendAppointmentApprovedNotification(
            appointment: appointment,
            patient: patient,
          );
        }
      } catch (e) {
        logE('Error sending appointment approved notification', error: e);
        // Don't throw - notification failure shouldn't break approval
      }
    } catch (e) {
      logE('Error approving appointment', error: e);
      handleRepositoryError(e);
    }
  }

  /// Reject an appointment (change status from pending to cancelled)
  Future<void> rejectAppointment(String appointmentId, {String? reason}) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Rejecting appointment: $appointmentId');

      final response = await _supabase
          .from('appointments')
          .update({
            'status': 'cancelled',
            'cancel_reason': reason,
            'cancelled_by': doctorId,
          })
          .eq('id', appointmentId)
          .eq('doctor_id', doctorId)
          .select()
          .single();

      final appointment = Appointment.fromJson(response);

      // Get patient info for notification
      model.User? patient;
      try {
        final patientResponse = await _supabase
            .from('users')
            .select()
            .eq('id', appointment.patientId)
            .maybeSingle();

        if (patientResponse != null) {
          patient = model.User.fromJson(patientResponse);
        }
      } catch (e) {
        logW('Error fetching patient for notification: $e');
      }

      logI('Appointment rejected successfully');

      // Send notification
      try {
        if (_notificationRepository != null && patient != null) {
          await _notificationRepository!.sendAppointmentRejectedNotification(
            appointment: appointment,
            patient: patient,
            reason: reason,
          );
        }
      } catch (e) {
        logE('Error sending appointment rejected notification', error: e);
        // Don't throw - notification failure shouldn't break rejection
      }
    } catch (e) {
      logE('Error rejecting appointment', error: e);
      handleRepositoryError(e);
    }
  }

  /// Get patient appointments (for patient users)
  /// Uses doctor ID from Supabase function
  Future<List<Appointment>> getPatientAppointments({
    AppointmentStatus? statusFilter,
    int? limit,
  }) async {
    try {
      final user = _storageService.getUser();
      if (user == null) {
        logW('No user found in storage');
        return [];
      }

      final patientId = user.id;

      logD('Fetching appointments for patient: $patientId');

      // Get doctor ID using Supabase function
      final doctorIdResponse = await _supabase.rpc('get_doctor_id');
      final doctorId = doctorIdResponse?.toString();

      if (doctorId == null || doctorId.isEmpty) {
        logW('No doctor ID found');
        return [];
      }

      // Build query - with complex select, build conditionally to include all filters in initial chain
      dynamic query;

      if (statusFilter != null) {
        // Include status filter in initial chain
        query = _supabase
            .from('appointments')
            .select('''
              *,
              doctor:doctor_id (
                id,
                full_name,
                avatar_url,
                email,
                phone
              )
            ''')
            .eq('patient_id', patientId)
            .eq('doctor_id', doctorId)
            .eq('status', statusFilter.toDb());
      } else {
        // Without status filter
        query = _supabase
            .from('appointments')
            .select('''
              *,
              doctor:doctor_id (
                id,
                full_name,
                avatar_url,
                email,
                phone
              )
            ''')
            .eq('patient_id', patientId)
            .eq('doctor_id', doctorId);
      }

      // Apply ordering (after all filters, before limit)
      query = query.order('start_at', ascending: true);

      // Apply limit if provided (must be last)
      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      if (response.isEmpty) {
        logD('No appointments found');
        return [];
      }

      final appointments = (response as List)
          .map((json) => Appointment.fromJson(json))
          .toList();

      logI('Fetched ${appointments.length} appointments for patient');
      return appointments;
    } catch (e) {
      logE('Error fetching patient appointments', error: e);
      handleRepositoryError(e);
    }
  }

  /// Get doctor info for patients
  Future<Map<String, dynamic>?> getDoctorInfo() async {
    try {
      logD('Fetching doctor info for patient');

      // Get doctor ID using Supabase function
      final doctorIdResponse = await _supabase.rpc('get_doctor_id');
      final doctorId = doctorIdResponse?.toString();

      if (doctorId == null || doctorId.isEmpty) {
        logW('No doctor ID found');
        return null;
      }

      // Fetch doctor profile
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', doctorId)
          .eq('is_doctor', true)
          .maybeSingle();

      if (response == null) {
        logD('No doctor profile found');
        return null;
      }

      logI('Doctor info fetched successfully');
      return Map<String, dynamic>.from(response);
    } catch (e) {
      logE('Error fetching doctor info', error: e);
      handleRepositoryError(e);
    }
  }

  /// Get available slots for a specific date
  ///
  /// This method uses the Supabase RPC function `get_available_slots` which:
  /// 1. Checks doctor_availability_windows table for available time windows
  /// 2. Checks doctor_time_off table to exclude time off periods
  /// 3. Checks appointments table to exclude already booked slots (pending/confirmed)
  /// 4. Generates slots based on slot_minutes from clinic_settings (default: 60 minutes / 1 hour)
  /// 5. Only returns slots that are available and not conflicting
  Future<List<AvailableSlot>> getAvailableSlotsForDate(DateTime date) async {
    try {
      logD('Fetching available slots for date: $date');

      // Get doctor ID using Supabase function
      final doctorIdResponse = await _supabase.rpc('get_doctor_id');
      final doctorId = doctorIdResponse?.toString();

      if (doctorId == null || doctorId.isEmpty) {
        logW('No doctor ID found');
        return [];
      }

      // Call the get_available_slots RPC function
      // This RPC automatically:
      // - Checks doctor_availability_windows for available time windows
      //   * Only includes windows where is_active = true
      //   * Matches day_of_week with the selected date
      //   * Uses start_time and end_time from the availability windows
      // - Excludes slots that overlap with doctor_time_off
      // - Excludes slots that conflict with existing appointments (pending/confirmed)
      // - Generates slots based on slot_minutes (default: 60 minutes / 1 hour)
      // - Returns slots in UTC (timestamptz) which need to be converted to local time for display
      final response = await _supabase.rpc(
        'get_available_slots',
        params: {'p_days_ahead': 30, 'p_doctor_id': doctorId},
      );

      if (response == null) {
        logD('No available slots found');
        return [];
      }

      // Parse slots and filter for the specific date
      final allSlots = (response as List)
          .map((json) => AvailableSlot.fromJson(json))
          .toList();

      // Filter slots for the selected date (convert to local time for comparison)
      final selectedDate = DateTime(date.year, date.month, date.day);
      final filteredSlots = allSlots.where((slot) {
        // Convert UTC slot time to local time for date comparison
        final slotLocal = slot.slotStartAt.toLocal();
        final slotDate = DateTime(
          slotLocal.year,
          slotLocal.month,
          slotLocal.day,
        );
        return slotDate.year == selectedDate.year &&
            slotDate.month == selectedDate.month &&
            slotDate.day == selectedDate.day;
      }).toList();

      logI('Fetched ${filteredSlots.length} available slots for date');
      return filteredSlots;
    } catch (e) {
      logE('Error fetching available slots', error: e);
      handleRepositoryError(e);
    }
  }

  /// Create a new appointment request
  Future<Appointment> createAppointment({
    required DateTime startAt,
    required DateTime endAt,
    String? patientNote,
    String? bookedFor,
    String? otherPersonName,
    String? otherPersonPhone,
    int? otherPersonAge,
    String? reason,
  }) async {
    try {
      final user = _storageService.getUser();
      if (user == null) {
        throw Exception('No user found in storage');
      }

      final patientId = user.id;

      // Get doctor ID using Supabase function
      final doctorIdResponse = await _supabase.rpc('get_doctor_id');
      final doctorId = doctorIdResponse?.toString();

      if (doctorId == null || doctorId.isEmpty) {
        throw Exception('No doctor ID found');
      }

      logD('Creating appointment for patient: $patientId');

      final appointmentData = {
        'patient_id': patientId,
        'doctor_id': doctorId,
        'start_at': startAt.toIso8601String(),
        'end_at': endAt.toIso8601String(),
        'status': 'pending',
        'patient_note': patientNote,
        'booked_for': bookedFor ?? 'self',
        'other_person_name': otherPersonName,
        'other_person_phone': otherPersonPhone,
        'other_person_age': otherPersonAge,
        'reason': reason,
      };

      final response = await _supabase
          .from('appointments')
          .insert(appointmentData)
          .select()
          .single();

      final appointment = Appointment.fromJson(response);
      logI('Appointment created successfully: ${appointment.id}');

      // Send notification
      try {
        if (_notificationRepository != null) {
          await _notificationRepository!.sendAppointmentBookedNotification(
            appointment: appointment,
            patient: user,
          );
        }
      } catch (e) {
        logE('Error sending appointment booked notification', error: e);
        // Don't throw - notification failure shouldn't break appointment creation
      }

      return appointment;
    } catch (e) {
      logE('Error creating appointment', error: e);
      handleRepositoryError(e);
    }
  }

  /// Get next upcoming appointment for patient
  Future<Appointment?> getNextAppointment() async {
    try {
      final appointments = await getPatientAppointments(
        statusFilter: AppointmentStatus.confirmed,
        limit: 1,
      );

      if (appointments.isEmpty) {
        return null;
      }

      final now = DateTime.now();
      final upcoming = appointments
          .where((apt) => apt.startAt.isAfter(now))
          .toList();

      if (upcoming.isEmpty) {
        return null;
      }

      // Return the earliest upcoming appointment
      upcoming.sort((a, b) => a.startAt.compareTo(b.startAt));
      return upcoming.first;
    } catch (e) {
      logE('Error fetching next appointment', error: e);
      return null;
    }
  }

  /// Cancel an appointment
  Future<Appointment> cancelAppointment({
    required String appointmentId,
    String? cancelReason,
  }) async {
    try {
      final user = _storageService.getUser();
      if (user == null) {
        throw Exception('No user found in storage');
      }

      final userId = user.id;

      logD('Cancelling appointment: $appointmentId');

      final updateData = {
        'status': AppointmentStatus.cancelled.toDb(),
        'cancelled_by': userId,
        'cancel_reason': cancelReason,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      final response = await _supabase
          .from('appointments')
          .update(updateData)
          .eq('id', appointmentId)
          .select()
          .single();

      logI('Appointment cancelled successfully: $appointmentId');
      final appointment = Appointment.fromJson(response);

      // Send notification
      try {
        if (_notificationRepository != null) {
          await _notificationRepository!.sendAppointmentCancelledNotification(
            appointment: appointment,
            cancelledBy: user,
            reason: cancelReason,
          );
        }
      } catch (e) {
        logE('Error sending appointment cancelled notification', error: e);
        // Don't throw - notification failure shouldn't break cancellation
      }

      return appointment;
    } catch (e) {
      logE('Error cancelling appointment', error: e);
      handleRepositoryError(e);
    }
  }
}
