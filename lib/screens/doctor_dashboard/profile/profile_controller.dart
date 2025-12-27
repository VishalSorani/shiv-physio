import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/modules/availability_repository.dart';
import '../../../data/modules/profile_repository.dart';
import '../../../data/models/doctor_availability_window.dart';
import '../../../data/models/doctor_time_off.dart';
import '../../../data/models/time_off_display.dart';
import '../../../widgets/app_snackbar.dart';

class DoctorProfileController extends BaseController {
  static const String contentId = 'doctor_profile_content';
  static const String tabsId = 'profile_tabs';
  static const String profileDetailsId = 'profile_details';
  static const String availabilityId = 'availability';

  final AvailabilityRepository _availabilityRepository;
  final ProfileRepository _profileRepository;
  final ImagePicker _imagePicker = ImagePicker();

  DoctorProfileController(
    this._availabilityRepository,
    this._profileRepository,
  );

  // Tab management
  int _currentTabIndex = 0; // 0 = Profile Details, 1 = Availability
  int get currentTabIndex => _currentTabIndex;

  // Profile Details Data
  String? _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuC78yIWPDY0KpOkkBVeOnOlS5oQ2U2e6rqz3AhjrVyS0sAqy4oLxc3nFmPg7QekNLZztWGdsGoUqt4DLIfWIe-aR4Rw3F5Zu8zhuxikid04XUGVafRmC2bbgPwOPRBi0n9rlfBiY7ueVBhX4PmSas2ARW2u9jCmBIlVZAmpz0FDLvpTUfZQJMPhYBxxjzjXpuATHMn2BW-I4B4qKEsckxbrCSGuttpPcFN4tg87MbmojJEs4zyMvnA0GRMrVRc5wLF6_0_iNC0Ba6M';
  String? get avatarUrl => _avatarUrl;

  String _doctorName = 'Dr. Pradip Chauhan';
  String get doctorName => _doctorName;

  String _title = 'Physiotherapist';
  String get title => _title;

  String _qualifications = 'BPT, MPT (Orthopedics)';
  String get qualifications => _qualifications;
  set qualifications(String value) {
    _qualifications = value;
    update([profileDetailsId]);
  }

  String _specializations = 'Sports Injury, Post-Op Rehab, Back Pain';
  String get specializations => _specializations;
  set specializations(String value) {
    _specializations = value;
    update([profileDetailsId]);
  }

  int _yearsOfExperience = 12;
  int get yearsOfExperience => _yearsOfExperience;
  set yearsOfExperience(int value) {
    _yearsOfExperience = value;
    update([profileDetailsId]);
  }

  String _clinicName = 'Chauhan Physiotherapy & Wellness';
  String get clinicName => _clinicName;
  set clinicName(String value) {
    _clinicName = value;
    update([profileDetailsId]);
  }

  String _clinicAddress =
      '102, Wellness Arcade, Opp. City Garden, Satellite Road, Ahmedabad - 380015';
  String get clinicAddress => _clinicAddress;
  set clinicAddress(String value) {
    _clinicAddress = value;
    update([profileDetailsId]);
  }

  String _phoneNumber = '+91 98765 43210';
  String get phoneNumber => _phoneNumber;
  set phoneNumber(String value) {
    _phoneNumber = value;
    update([profileDetailsId]);
  }

  String _email = 'dr.pradip@chauhanphysio.com';
  String get email => _email;
  set email(String value) {
    _email = value;
    update([profileDetailsId]);
  }

  int _consultationFee = 800;
  int get consultationFee => _consultationFee;
  set consultationFee(int value) {
    _consultationFee = value;
    update([profileDetailsId]);
  }

  // Availability Data
  List<DoctorAvailabilityWindow> _availabilityWindows = [];
  List<DoctorTimeOff> _timeOffList = [];

  bool _isLoadingAvailability = false;
  bool get isLoadingAvailability => _isLoadingAvailability;

  bool get hasAvailability => _availabilityWindows.isNotEmpty;
  bool get hasTimeOff => _timeOffList.isNotEmpty;

