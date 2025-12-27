import 'model_parsers.dart';

/// Data model for Supabase RPC result: `public.get_available_slots(...)`
class AvailableSlot {
  final String doctorId; // uuid
  final DateTime slotStartAt;
  final DateTime slotEndAt;

  const AvailableSlot({
    required this.doctorId,
    required this.slotStartAt,
    required this.slotEndAt,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return AvailableSlot(
      doctorId: (json['doctor_id'] ?? '').toString(),
      slotStartAt: ModelParsers.dateTime(json['slot_start_at'], fallback: now),
      slotEndAt: ModelParsers.dateTime(json['slot_end_at'], fallback: now),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'slot_start_at': slotStartAt.toIso8601String(),
      'slot_end_at': slotEndAt.toIso8601String(),
    };
  }

  AvailableSlot copyWith({
    String? doctorId,
    DateTime? slotStartAt,
    DateTime? slotEndAt,
  }) {
    return AvailableSlot(
      doctorId: doctorId ?? this.doctorId,
      slotStartAt: slotStartAt ?? this.slotStartAt,
      slotEndAt: slotEndAt ?? this.slotEndAt,
    );
  }
}


