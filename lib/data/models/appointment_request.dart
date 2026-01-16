import 'appointment.dart';
import 'user.dart';
import 'enums.dart';
import 'package:intl/intl.dart';

/// Model for appointment request with patient information
class AppointmentRequest {
  final Appointment appointment;
  final User patient;

  const AppointmentRequest({required this.appointment, required this.patient});

  factory AppointmentRequest.fromJson(Map<String, dynamic> json) {
    final appointment = Appointment.fromJson(json);
    final patientJson = json['patient'] as Map<String, dynamic>?;

    User patient;
    if (patientJson != null) {
      patient = User.fromJson(patientJson);
    } else {
      // Create a minimal user if patient data is missing
      final now = DateTime.now();
      patient = User(
        id: appointment.patientId,
        isDoctor: false,
        fullName: null,
        email: null,
        phone: null,
        age: null,
        avatarUrl: null,
        createdAt: now,
        updatedAt: now,
      );
    }

    return AppointmentRequest(appointment: appointment, patient: patient);
  }

  Map<String, dynamic> toJson() {
    return {...appointment.toJson(), 'patient': patient.toJson()};
  }

  /// Get formatted date string
  String get formattedDate {
    final localStart = appointment.startAt.toLocal();
    return DateFormat('MMM d, yyyy').format(localStart);
  }

  /// Get formatted time string
  String get formattedTime {
    final localStart = appointment.startAt.toLocal();
    return DateFormat('hh:mm a').format(localStart);
  }

  /// Get patient age and gender string (if available)
  String? get patientAgeGender {
    if (patient.age != null) {
      // Gender is not stored in User model, so we'll just show age
      return '${patient.age} years';
    }
    return null;
  }

  /// Check if this is a new request (created within last 24 hours)
  bool get isNew {
    final now = DateTime.now();
    final hoursSinceCreation = now.difference(appointment.createdAt).inHours;
    return hoursSinceCreation < 24;
  }

  /// Get request status based on appointment status and urgency
  RequestStatus? get requestStatus {
    if (appointment.status == AppointmentStatus.pending) {
      // Check if urgent based on patient note keywords or time proximity
      final note = appointment.patientNote?.toLowerCase() ?? '';
      final isUrgent =
          note.contains('urgent') ||
          note.contains('emergency') ||
          note.contains('severe') ||
          note.contains('high fever') ||
          note.contains('pain');

      if (isUrgent) {
        return RequestStatus.urgent;
      }
      return RequestStatus.newRequest;
    }
    return null;
  }

  /// Get reason for visit (patient note)
  String get reasonForVisit => appointment.reason ?? 'General Consultation';
}
