import 'package:shiv_physio_app/data/chat/enum/chat_enums.dart';
import 'package:shiv_physio_app/data/chat/helper/timestamp_parser_helper.dart';

class ConversationParticipant {
  final String userId; // Reference to user
  final int unreadCount;
  final DateTime? lastSeenAt;
  final bool typingStatus;
  final List<String> blockedUsers; // Users this participant has blocked
  final ParticipantRole role; // For group chat roles

  ConversationParticipant({
    required this.userId,
    required this.unreadCount,
    this.lastSeenAt,
    required this.typingStatus,
    required this.blockedUsers,
    this.role = ParticipantRole.member,
  });

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    List<String> blocked = [];
    if (json['blockedUsers'] != null) {
      blocked = List<String>.from(json['blockedUsers']);
    }

    return ConversationParticipant(
      userId: json['userId'] as String,
      unreadCount: json['unreadCount'] as int? ?? 0,
      lastSeenAt: TimestampParser.parseTimestamp(json['lastSeenAt']),
      typingStatus: json['typingStatus'] as bool? ?? false,
      blockedUsers: blocked,
      role: ParticipantRole.values.firstWhere(
        (role) => role.value == (json['role'] as String?),
        orElse: () => ParticipantRole.member,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'unreadCount': unreadCount,
      'lastSeenAt': lastSeenAt,
      'typingStatus': typingStatus,
      'blockedUsers': blockedUsers,
      'role': role.value,
    };
  }

  ConversationParticipant copyWith({
    String? userId,
    int? unreadCount,
    DateTime? lastSeenAt,
    bool? typingStatus,
    List<String>? blockedUsers,
    ParticipantRole? role,
  }) {
    return ConversationParticipant(
      userId: userId ?? this.userId,
      unreadCount: unreadCount ?? this.unreadCount,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      typingStatus: typingStatus ?? this.typingStatus,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      role: role ?? this.role,
    );
  }

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
