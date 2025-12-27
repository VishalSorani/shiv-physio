import 'model_parsers.dart';

/// Data model for Supabase table: `public.doctor_availability_windows`
class DoctorAvailabilityWindow {
  final String id; // uuid
  final String doctorId; // uuid

  /// 0 = Sunday ... 6 = Saturday (Postgres `extract(dow ...)` convention)
  final int dayOfWeek;

  /// Postgres `time` is typically returned by Supabase as `HH:MM:SS` string.
  final String startTime;
  final String endTime;

  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DoctorAvailabilityWindow({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoctorAvailabilityWindow.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return DoctorAvailabilityWindow(
      id: (json['id'] ?? '').toString(),
      doctorId: (json['doctor_id'] ?? '').toString(),
      dayOfWeek: ModelParsers.intValue(json['day_of_week'], fallback: 0),
      startTime: (json['start_time'] ?? '').toString(),
      endTime: (json['end_time'] ?? '').toString(),
      isActive: ModelParsers.boolValue(json['is_active'], fallback: true),
      createdAt: ModelParsers.dateTime(json['created_at'], fallback: now),
      updatedAt: ModelParsers.dateTime(json['updated_at'], fallback: now),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DoctorAvailabilityWindow copyWith({
    String? id,
    String? doctorId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorAvailabilityWindow(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


