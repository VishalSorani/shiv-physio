import 'model_parsers.dart';

/// Data model for Supabase table: `public.doctor_time_off`
class DoctorTimeOff {
  final String id; // uuid
  final String doctorId; // uuid
  final DateTime startAt;
  final DateTime endAt;
  final String? reason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DoctorTimeOff({
    required this.id,
    required this.doctorId,
    required this.startAt,
    required this.endAt,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoctorTimeOff.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return DoctorTimeOff(
      id: (json['id'] ?? '').toString(),
      doctorId: (json['doctor_id'] ?? '').toString(),
      startAt: ModelParsers.dateTime(json['start_at'], fallback: now),
      endAt: ModelParsers.dateTime(json['end_at'], fallback: now),
      reason: ModelParsers.stringOrNull(json['reason']),
      createdAt: ModelParsers.dateTime(json['created_at'], fallback: now),
      updatedAt: ModelParsers.dateTime(json['updated_at'], fallback: now),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DoctorTimeOff copyWith({
    String? id,
    String? doctorId,
    DateTime? startAt,
    DateTime? endAt,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorTimeOff(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


