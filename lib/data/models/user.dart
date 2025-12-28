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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
