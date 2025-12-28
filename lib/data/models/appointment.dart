import 'enums.dart';
import 'model_parsers.dart';

/// Data model for Supabase table: `public.appointments`
class Appointment {
  final String id; // uuid
  final String patientId; // uuid
  final String doctorId; // uuid
  final DateTime startAt;
  final DateTime endAt;
  final AppointmentStatus status;
  final String? patientNote;
  final String? doctorNote;
  final String? cancelledBy; // uuid
  final String? cancelReason;
  final String? bookedFor; // 'self' or 'other'
  final String? otherPersonName;
  final String? otherPersonPhone;
  final int? otherPersonAge;
  final String? reason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.patientNote,
    required this.doctorNote,
    required this.cancelledBy,
    required this.cancelReason,
    this.bookedFor,
    this.otherPersonName,
    this.otherPersonPhone,
    this.otherPersonAge,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Appointment(
      id: (json['id'] ?? '').toString(),
      patientId: (json['patient_id'] ?? '').toString(),
      doctorId: (json['doctor_id'] ?? '').toString(),
      startAt: ModelParsers.dateTime(json['start_at'], fallback: now),
      endAt: ModelParsers.dateTime(json['end_at'], fallback: now),
      status: AppointmentStatusMapper.fromDb(json['status']?.toString()),
      patientNote: ModelParsers.stringOrNull(json['patient_note']),
      doctorNote: ModelParsers.stringOrNull(json['doctor_note']),
      cancelledBy: ModelParsers.stringOrNull(json['cancelled_by']),
      cancelReason: ModelParsers.stringOrNull(json['cancel_reason']),
      bookedFor: ModelParsers.stringOrNull(json['booked_for']),
      otherPersonName: ModelParsers.stringOrNull(json['other_person_name']),
      otherPersonPhone: ModelParsers.stringOrNull(json['other_person_phone']),
      otherPersonAge: ModelParsers.intOrNull(json['other_person_age']),
      reason: ModelParsers.stringOrNull(json['reason']),
      createdAt: ModelParsers.dateTime(json['created_at'], fallback: now),
      updatedAt: ModelParsers.dateTime(json['updated_at'], fallback: now),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'status': status.toDb(),
      'patient_note': patientNote,
      'doctor_note': doctorNote,
      'cancelled_by': cancelledBy,
      'cancel_reason': cancelReason,
      'booked_for': bookedFor,
      'other_person_name': otherPersonName,
      'other_person_phone': otherPersonPhone,
      'other_person_age': otherPersonAge,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Appointment copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? startAt,
    DateTime? endAt,
    AppointmentStatus? status,
    String? patientNote,
    String? doctorNote,
    String? cancelledBy,
    String? cancelReason,
    String? bookedFor,
    String? otherPersonName,
    String? otherPersonPhone,
    int? otherPersonAge,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      status: status ?? this.status,
      patientNote: patientNote ?? this.patientNote,
      doctorNote: doctorNote ?? this.doctorNote,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelReason: cancelReason ?? this.cancelReason,
      bookedFor: bookedFor ?? this.bookedFor,
      otherPersonName: otherPersonName ?? this.otherPersonName,
      otherPersonPhone: otherPersonPhone ?? this.otherPersonPhone,
      otherPersonAge: otherPersonAge ?? this.otherPersonAge,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
