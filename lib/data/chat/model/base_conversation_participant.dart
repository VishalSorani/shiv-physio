import 'package:shiv_physio_app/data/chat/enum/chat_enums.dart';

/// Base model for conversation participant with enhanced user data
class BaseConversationParticipant {
  final String userId; // Reference to user
  final String name;
  final String? profileImage;
  final bool typingStatus;
  final DateTime lastActiveAt;
  final DateTime? lastSeenAt;
  final int unreadCount;
  final List<String> blockedUsers; // Users this participant has blocked
  final ParticipantRole role; // For group chat roles

  BaseConversationParticipant({
    required this.userId,
    required this.name,
    this.profileImage,
    required this.typingStatus,
    required this.lastActiveAt,
    this.lastSeenAt,
    required this.unreadCount,
    required this.blockedUsers,
    this.role = ParticipantRole.member,
  });

  // Create a copy with modified fields
  BaseConversationParticipant copyWith({
    String? userId,
    String? name,
    String? profileImage,
    bool? typingStatus,
    DateTime? lastActiveAt,
    DateTime? lastSeenAt,
    int? unreadCount,
    List<String>? blockedUsers,
    ParticipantRole? role,
  }) {
    return BaseConversationParticipant(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      typingStatus: typingStatus ?? this.typingStatus,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      unreadCount: unreadCount ?? this.unreadCount,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      role: role ?? this.role,
    );
  }

  // Utility methods
  bool hasBlockedUser(String otherUserId) {
    return blockedUsers.contains(otherUserId);
  }

  bool isAdmin() {
    return role == ParticipantRole.admin;
  }

  bool isModerator() {
    return role == ParticipantRole.moderator;
  }

  bool canDeleteMessages() {
    return role.canDeleteMessages();
  }

  bool canModerateUsers() {
    return role.canModerateUsers();
  }

  bool canAddRemoveUsers() {
    return role.canAddUsers();
  }

  bool canEditGroupInfo() {
    return role.canEditGroupInfo();
  }
}

