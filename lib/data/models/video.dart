import 'model_parsers.dart';

/// Data model for Supabase table: `public.videos`
class Video {
  final String id; // uuid
  final String uploadedBy; // uuid
  final String title;
  final String? description;
  final String? category;
  final String? thumbnailUrl;
  final String? storagePath;
  final String? videoUrl;
  final bool isPublished;
  final DateTime createdAt;

  const Video({
    required this.id,
    required this.uploadedBy,
    required this.title,
    required this.description,
    required this.category,
    required this.thumbnailUrl,
    required this.storagePath,
    required this.videoUrl,
    required this.isPublished,
    required this.createdAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Video(
      id: (json['id'] ?? '').toString(),
      uploadedBy: (json['uploaded_by'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: ModelParsers.stringOrNull(json['description']),
      category: ModelParsers.stringOrNull(json['category']),
      thumbnailUrl: ModelParsers.stringOrNull(json['thumbnail_url']),
      storagePath: ModelParsers.stringOrNull(json['storage_path']),
      videoUrl: ModelParsers.stringOrNull(json['video_url']),
      isPublished: ModelParsers.boolValue(json['is_published'], fallback: true),
      createdAt: ModelParsers.dateTime(json['created_at'], fallback: now),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uploaded_by': uploadedBy,
      'title': title,
      'description': description,
      'category': category,
      'thumbnail_url': thumbnailUrl,
      'storage_path': storagePath,
      'video_url': videoUrl,
      'is_published': isPublished,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Video copyWith({
    String? id,
    String? uploadedBy,
    String? title,
    String? description,
    String? category,
    String? thumbnailUrl,
    String? storagePath,
    String? videoUrl,
    bool? isPublished,
    DateTime? createdAt,
  }) {
    return Video(
      id: id ?? this.id,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      storagePath: storagePath ?? this.storagePath,
      videoUrl: videoUrl ?? this.videoUrl,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


