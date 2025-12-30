class ChatUser {
  final String id;
  final String name;
  final String? profileImage;
  final DateTime lastActiveAt;
  final DateTime? lastSeenAt;

  ChatUser({
    required this.id,
    required this.name,
    this.profileImage,
    required this.lastActiveAt,
    this.lastSeenAt,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImage: json['profileImage'] as String?,
      lastActiveAt: (json['lastActiveAt'])?.toDate(),
      lastSeenAt: (json['lastSeenAt'])?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
      'lastActiveAt': lastActiveAt,
      'lastSeenAt': lastSeenAt,
    };
  }

  ChatUser copyWith({
    String? id,
    String? name,
    String? profileImage,
    bool? typingStatus,
    DateTime? lastActiveAt,
    DateTime? lastSeenAt,
  }) {
    return ChatUser(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  bool get isOnline {
    final now = DateTime.now();
    final difference = now.difference(lastActiveAt);
    // Consider a user online if they've been active in the last 2 minutes
    return difference.inMinutes < 2;
  }
}
