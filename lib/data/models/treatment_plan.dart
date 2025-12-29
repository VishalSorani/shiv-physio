import 'model_parsers.dart';

/// Data model for Supabase table: `public.treatment_plans`
class TreatmentPlan {
  final String id; // uuid
  final String patientId; // text
  final String doctorId; // text
  final String? diagnosis; // Medical diagnosis/condition
  final List<String>? medicalConditions; // Array of medical conditions
  final String? treatmentGoals; // Treatment objectives/goals
  final String treatmentPlan; // Detailed treatment plan
  final int? durationWeeks; // Expected duration in weeks
  final int? frequencyPerWeek; // Number of sessions per week
  final String? notes; // Additional notes/observations
  final String status; // active, completed, paused, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;

  const TreatmentPlan({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.diagnosis,
    this.medicalConditions,
    this.treatmentGoals,
    required this.treatmentPlan,
    this.durationWeeks,
    this.frequencyPerWeek,
    this.notes,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    
    // Parse medical conditions array
    List<String>? medicalConditions;
    if (json['medical_conditions'] != null) {
      if (json['medical_conditions'] is List) {
        medicalConditions = (json['medical_conditions'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    return TreatmentPlan(
      id: (json['id'] ?? '').toString(),
      patientId: (json['patient_id'] ?? '').toString(),
      doctorId: (json['doctor_id'] ?? '').toString(),
      diagnosis: ModelParsers.stringOrNull(json['diagnosis']),
      medicalConditions: medicalConditions,
      treatmentGoals: ModelParsers.stringOrNull(json['treatment_goals']),
      treatmentPlan: (json['treatment_plan'] ?? '').toString(),
      durationWeeks: json['duration_weeks'] != null
          ? int.tryParse(json['duration_weeks'].toString())
          : null,
      frequencyPerWeek: json['frequency_per_week'] != null
          ? int.tryParse(json['frequency_per_week'].toString())
          : null,
      notes: ModelParsers.stringOrNull(json['notes']),
      status: (json['status'] ?? 'active').toString(),
      createdAt: ModelParsers.dateTime(json['created_at'], fallback: now),
      updatedAt: ModelParsers.dateTime(json['updated_at'], fallback: now),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'diagnosis': diagnosis,
      'medical_conditions': medicalConditions,
      'treatment_goals': treatmentGoals,
      'treatment_plan': treatmentPlan,
      'duration_weeks': durationWeeks,
      'frequency_per_week': frequencyPerWeek,
      'notes': notes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TreatmentPlan copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? diagnosis,
    List<String>? medicalConditions,
    String? treatmentGoals,
    String? treatmentPlan,
    int? durationWeeks,
    int? frequencyPerWeek,
    String? notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TreatmentPlan(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      diagnosis: diagnosis ?? this.diagnosis,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      treatmentGoals: treatmentGoals ?? this.treatmentGoals,
      treatmentPlan: treatmentPlan ?? this.treatmentPlan,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      frequencyPerWeek: frequencyPerWeek ?? this.frequencyPerWeek,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isPaused => status == 'paused';
  bool get isCancelled => status == 'cancelled';
}

