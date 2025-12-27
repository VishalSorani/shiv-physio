import 'package:shiv_physio_app/data/models/enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_class/base_repository.dart';
import '../models/appointment_request.dart';
import '../service/storage_service.dart';

/// Repository for managing doctor appointments
class AppointmentsRepository extends BaseRepository {
  final SupabaseClient _supabase;
  final StorageService _storageService;

  AppointmentsRepository({
    required SupabaseClient supabase,
    required StorageService storageService,
  }) : _supabase = supabase,
       _storageService = storageService;

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
      rethrow;
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

      await _supabase
          .from('appointments')
          .update({'status': 'confirmed'})
          .eq('id', appointmentId)
          .eq('doctor_id', doctorId);

      logI('Appointment approved successfully');
    } catch (e) {
      logE('Error approving appointment', error: e);
      handleRepositoryError(e);
      rethrow;
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

      await _supabase
          .from('appointments')
          .update({
            'status': 'cancelled',
            'cancel_reason': reason,
            'cancelled_by': doctorId,
          })
          .eq('id', appointmentId)
          .eq('doctor_id', doctorId);

      logI('Appointment rejected successfully');
    } catch (e) {
      logE('Error rejecting appointment', error: e);
      handleRepositoryError(e);
      rethrow;
    }
  }
}
