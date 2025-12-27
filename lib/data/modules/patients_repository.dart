import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_class/base_repository.dart';
import '../models/patient_display.dart';
import '../models/appointment.dart';
import '../models/user.dart' as app_models;
import '../service/storage_service.dart';

/// Repository for managing patient data
class PatientsRepository extends BaseRepository {
  final SupabaseClient _supabase;
  final StorageService _storageService;

  PatientsRepository({
    required SupabaseClient supabase,
    required StorageService storageService,
  }) : _supabase = supabase,
       _storageService = storageService;

  /// Get current doctor ID from storage
  String? _getDoctorId() {
    final user = _storageService.getUser();
    return user?.id;
  }

  /// Get all patients (non-doctor users) with pagination
  /// Returns list of PatientDisplay models with appointment information
  Future<List<PatientDisplay>> getPatients({
    int page = 1,
    int limit = 10,
    String? searchQuery,
  }) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        logW('No doctor ID found in storage');
        return [];
      }

      logD('Fetching all patients, page: $page, limit: $limit');

      // Get all non-doctor users
      dynamic patientsQuery = _supabase
          .from('users')
          .select('*')
          .eq('is_doctor', false);

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        patientsQuery = patientsQuery.or(
          'full_name.ilike.%$searchQuery%,id.ilike.%$searchQuery%',
        );
      }

      // Order by full_name
      patientsQuery = patientsQuery.order('full_name', ascending: true);

      // Apply pagination
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      patientsQuery = patientsQuery.range(from, to);

      final patientsResponse = await patientsQuery;

      if (patientsResponse.isEmpty) {
        logD('No patients found');
        return [];
      }

      // For each patient, get their appointments
      final patients = <PatientDisplay>[];
      for (final patientJson in patientsResponse as List) {
        final patient = app_models.User.fromJson(patientJson);
        final patientId = patient.id;

        // Get next appointment (upcoming confirmed or pending)
        final nextAppointmentResponse = await _supabase
            .from('appointments')
            .select('*')
            .eq('doctor_id', doctorId)
            .eq('patient_id', patientId)
            .or('status.eq.pending,status.eq.confirmed')
            .gte('start_at', DateTime.now().toIso8601String())
            .order('start_at', ascending: true)
            .limit(1)
            .maybeSingle();

        Appointment? nextAppointment;
        if (nextAppointmentResponse != null) {
          nextAppointment = Appointment.fromJson(nextAppointmentResponse);
        }

        // Get last appointment (completed or cancelled)
        final lastAppointmentResponse = await _supabase
            .from('appointments')
            .select('*')
            .eq('doctor_id', doctorId)
            .eq('patient_id', patientId)
            .or('status.eq.completed,status.eq.cancelled')
            .order('start_at', ascending: false)
            .limit(1)
            .maybeSingle();

        Appointment? lastAppointment;
        if (lastAppointmentResponse != null) {
          lastAppointment = Appointment.fromJson(lastAppointmentResponse);
        }

        // Get primary condition from most recent appointment's patient note
        String? condition;
        if (nextAppointment?.patientNote != null) {
          condition = _extractCondition(nextAppointment!.patientNote!);
        } else if (lastAppointment?.patientNote != null) {
          condition = _extractCondition(lastAppointment!.patientNote!);
        }

        // Determine status
        String? status;
        if (nextAppointment != null) {
          if (nextAppointment.status.toString().contains('pending')) {
            status = 'pending_review';
          } else {
            status = 'active';
          }
        } else if (lastAppointment != null) {
          status = 'completed';
        }

        // Calculate progress (mock for now - can be enhanced with actual treatment plan data)
        int? progressPercentage;
        if (status == 'active') {
          // Mock progress calculation - can be replaced with actual treatment plan progress
          progressPercentage =
              60 + (patient.id.hashCode % 40); // Random between 60-100
        } else if (status == 'pending_review') {
          progressPercentage =
              40 + (patient.id.hashCode % 20); // Random between 40-60
        }

        patients.add(
          PatientDisplay(
            patient: patient,
            nextAppointment: nextAppointment,
            lastAppointment: lastAppointment,
            condition: condition,
            progressPercentage: progressPercentage,
            status: status,
          ),
        );
      }

      logI('Fetched ${patients.length} patients');
      return patients;
    } catch (e) {
      logE('Error fetching patients', error: e);
      handleRepositoryError(e);
      rethrow;
    }
  }

  /// Get total count of patients (for pagination)
  Future<int> getPatientsCount({String? searchQuery}) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        return 0;
      }

      // Get count of all non-doctor users
      dynamic countQuery = _supabase
          .from('users')
          .select('id')
          .eq('is_doctor', false);

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        countQuery = countQuery.or(
          'full_name.ilike.%$searchQuery%,id.ilike.%$searchQuery%',
        );
      }

      final response = await countQuery;
      // Count the results manually since we can't use count option with or()
      return (response as List).length;
    } catch (e) {
      logE('Error getting patients count', error: e);
      return 0;
    }
  }

  /// Get patient details by ID
  Future<app_models.User?> getPatientById(String patientId) async {
    try {
      logD('Fetching patient details for: $patientId');

      final response = await _supabase
          .from('users')
          .select('*')
          .eq('id', patientId)
          .eq('is_doctor', false)
          .maybeSingle();

      if (response == null) {
        logD('Patient not found');
        return null;
      }

      final patient = app_models.User.fromJson(response);
      logI('Patient details fetched successfully');
      return patient;
    } catch (e) {
      logE('Error fetching patient details', error: e);
      handleRepositoryError(e);
      rethrow;
    }
  }

  /// Get all appointments for a specific patient with the current doctor
  Future<List<Appointment>> getPatientAppointments(String patientId) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        logW('No doctor ID found in storage');
        return [];
      }

      logD('Fetching appointments for patient: $patientId, doctor: $doctorId');

      final response = await _supabase
          .from('appointments')
          .select('*')
          .eq('doctor_id', doctorId)
          .eq('patient_id', patientId)
          .order('start_at', ascending: false);

      if (response.isEmpty) {
        logD('No appointments found');
        return [];
      }

      final appointments = (response as List)
          .map((json) => Appointment.fromJson(json))
          .toList();

      logI('Fetched ${appointments.length} appointments');
      return appointments;
    } catch (e) {
      logE('Error fetching patient appointments', error: e);
      handleRepositoryError(e);
      rethrow;
    }
  }

  /// Extract condition from patient note
  String? _extractCondition(String note) {
    // Simple extraction - look for common condition keywords
    final lowerNote = note.toLowerCase();
    final conditions = [
      'acl',
      'lower back pain',
      'frozen shoulder',
      'sciatica',
      'knee pain',
      'shoulder pain',
      'neck pain',
      'post-op',
    ];

    for (final condition in conditions) {
      if (lowerNote.contains(condition)) {
        // Capitalize first letter of each word
        return condition
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
      }
    }

    // If no specific condition found, return first few words of note
    final words = note.split(' ');
    if (words.length > 3) {
      return '${words[0]} ${words[1]} ${words[2]}...';
    }
    return note.length > 30 ? '${note.substring(0, 30)}...' : note;
  }
}
