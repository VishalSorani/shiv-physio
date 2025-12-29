import 'model_parsers.dart';

/// Data model for Supabase table: `public.notifications`
class Notification {
  final String id; // uuid
  final String userId; // text
  final String title;
  final String message;
  final String
  notificationType; // appointment_booked, appointment_cancelled, etc.
  final String? relatedId; // ID of related entity (e.g., appointment_id)
  final Map<String, dynamic>? data; // Additional notification data
  final String? onesignalId; // OneSignal player ID
  final DateTime sentAt;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.notificationType,
    this.relatedId,
    this.data,
    this.onesignalId,
    required this.sentAt,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Notification(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      notificationType: (json['notification_type'] ?? '').toString(),
      relatedId: ModelParsers.stringOrNull(json['related_id']),
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      onesignalId: ModelParsers.stringOrNull(json['onesignal_id']),
      sentAt: ModelParsers.dateTime(json['sent_at'], fallback: now),
      readAt: ModelParsers.dateTimeOrNull(json['read_at']),
      createdAt: ModelParsers.dateTime(json['created_at'], fallback: now),
      updatedAt: ModelParsers.dateTime(json['updated_at'], fallback: now),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'related_id': relatedId,
      'data': data,
      'onesignal_id': onesignalId,
      'sent_at': sentAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? notificationType,
    String? relatedId,
    Map<String, dynamic>? data,
    String? onesignalId,
    DateTime? sentAt,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationType: notificationType ?? this.notificationType,
      relatedId: relatedId ?? this.relatedId,
      data: data ?? this.data,
      onesignalId: onesignalId ?? this.onesignalId,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isRead => readAt != null;
}
