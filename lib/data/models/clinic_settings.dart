import 'model_parsers.dart';

/// Data model for Supabase table: `public.clinic_settings`
class ClinicSettings {
  /// Single row table; `id` is always `true`.
  final bool id;
  final String clinicTimezone;
  final int slotMinutes;
  final int minBookingNoticeMinutes;
  final int maxBookingDaysAhead;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClinicSettings({
    required this.id,
    required this.clinicTimezone,
    required this.slotMinutes,
    required this.minBookingNoticeMinutes,
    required this.maxBookingDaysAhead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClinicSettings.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return ClinicSettings(
      id: ModelParsers.boolValue(json['id'], fallback: true),
      clinicTimezone:
          (json['clinic_timezone'] ?? 'Asia/Kolkata').toString(),
      slotMinutes: ModelParsers.intValue(json['slot_minutes'], fallback: 60),
      minBookingNoticeMinutes: ModelParsers.intValue(
        json['min_booking_notice_minutes'],
        fallback: 0,
      ),
      maxBookingDaysAhead: ModelParsers.intValue(
        json['max_booking_days_ahead'],
        fallback: 30,
      ),
      createdAt: ModelParsers.dateTime(json['created_at'], fallback: now),
      updatedAt: ModelParsers.dateTime(json['updated_at'], fallback: now),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinic_timezone': clinicTimezone,
      'slot_minutes': slotMinutes,
      'min_booking_notice_minutes': minBookingNoticeMinutes,
      'max_booking_days_ahead': maxBookingDaysAhead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ClinicSettings copyWith({
    bool? id,
    String? clinicTimezone,
    int? slotMinutes,
    int? minBookingNoticeMinutes,
    int? maxBookingDaysAhead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClinicSettings(
      id: id ?? this.id,
      clinicTimezone: clinicTimezone ?? this.clinicTimezone,
      slotMinutes: slotMinutes ?? this.slotMinutes,
      minBookingNoticeMinutes:
          minBookingNoticeMinutes ?? this.minBookingNoticeMinutes,
      maxBookingDaysAhead: maxBookingDaysAhead ?? this.maxBookingDaysAhead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


