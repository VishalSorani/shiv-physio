import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_class/base_repository.dart';
import '../models/appointment.dart';
import '../models/appointment_request.dart';
import '../service/storage_service.dart';

/// Repository for doctor home screen data
class DoctorHomeRepository extends BaseRepository {
  final SupabaseClient _supabase;
  final StorageService _storageService;

  DoctorHomeRepository({
    required SupabaseClient supabase,
    required StorageService storageService,
  }) : _supabase = supabase,
       _storageService = storageService;

  /// Get current doctor ID from storage
  String? _getDoctorId() {
    final user = _storageService.getUser();
    return user?.id;
  }

  /// Get doctor profile info
  Future<Map<String, dynamic>?> getDoctorInfo() async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        logW('No doctor ID found in storage');
        return null;
      }

      logD('Fetching doctor info for: $doctorId');

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
      rethrow;
    }
  }

  /// Get pending appointment requests (status = 'pending')
  /// Returns list of AppointmentRequest models
  Future<List<AppointmentRequest>> getPendingRequests({int limit = 5}) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        logW('No doctor ID found in storage');
        return [];
      }

      logD('Fetching pending requests for doctor: $doctorId');

      final response = await _supabase
          .from('appointments')
          .select('''
            *,
            patient:patient_id (
              id,
              full_name,
              avatar_url,
              email,
              phone
            )
          ''')
          .eq('doctor_id', doctorId)
          .eq('status', 'pending')
          .order('start_at', ascending: true)
          .limit(limit);

      if (response.isEmpty) {
        logD('No pending requests found');
        return [];
      }

      final requests = (response as List)
          .map((json) => AppointmentRequest.fromJson(json))
          .toList();

      logI('Fetched ${requests.length} pending requests');
      return requests;
    } catch (e) {
      logE('Error fetching pending requests', error: e);
      handleRepositoryError(e);
      rethrow;
    }
  }

  /// Get today's schedule (confirmed and pending appointments for today)
  /// Returns list of AppointmentRequest models
  Future<List<AppointmentRequest>> getTodaysSchedule() async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        logW('No doctor ID found in storage');
        return [];
      }

      logD('Fetching today\'s schedule for doctor: $doctorId');

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('appointments')
          .select('''
            *,
            patient:patient_id (
              id,
              full_name,
              avatar_url,
              email,
              phone
            )
          ''')
          .eq('doctor_id', doctorId)
          .or('status.eq.pending,status.eq.confirmed')
          .gte('start_at', startOfDay.toIso8601String())
          .lt('start_at', endOfDay.toIso8601String())
          .order('start_at', ascending: true);

      if (response.isEmpty) {
        logD('No appointments found for today');
        return [];
      }

      final requests = (response as List)
          .map((json) => AppointmentRequest.fromJson(json))
          .toList();

      logI('Fetched ${requests.length} appointments for today');
      return requests;
    } catch (e) {
      logE('Error fetching today\'s schedule', error: e);
      handleRepositoryError(e);
      rethrow;
    }
  }

  /// Get analytics data for the current month
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        logW('No doctor ID found in storage');
        return {
          'totalPatients': 0,
          'totalAppointments': 0,
          'completedAppointments': 0,
          'completionRate': 0.0,
        };
      }

      logD('Fetching analytics for doctor: $doctorId');

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1);

      // Get total unique patients
      final patientsResponse = await _supabase
          .from('appointments')
          .select('patient_id')
          .eq('doctor_id', doctorId)
          .gte('created_at', startOfMonth.toIso8601String())
          .lt('created_at', endOfMonth.toIso8601String());

      final uniquePatients = <String>{};
      if (patientsResponse.isNotEmpty) {
        for (final item in patientsResponse) {
          final patientId = item['patient_id']?.toString();
          if (patientId != null) {
            uniquePatients.add(patientId);
          }
        }
      }

      // Get total appointments this month
      final appointmentsResponse = await _supabase
          .from('appointments')
          .select('id, status')
          .eq('doctor_id', doctorId)
          .gte('created_at', startOfMonth.toIso8601String())
          .lt('created_at', endOfMonth.toIso8601String());

      final totalAppointments = appointmentsResponse.length;
      final completedAppointments = appointmentsResponse
          .where((a) => a['status'] == 'completed')
          .length;

      final completionRate = totalAppointments > 0
          ? (completedAppointments / totalAppointments) * 100
          : 0.0;

      logI(
        'Analytics fetched: $uniquePatients.length patients, $totalAppointments appointments',
      );

      return {
        'totalPatients': uniquePatients.length,
        'totalAppointments': totalAppointments,
        'completedAppointments': completedAppointments,
        'completionRate': completionRate,
      };
    } catch (e) {
      logE('Error fetching analytics', error: e);
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

  /// Decline an appointment (change status from pending to cancelled)
  Future<void> declineAppointment(
    String appointmentId, {
    String? reason,
  }) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Declining appointment: $appointmentId');

      await _supabase
          .from('appointments')
          .update({
            'status': 'cancelled',
            'cancel_reason': reason,
            'cancelled_by': doctorId,
          })
          .eq('id', appointmentId)
          .eq('doctor_id', doctorId);

      logI('Appointment declined successfully');
    } catch (e) {
      logE('Error declining appointment', error: e);
      handleRepositoryError(e);
      rethrow;
    }
  }
}
