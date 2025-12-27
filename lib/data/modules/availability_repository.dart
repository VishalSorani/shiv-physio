import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_class/base_repository.dart';
import '../models/doctor_availability_window.dart';
import '../models/doctor_time_off.dart';
import '../service/storage_service.dart';

/// Repository for managing doctor availability windows and time off
class AvailabilityRepository extends BaseRepository {
  final SupabaseClient _supabase;
  final StorageService _storageService;

  AvailabilityRepository({
    required SupabaseClient supabase,
    required StorageService storageService,
  })  : _supabase = supabase,
        _storageService = storageService;

  /// Get current doctor ID from storage
  String? _getDoctorId() {
    final user = _storageService.getUser();
    return user?.id;
  }

  /// Fetch all availability windows for the current doctor
  Future<List<DoctorAvailabilityWindow>> getAvailabilityWindows() async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        logW('No doctor ID found in storage');
        return [];
      }

      logD('Fetching availability windows for doctor: $doctorId');

      final response = await _supabase
          .from('doctor_availability_windows')
          .select()
          .eq('doctor_id', doctorId)
          .order('day_of_week')
          .order('start_time');

      if (response.isEmpty) {
        logD('No availability windows found');
        return [];
      }

      final windows = (response as List)
          .map((json) => DoctorAvailabilityWindow.fromJson(json))
          .toList();

      logI('Fetched ${windows.length} availability windows');
      return windows;
    } catch (e) {
      logE('Error fetching availability windows', error: e);
      handleRepositoryError(e);
    }
  }

  /// Fetch all time off periods for the current doctor
  Future<List<DoctorTimeOff>> getTimeOffList() async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        logW('No doctor ID found in storage');
        return [];
      }

      logD('Fetching time off for doctor: $doctorId');

      final response = await _supabase
          .from('doctor_time_off')
          .select()
          .eq('doctor_id', doctorId)
          .gte('end_at', DateTime.now().toIso8601String())
          .order('start_at');

      if (response.isEmpty) {
        logD('No time off found');
        return [];
      }

      final timeOffList = (response as List)
          .map((json) => DoctorTimeOff.fromJson(json))
          .toList();

      logI('Fetched ${timeOffList.length} time off periods');
      return timeOffList;
    } catch (e) {
      logE('Error fetching time off', error: e);
      handleRepositoryError(e);
    }
  }

  /// Upsert availability windows (insert or update)
  /// This will delete all existing windows and insert new ones
  Future<void> saveAvailabilityWindows(
    List<DoctorAvailabilityWindow> windows,
  ) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Saving ${windows.length} availability windows for doctor: $doctorId');

      // Delete all existing windows for this doctor
      await _supabase
          .from('doctor_availability_windows')
          .delete()
          .eq('doctor_id', doctorId);

      // Insert new windows
      if (windows.isNotEmpty) {
        final windowsToInsert = windows.map((window) {
          return {
            'doctor_id': doctorId,
            'day_of_week': window.dayOfWeek,
            'start_time': window.startTime,
            'end_time': window.endTime,
            'is_active': window.isActive,
          };
        }).toList();

        await _supabase
            .from('doctor_availability_windows')
            .insert(windowsToInsert);
      }

      logI('Successfully saved ${windows.length} availability windows');
    } catch (e) {
      logE('Error saving availability windows', error: e);
      handleRepositoryError(e);
    }
  }

  /// Upsert time off periods
  /// This will delete all existing time off and insert new ones
  Future<void> saveTimeOffList(List<DoctorTimeOff> timeOffList) async {
    try {
      final doctorId = _getDoctorId();
      if (doctorId == null) {
        throw Exception('No doctor ID found in storage');
      }

      logD('Saving ${timeOffList.length} time off periods for doctor: $doctorId');

      // Delete all existing time off for this doctor
      await _supabase
          .from('doctor_time_off')
          .delete()
          .eq('doctor_id', doctorId);

      // Insert new time off periods
      if (timeOffList.isNotEmpty) {
        final timeOffToInsert = timeOffList.map((timeOff) {
          return {
            'doctor_id': doctorId,
            'start_at': timeOff.startAt.toIso8601String(),
            'end_at': timeOff.endAt.toIso8601String(),
            'reason': timeOff.reason,
          };
        }).toList();

        await _supabase.from('doctor_time_off').insert(timeOffToInsert);
      }

      logI('Successfully saved ${timeOffList.length} time off periods');
    } catch (e) {
      logE('Error saving time off', error: e);
      handleRepositoryError(e);
    }
  }

  /// Save both availability windows and time off in a transaction
  Future<void> saveAvailability({
    required List<DoctorAvailabilityWindow> windows,
    required List<DoctorTimeOff> timeOffList,
  }) async {
    try {
      await saveAvailabilityWindows(windows);
      await saveTimeOffList(timeOffList);
      logI('Successfully saved all availability data');
    } catch (e) {
      logE('Error saving availability data', error: e);
      handleRepositoryError(e);
    }
  }
}