  // Weekly availability (derived from windows)
  List<bool> get weeklyAvailability {
    final availability = List<bool>.filled(7, false);
    for (final window in _availabilityWindows) {
      if (window.isActive) {
        availability[window.dayOfWeek] = true;
      }
    }
    return availability;
  }

  // Get availability windows for a specific day
  List<DoctorAvailabilityWindow> getAvailabilityForDay(int dayOfWeek) {
    return _availabilityWindows
        .where((w) => w.dayOfWeek == dayOfWeek && w.isActive)
        .toList();
  }

  // Get formatted time slots for a day (for UI display)
  List<Map<String, String>> getTimeSlotsForDay(int dayOfWeek) {
    final windows = getAvailabilityForDay(dayOfWeek);
    return windows.map((window) {
      return {
        'start': _formatTimeForDisplay(window.startTime),
        'end': _formatTimeForDisplay(window.endTime),
      };
    }).toList();
  }

  // Check if a day has availability
  bool isDayAvailable(int dayOfWeek) {
    return _availabilityWindows.any(
      (w) => w.dayOfWeek == dayOfWeek && w.isActive,
    );
  }

  // Get time off list formatted for UI
  List<TimeOffDisplay> get timeOffListFormatted {
    return _timeOffList.map((timeOff) => TimeOffDisplay.fromTimeOff(timeOff)).toList();
  }

  String _formatTimeForDisplay(String timeString) {
    // Convert "HH:MM:SS" or "HH:MM" to "HH:MM AM/PM"
    try {
      final parts = timeString.split(':');
      if (parts.isEmpty) return timeString;

      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final displayMinute = minute.toString().padLeft(2, '0');

      return '$displayHour:$displayMinute $period';
    } catch (e) {
      return timeString;
    }
  }

  String _formatTimeForDatabase(String displayTime) {
    // Convert "HH:MM AM/PM" to "HH:MM:SS"
    try {
      final parts = displayTime.split(' ');
      if (parts.length < 2) return displayTime;

      final timePart = parts[0];
      final period = parts[1].toUpperCase();

      final timeParts = timePart.split(':');
      var hour = int.parse(timeParts[0]);
      final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
    } catch (e) {
      return displayTime;
    }
  }


