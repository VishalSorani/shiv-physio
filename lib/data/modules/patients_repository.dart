import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_class/base_repository.dart';
import '../models/patient_display.dart';
import '../models/appointment.dart';
import '../models/treatment_plan.dart';
import '../models/user.dart' as app_models;
import '../service/storage_service.dart';

/// Repository for managing patient data
class PatientsRepository extends BaseRepository {
  final SupabaseClient _supabase;
  final StorageService _storageService;
  final Random _random = Random();

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

  /// Get all treatment plans for a specific patient
  Future<List<TreatmentPlan>> getPatientTreatmentPlans(String patientId) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        logW('No doctor ID found in storage');
        return [];
      }

      logD('Fetching treatment plans for patient: $patientId');

      final response = await _supabase
          .from('treatment_plans')
          .select('*')
          .eq('patient_id', patientId)
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        logD('No treatment plans found');
        return [];
      }

      final treatmentPlans = (response as List)
          .map((json) => TreatmentPlan.fromJson(json))
          .toList();

      logI('Fetched ${treatmentPlans.length} treatment plans');
      return treatmentPlans;
    } catch (e) {
      logE('Error fetching treatment plans', error: e);
      handleRepositoryError(e);
    }
  }

  /// Create a new treatment plan
  Future<TreatmentPlan> createTreatmentPlan({
    required String patientId,
    String? diagnosis,
    List<String>? medicalConditions,
    String? treatmentGoals,
    required String treatmentPlan,
    int? durationWeeks,
    int? frequencyPerWeek,
    String? notes,
  }) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Creating treatment plan for patient: $patientId');

      final response = await _supabase
          .from('treatment_plans')
          .insert({
            'patient_id': patientId,
            'doctor_id': doctorId,
            'diagnosis': diagnosis,
            'medical_conditions': medicalConditions,
            'treatment_goals': treatmentGoals,
            'treatment_plan': treatmentPlan,
            'duration_weeks': durationWeeks,
            'frequency_per_week': frequencyPerWeek,
            'notes': notes,
            'status': 'active',
          })
          .select()
          .single();

      final createdPlan = TreatmentPlan.fromJson(response);
      logI('Treatment plan created successfully: ${createdPlan.id}');
      return createdPlan;
    } catch (e) {
      logE('Error creating treatment plan', error: e);
      handleRepositoryError(e);
    }
  }

  /// Update an existing treatment plan
  Future<TreatmentPlan> updateTreatmentPlan({
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
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Updating treatment plan: $treatmentPlanId');

      final updateData = <String, dynamic>{};
      if (diagnosis != null) updateData['diagnosis'] = diagnosis;
      if (medicalConditions != null)
        updateData['medical_conditions'] = medicalConditions;
      if (treatmentGoals != null)
        updateData['treatment_goals'] = treatmentGoals;
      if (treatmentPlan != null) updateData['treatment_plan'] = treatmentPlan;
      if (durationWeeks != null) updateData['duration_weeks'] = durationWeeks;
      if (frequencyPerWeek != null)
        updateData['frequency_per_week'] = frequencyPerWeek;
      if (notes != null) updateData['notes'] = notes;
      if (status != null) updateData['status'] = status;

      final response = await _supabase
          .from('treatment_plans')
          .update(updateData)
          .eq('id', treatmentPlanId)
          .eq('doctor_id', doctorId)
          .select()
          .single();

      final updatedPlan = TreatmentPlan.fromJson(response);
      logI('Treatment plan updated successfully: ${updatedPlan.id}');
      return updatedPlan;
    } catch (e) {
      logE('Error updating treatment plan', error: e);
      handleRepositoryError(e);
    }
  }

  /// Delete a treatment plan
  Future<void> deleteTreatmentPlan(String treatmentPlanId) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Deleting treatment plan: $treatmentPlanId');

      await _supabase
          .from('treatment_plans')
          .delete()
          .eq('id', treatmentPlanId)
          .eq('doctor_id', doctorId);

      logI('Treatment plan deleted successfully');
    } catch (e) {
      logE('Error deleting treatment plan', error: e);
      handleRepositoryError(e);
    }
  }

  /// Check if email already exists in users table
  Future<bool> emailExists(String email, {String? excludeUserId}) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('email', email.toLowerCase().trim())
          .limit(1);

      final results = response as List;
      if (results.isEmpty) {
        return false;
      }

      // If excludeUserId is provided, check if the found user is different
      if (excludeUserId != null) {
        final foundUserId = results.first['id'] as String?;
        return foundUserId != excludeUserId;
      }

      return true;
    } catch (e) {
      logE('Error checking email existence', error: e);
      return false;
    }
  }

  /// Check if phone already exists in users table
  Future<bool> phoneExists(String phone, {String? excludeUserId}) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('phone', phone.trim())
          .limit(1);

      final results = response as List;
      if (results.isEmpty) {
        return false;
      }

      // If excludeUserId is provided, check if the found user is different
      if (excludeUserId != null) {
        final foundUserId = results.first['id'] as String?;
        return foundUserId != excludeUserId;
      }

      return true;
    } catch (e) {
      logE('Error checking phone existence', error: e);
      return false;
    }
  }

  /// Create a new patient using Firebase anonymous authentication
  /// Returns the created User object
  Future<app_models.User> createPatient({
    required String fullName,
    String? email,
    String? phone,
    int? age,
    String? gender,
    String? address,
  }) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Creating new patient: $fullName');

      // Validate email uniqueness if provided
      if (email != null && email.trim().isNotEmpty) {
        final emailExistsResult = await emailExists(email);
        if (emailExistsResult) {
          throw Exception(
            'Email already exists. Please use a different email.',
          );
        }
      }

      // Validate phone uniqueness if provided
      if (phone != null && phone.trim().isNotEmpty) {
        final phoneExistsResult = await phoneExists(phone);
        if (phoneExistsResult) {
          throw Exception(
            'Phone number already exists. Please use a different phone number.',
          );
        }
      }

      // 1. Generate a unique random ID (similar to Firebase format)
      final patientId = await _generateUniquePatientId();
      logD('Generated unique patient ID: $patientId');

      // 2. Create user in Supabase
      final now = DateTime.now().toIso8601String();
      final userData = <String, dynamic>{
        'id': patientId,
        'is_doctor': false,
        'full_name': fullName,
        'email': email?.trim().toLowerCase(),
        'phone': phone?.trim(),
        'age': age,
        'gender': gender,
        'address': address,
        'created_at': now,
        'updated_at': now,
      };

      final response = await _supabase
          .from('users')
          .insert(userData)
          .select()
          .single();

      final createdPatient = app_models.User.fromJson(response);
      logI('Patient created successfully: ${createdPatient.id}');

      return createdPatient;
    } catch (e) {
      logE('Error creating patient', error: e);
      handleRepositoryError(e);
    }
  }

  /// Update patient information
  Future<app_models.User> updatePatient({
    required String patientId,
    String? fullName,
    String? email,
    String? phone,
    int? age,
    String? gender,
    String? address,
  }) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Updating patient: $patientId');

      // Validate email uniqueness if provided and changed
      if (email != null && email.trim().isNotEmpty) {
        final emailExistsResult = await emailExists(
          email,
          excludeUserId: patientId,
        );
        if (emailExistsResult) {
          throw Exception(
            'Email already exists. Please use a different email.',
          );
        }
      }

      // Validate phone uniqueness if provided and changed
      if (phone != null && phone.trim().isNotEmpty) {
        final phoneExistsResult = await phoneExists(
          phone,
          excludeUserId: patientId,
        );
        if (phoneExistsResult) {
          throw Exception(
            'Phone number already exists. Please use a different phone number.',
          );
        }
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (email != null) updateData['email'] = email.trim().toLowerCase();
      if (phone != null) updateData['phone'] = phone.trim();
      if (age != null) updateData['age'] = age;
      if (gender != null) updateData['gender'] = gender;
      if (address != null) updateData['address'] = address;

      final response = await _supabase
          .from('users')
          .update(updateData)
          .eq('id', patientId)
          .eq('is_doctor', false)
          .select()
          .single();

      final updatedPatient = app_models.User.fromJson(response);
      logI('Patient updated successfully: ${updatedPatient.id}');

      return updatedPatient;
    } catch (e) {
      logE('Error updating patient', error: e);
      handleRepositoryError(e);
    }
  }

  /// Check if a user ID already exists in the users table
  Future<bool> userIdExists(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('id', userId)
          .limit(1);

      final results = response as List;
      return results.isNotEmpty;
    } catch (e) {
      logE('Error checking user ID existence', error: e);
      return false;
    }
  }

  /// Generate a random ID similar to Firebase UID format
  /// Format: 28 characters alphanumeric (similar to Firebase's 28-char UIDs)
  String _generateRandomId() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final buffer = StringBuffer();

    // Generate 28 characters (Firebase UIDs are typically 28 chars)
    for (int i = 0; i < 28; i++) {
      buffer.write(chars[_random.nextInt(chars.length)]);
    }

    return buffer.toString();
  }

  /// Generate a unique patient ID that doesn't exist in the users table
  /// Retries up to 10 times if generated ID already exists
  Future<String> _generateUniquePatientId() async {
    const maxRetries = 10;
    int attempts = 0;

    while (attempts < maxRetries) {
      final generatedId = _generateRandomId();
      final exists = await userIdExists(generatedId);

      if (!exists) {
        logD('Generated unique patient ID after ${attempts + 1} attempt(s)');
        return generatedId;
      }

      attempts++;
      logW(
        'Generated ID already exists, retrying... (attempt $attempts/$maxRetries)',
      );
    }

    // If we've exhausted retries, throw an error
    throw Exception(
      'Failed to generate unique patient ID after $maxRetries attempts. Please try again.',
    );
  }
}
