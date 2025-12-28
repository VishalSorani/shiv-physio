/// Content type enum
enum ContentType { video, image }

/// Content category enum
enum ContentCategory { all, videos, images, promotional, exercise }

/// Model for content items (videos/images)
class ContentItem {
  final String id;
  final String title;
  final String? description;
  final ContentType type;
  final ContentCategory category;
  final String fileUrl; // URL to the file in storage
  final String? thumbnailUrl; // URL to thumbnail (for videos)
  final int? duration; // Duration in seconds (for videos)
  final int fileSize; // File size in bytes
  final String? fileFormat; // e.g., "MP4", "JPG", "PNG"
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContentItem({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.category,
    required this.fileUrl,
    this.thumbnailUrl,
    this.duration,
    required this.fileSize,
    this.fileFormat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    // Get file URL from video_url or storage_path
    final videoUrl = json['video_url']?.toString();
    final storagePath = json['storage_path']?.toString();
    final fileUrl = videoUrl?.isNotEmpty == true
        ? videoUrl!
        : (storagePath?.isNotEmpty == true ? storagePath! : '');

    // Parse content type from database
    final typeString = json['type']?.toString().toLowerCase();
    final contentType = _parseContentType(typeString, videoUrl, storagePath);

    // Extract file format from URL/path
    String? fileFormat;
    if (fileUrl.isNotEmpty) {
      final extension = fileUrl.split('.').last.toLowerCase();
      fileFormat = extension.toUpperCase();
    }

    return ContentItem(
      id: (json['id'] ?? '').toString(),
      title: json['title']?.toString() ?? 'Untitled',
      description: json['description']?.toString(),
      type: contentType,
      category: _parseContentCategory(json['category']?.toString()),
      fileUrl: fileUrl,
      thumbnailUrl: json['thumbnail_url']?.toString(),
      duration:
          null, // Not in schema, can be extracted from video metadata later
      fileSize: 0, // Not in schema
      fileFormat: fileFormat,
      createdAt: _parseDateTime(json['created_at']) ?? now,
      updatedAt:
          _parseDateTime(json['updated_at']) ??
          _parseDateTime(json['created_at']) ??
          now,
    );
  }

  static ContentType _parseContentType(
    String? typeString,
    String? videoUrl,
    String? storagePath,
  ) {
    // First try to parse from type field
    if (typeString != null) {
      switch (typeString.toLowerCase()) {
        case 'video':
          return ContentType.video;
        case 'image':
          return ContentType.image;
      }
    }

    // Fallback: determine from URL fields
    if (videoUrl != null && videoUrl.isNotEmpty) {
      return ContentType.video;
    }
    if (storagePath != null && storagePath.isNotEmpty) {
      return ContentType.image;
    }

    // Default fallback
    return ContentType.image;
  }

  Map<String, dynamic> toJson() {
    // Map to content table structure
    // For videos: use video_url, for images: use storage_path
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toDb(),
      'type': type.toDb(), // Store type explicitly in database
      'thumbnail_url': thumbnailUrl,
      // Store video URLs in video_url, image URLs in storage_path
      'video_url': type == ContentType.video ? fileUrl : null,
      'storage_path': type == ContentType.image ? fileUrl : null,
      'is_published': true, // Default to published
      'created_at': createdAt.toIso8601String(),
    };
  }

  static ContentCategory _parseContentCategory(String? value) {
    switch (value?.toLowerCase()) {
      case 'videos':
        return ContentCategory.videos;
      case 'images':
        return ContentCategory.images;
      case 'promotional':
        return ContentCategory.promotional;
      case 'exercise':
        return ContentCategory.exercise;
      default:
        return ContentCategory.all;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Get formatted duration string (for videos)
  String? get formattedDuration {
    if (duration == null) return null;
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Get category display name
  String get categoryDisplayName {
    switch (category) {
      case ContentCategory.promotional:
        return 'Promotional';
      case ContentCategory.exercise:
        return 'Exercise';
      case ContentCategory.videos:
        return 'Videos';
      case ContentCategory.images:
        return 'Images';
      case ContentCategory.all:
        return 'All';
    }
  }

  /// Get category color name (for UI to determine color)
  String get categoryColorName {
    switch (category) {
      case ContentCategory.promotional:
        return 'blue';
      case ContentCategory.exercise:
        return 'teal';
      case ContentCategory.videos:
        return 'blue';
      case ContentCategory.images:
        return 'green';
      case ContentCategory.all:
        return 'grey';
    }
  }

  /// Create a copy with updated fields
  ContentItem copyWith({
    String? id,
    String? title,
    String? description,
    ContentType? type,
    ContentCategory? category,
    String? fileUrl,
    String? thumbnailUrl,
    int? duration,
    int? fileSize,
    String? fileFormat,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      fileFormat: fileFormat ?? this.fileFormat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

extension ContentTypeExtension on ContentType {
  String toDb() {
    return switch (this) {
      ContentType.video => 'video',
      ContentType.image => 'image',
    };
  }
}

extension ContentCategoryExtension on ContentCategory {
  String toDb() {
    return switch (this) {
      ContentCategory.all => 'all',
      ContentCategory.videos => 'videos',
      ContentCategory.images => 'images',
      ContentCategory.promotional => 'promotional',
      ContentCategory.exercise => 'exercise',
    };
  }
}