  void onTabChanged(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      update([tabsId, contentId]);
    }
  }

  Future<void> onSaveProfile() async {
    await handleAsyncOperation(() async {
      // Save profile to Supabase
      await _profileRepository.saveDoctorProfile(
        fullName: _doctorName,
        avatarUrl: _avatarUrl,
        email: _email,
        phone: _phoneNumber,
        title: _title,
        qualifications: _qualifications,
        specializations: _specializations,
        yearsOfExperience: _yearsOfExperience,
        clinicName: _clinicName,
        clinicAddress: _clinicAddress,
        consultationFee: _consultationFee,
      );

      AppSnackBar.success(
        title: 'Success',
        message: 'Profile details saved successfully',
      );
      update([profileDetailsId]);
    });
  }

  Future<void> onEditAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        await handleAsyncOperation(() async {
          // Upload to Firebase Storage
          final file = File(image.path);
          final downloadUrl = await _profileRepository.uploadProfilePhoto(file);

          // Update avatar URL
          _avatarUrl = downloadUrl;
          update([profileDetailsId]);

          // Also save to profile
          await _profileRepository.saveDoctorProfile(
            fullName: _doctorName,
            avatarUrl: _avatarUrl,
            email: _email,
            phone: _phoneNumber,
            title: _title,
            qualifications: _qualifications,
            specializations: _specializations,
            yearsOfExperience: _yearsOfExperience,
            clinicName: _clinicName,
            clinicAddress: _clinicAddress,
            consultationFee: _consultationFee,
          );

          AppSnackBar.success(
            title: 'Success',
            message: 'Profile photo updated successfully',
          );
        });
      }
    } catch (e) {
      AppSnackBar.error(
        title: 'Error',
        message: 'Failed to update profile photo: ${e.toString()}',
      );
    }
  }

  Future<void> loadProfile() async {
    await handleAsyncOperation(() async {
      final profile = await _profileRepository.getDoctorProfile();
      if (profile != null) {
        _doctorName = profile['full_name'] ?? _doctorName;
        _avatarUrl = profile['avatar_url'] ?? _avatarUrl;
        _email = profile['email'] ?? _email;
        _phoneNumber = profile['phone'] ?? _phoneNumber;

        // Try to load additional profile data
        // These fields may not exist in the database yet
        _title = profile['title'] ?? _title;
        _qualifications = profile['qualifications'] ?? _qualifications;
        _specializations = profile['specializations'] ?? _specializations;
        if (profile['years_of_experience'] != null) {
          _yearsOfExperience = profile['years_of_experience'] as int;
        }
        _clinicName = profile['clinic_name'] ?? _clinicName;
        _clinicAddress = profile['clinic_address'] ?? _clinicAddress;
        if (profile['consultation_fee'] != null) {
          _consultationFee = profile['consultation_fee'] as int;
        }

        update([profileDetailsId]);
      }
    });
  }

  Future<void> onSaveAvailability() async {
    await handleAsyncOperation(() async {
      // Save all windows from _availabilityWindows (they already have updated times)
      // Update isActive status based on weekly availability
      final windowsToSave = <DoctorAvailabilityWindow>[];

      // For each day of week (0-6)
      for (int day = 0; day < 7; day++) {
        final isAvailable = weeklyAvailability[day];
        final existingWindows = _availabilityWindows
            .where((w) => w.dayOfWeek == day)
            .toList();

        if (existingWindows.isEmpty && isAvailable) {
          // Create default window if day is available but no windows exist
          windowsToSave.add(
            DoctorAvailabilityWindow(
              id: '', // Will be generated by DB
              doctorId: '', // Will be set by repository
              dayOfWeek: day,
              startTime: '09:00:00',
              endTime: '17:00:00',
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        } else {
          // Update existing windows with correct isActive status
          windowsToSave.addAll(
            existingWindows.map((w) => w.copyWith(isActive: isAvailable)),
          );
        }
      }

      // Save to Supabase
      await _availabilityRepository.saveAvailability(
        windows: windowsToSave,
        timeOffList: _timeOffList,
      );

      // Reload data
      await loadAvailability();

      AppSnackBar.success(
        title: 'Success',
        message: 'Availability saved successfully',
      );
      update([availabilityId]);
    });
  }

  void onDayTapped(int dayIndex) {
    // Toggle availability for this day
    final isCurrentlyAvailable = isDayAvailable(dayIndex);

    if (isCurrentlyAvailable) {
      // Mark all windows for this day as inactive
      for (int i = 0; i < _availabilityWindows.length; i++) {
        if (_availabilityWindows[i].dayOfWeek == dayIndex) {
          _availabilityWindows[i] = _availabilityWindows[i].copyWith(
            isActive: false,
          );
        }
      }
    } else {
      // Create a default window if none exists
      final existingWindows = _availabilityWindows
          .where((w) => w.dayOfWeek == dayIndex)
          .toList();

      if (existingWindows.isEmpty) {
        // Create default window (9 AM - 5 PM)
        final newWindow = DoctorAvailabilityWindow(
          id: '',
          doctorId: '',
          dayOfWeek: dayIndex,
          startTime: '09:00:00',
          endTime: '17:00:00',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _availabilityWindows.add(newWindow);
      } else {
        // Activate existing windows
        for (int i = 0; i < _availabilityWindows.length; i++) {
          if (_availabilityWindows[i].dayOfWeek == dayIndex) {
            _availabilityWindows[i] = _availabilityWindows[i].copyWith(
              isActive: true,
            );
          }
        }
      }
    }

    update([availabilityId]);
  }

  void onAddTimeSlot(int dayOfWeek, {String? startTime, String? endTime}) {
    // Add a new time slot with provided times or defaults
    final newWindow = DoctorAvailabilityWindow(
      id: '',
      doctorId: '',
      dayOfWeek: dayOfWeek,
      startTime: startTime ?? '09:00:00',
      endTime: endTime ?? '17:00:00',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _availabilityWindows.add(newWindow);
    update([availabilityId]);
  }

  void onEditTimeSlot(
    int dayOfWeek,
    int slotIndex,
    String startTime,
    String endTime,
  ) {
    // Update an existing time slot
    final windowsForDay = _availabilityWindows
        .where((w) => w.dayOfWeek == dayOfWeek && w.isActive)
        .toList();

    if (slotIndex < windowsForDay.length) {
      final windowToEdit = windowsForDay[slotIndex];
      final dbStartTime = _formatTimeForDatabase(startTime);
      final dbEndTime = _formatTimeForDatabase(endTime);

      // Find and update the window in the main list
      for (int i = 0; i < _availabilityWindows.length; i++) {
        if (_availabilityWindows[i].id == windowToEdit.id ||
            (_availabilityWindows[i].dayOfWeek == dayOfWeek &&
                _availabilityWindows[i].startTime == windowToEdit.startTime &&
                _availabilityWindows[i].endTime == windowToEdit.endTime)) {
          _availabilityWindows[i] = _availabilityWindows[i].copyWith(
            startTime: dbStartTime,
            endTime: dbEndTime,
            updatedAt: DateTime.now(),
          );
          break;
        }
      }
      update([availabilityId]);
    }
  }

  void onDeleteTimeSlot(int dayOfWeek, int slotIndex) {
    final windowsForDay = _availabilityWindows
        .where((w) => w.dayOfWeek == dayOfWeek && w.isActive)
        .toList();
    if (slotIndex < windowsForDay.length) {
      final windowToDelete = windowsForDay[slotIndex];
      _availabilityWindows.remove(windowToDelete);
      update([availabilityId]);
    }
  }

  DoctorAvailabilityWindow? getTimeSlotWindow(int dayOfWeek, int slotIndex) {
    final windowsForDay = _availabilityWindows
        .where((w) => w.dayOfWeek == dayOfWeek && w.isActive)
        .toList();
    if (slotIndex < windowsForDay.length) {
      return windowsForDay[slotIndex];
    }
    return null;
  }

  void onAddTimeOff(DateTime startAt, DateTime endAt, String? reason) {
    final newTimeOff = DoctorTimeOff(
      id: '', // Will be generated by DB
      doctorId: '', // Will be set by repository
      startAt: startAt,
      endAt: endAt,
      reason: reason,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _timeOffList.add(newTimeOff);
    update([availabilityId]);
  }

  void onEditTimeOff(
    int index,
    DateTime startAt,
    DateTime endAt,
    String? reason,
  ) {
    if (index < _timeOffList.length) {
      _timeOffList[index] = _timeOffList[index].copyWith(
        startAt: startAt,
        endAt: endAt,
        reason: reason,
        updatedAt: DateTime.now(),
      );
      update([availabilityId]);
    }
  }

  void onDeleteTimeOff(int index) {
    if (index < _timeOffList.length) {
      _timeOffList.removeAt(index);
      update([availabilityId]);
    }
  }

  DoctorTimeOff? getTimeOff(int index) {
    if (index < _timeOffList.length) {
      return _timeOffList[index];
    }
    return null;
  }

  Future<void> loadAvailability() async {
    await handleAsyncOperation(() async {
      _isLoadingAvailability = true;
      update([availabilityId]);

      try {
        final windows = await _availabilityRepository.getAvailabilityWindows();
        final timeOff = await _availabilityRepository.getTimeOffList();

        _availabilityWindows = windows;
        _timeOffList = timeOff;

        update([availabilityId]);
      } finally {
        _isLoadingAvailability = false;
        update([availabilityId]);
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    // Load profile and availability when controller initializes
    loadProfile();
    loadAvailability();
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
  }
}
