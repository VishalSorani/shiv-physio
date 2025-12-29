import 'model_parsers.dart';

/// Data model for Supabase table: `public.users`
class User {
  final String id; // uuid
  final bool isDoctor;
  final String? fullName;
  final String? email;
  final String? phone;
  final int? age;
  final String? avatarUrl;
  final String? gender; // male, female, other
  final String? address;
  // Doctor-specific fields
  final String? title;
  final String? qualifications;
  final String? specializations;
  final int? yearsOfExperience;
  final String? clinicName;
  final String? clinicAddress;
  final int? consultationFee;
  final String? onesignalId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.isDoctor,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.age,
    required this.avatarUrl,
    this.gender,
    this.address,
    this.title,
    this.qualifications,
    this.specializations,
    this.yearsOfExperience,
    this.clinicName,
    this.clinicAddress,
    this.consultationFee,
    this.onesignalId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return User(
      id: (json['id'] ?? '').toString(),
      isDoctor: ModelParsers.boolValue(json['is_doctor'], fallback: false),
      fullName: ModelParsers.stringOrNull(json['full_name']),
      email: ModelParsers.stringOrNull(json['email']),
      phone: ModelParsers.stringOrNull(json['phone']),
      age: ModelParsers.intOrNull(json['age']),
      avatarUrl: ModelParsers.stringOrNull(json['avatar_url']),
      gender: ModelParsers.stringOrNull(json['gender']),
      address: ModelParsers.stringOrNull(json['address']),
      title: ModelParsers.stringOrNull(json['title']),
      qualifications: ModelParsers.stringOrNull(json['qualifications']),
      specializations: ModelParsers.stringOrNull(json['specializations']),
      yearsOfExperience: ModelParsers.intOrNull(json['years_of_experience']),
      clinicName: ModelParsers.stringOrNull(json['clinic_name']),
      clinicAddress: ModelParsers.stringOrNull(json['clinic_address']),
      consultationFee: ModelParsers.intOrNull(json['consultation_fee']),
      onesignalId: ModelParsers.stringOrNull(json['onesignal_id']),
      createdAt: ModelParsers.dateTime(json['created_at'], fallback: now),
      updatedAt: ModelParsers.dateTime(json['updated_at'], fallback: now),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_doctor': isDoctor,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'age': age,
      'avatar_url': avatarUrl,
      'gender': gender,
      'address': address,
      'title': title,
      'qualifications': qualifications,
      'specializations': specializations,
      'years_of_experience': yearsOfExperience,
      'clinic_name': clinicName,
      'clinic_address': clinicAddress,
      'consultation_fee': consultationFee,
      'onesignal_id': onesignalId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    bool? isDoctor,
    String? fullName,
    String? email,
    String? phone,
    int? age,
    String? avatarUrl,
    String? gender,
    String? address,
    String? title,
    String? qualifications,
    String? specializations,
    int? yearsOfExperience,
    String? clinicName,
    String? clinicAddress,
    int? consultationFee,
    String? onesignalId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      isDoctor: isDoctor ?? this.isDoctor,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      title: title ?? this.title,
      qualifications: qualifications ?? this.qualifications,
      specializations: specializations ?? this.specializations,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      consultationFee: consultationFee ?? this.consultationFee,
      onesignalId: onesignalId ?? this.onesignalId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
