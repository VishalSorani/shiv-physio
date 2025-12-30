import 'package:shiv_physio_app/data/chat/helper/timestamp_parser_helper.dart';
import 'package:shiv_physio_app/data/chat/model/chat_conversation_participant.dart';
import 'package:shiv_physio_app/data/chat/model/conversation_last_message.dart';

class ChatConversation {
  final String id;
  final List<String> participantIds; // List of user references/IDs
  final Map<String, ConversationParticipant>
      participantData; // Participant details by userId
  final String? title;
  final DateTime createdAt;
  final LastMessage? lastMessage;
  final bool isGroupChat;
  final String? adminId; // Reference to user ID who is admin
  final String? groupImage; // For group chats
  final bool isReported;
  final String? reportReason;
  final DateTime? reportedAt;
  final String? reportedBy; // User ID who reported

  ChatConversation({
    required this.id,
    required this.participantIds,
    required this.participantData,
    this.title,
    required this.createdAt,
    this.lastMessage,
    required this.isGroupChat,
    this.adminId,
    this.groupImage,
    this.isReported = false,
    this.reportReason,
    this.reportedAt,
    this.reportedBy,
  });
  
  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    // Parse participants
    List<String> participants = [];
    if (json['participantIds'] != null) {
      participants = List<String>.from(json['participantIds']);
    }

    // Parse participant data
    Map<String, ConversationParticipant> participantDataMap = {};
    if (json['participantData'] != null) {
      (json['participantData'] as Map<String, dynamic>).forEach((userId, data) {
        participantDataMap[userId] =
            ConversationParticipant.fromJson(data as Map<String, dynamic>);
      });
    }

    // Parse last message
    LastMessage? lastMsg;
    if (json['lastMessage'] != null) {
      lastMsg =
          LastMessage.fromJson(json['lastMessage'] as Map<String, dynamic>);
    }

      return ChatConversation(
      id: json['id'] as String,
      participantIds: participants,
      participantData: participantDataMap,
      title: json['title'] as String?,
      createdAt: TimestampParser.parseTimestampWithDefault(json['createdAt']),
      lastMessage: lastMsg,
      isGroupChat: json['isGroupChat'] as bool,
      adminId: json['adminId'] as String?,
      groupImage: json['groupImage'] as String?,
      isReported: json['isReported'] as bool? ?? false,
      reportReason: json['reportReason'] as String?,
      reportedAt: TimestampParser.parseTimestamp(json['reportedAt']),
      reportedBy: json['reportedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    // Convert participant data to a map
    final Map<String, dynamic> participantDataJson = {};
    participantData.forEach((userId, participant) {
      participantDataJson[userId] = participant.toJson();
    });

    return {
      'id': id,
      'participantIds': participantIds,
      'participantData': participantDataJson,
      'title': title,
      'createdAt': createdAt,
      'lastMessage': lastMessage?.toJson(),
      'isGroupChat': isGroupChat,
      'adminId': adminId,
      'groupImage': groupImage,
      'isReported': isReported,
      'reportReason': reportReason,
      'reportedAt': reportedAt,
      'reportedBy': reportedBy,
    };
  }

  ChatConversation copyWith({
    String? id,
    List<String>? participantIds,
    Map<String, ConversationParticipant>? participantData,
    String? title,
    DateTime? createdAt,
    LastMessage? lastMessage,
    bool? isGroupChat,
    String? adminId,
    String? groupImage,
    bool? isReported,
    String? reportReason,
    DateTime? reportedAt,
    String? reportedBy,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      participantData: participantData ?? this.participantData,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      isGroupChat: isGroupChat ?? this.isGroupChat,
      adminId: adminId ?? this.adminId,
      groupImage: groupImage ?? this.groupImage,
      isReported: isReported ?? this.isReported,
      reportReason: reportReason ?? this.reportReason,
      reportedAt: reportedAt ?? this.reportedAt,
      reportedBy: reportedBy ?? this.reportedBy,
    );
  }

  // Utility methods

  // Check if a user is a participant
  bool hasParticipant(String userId) {
    return participantIds.contains(userId);
  }

  // Get participant data for a user
  ConversationParticipant? getParticipantData(String userId) {
    return participantData[userId];
  }

  // Get other participant IDs (excluding specified user)
  List<String> getOtherParticipantIds(String userId) {
    return participantIds.where((id) => id != userId).toList();
  }

  // Check if a user has blocked another user
  bool hasUserBlocked(String userId, String otherUserId) {
    final participant = participantData[userId];
    if (participant == null) return false;
    return participant.hasBlockedUser(otherUserId);
  }

  // Check if a user is blocked by another user
  bool isUserBlockedBy(String userId, String otherUserId) {
    final otherParticipant = participantData[otherUserId];
    if (otherParticipant == null) return false;
    return otherParticipant.hasBlockedUser(userId);
  }

  // Get a list of users blocked by a specific user
  List<String> getUsersBlockedBy(String userId) {
    final participant = participantData[userId];
    if (participant == null) return [];
    return participant.blockedUsers;
  }

  // Check if a participant is typing
  bool isParticipantTyping(String userId) {
    final participant = participantData[userId];
    if (participant == null) return false;
    return participant.typingStatus;
  }

  // Get unread count for a specific user
  int getUnreadCountForUser(String userId) {
    final participant = participantData[userId];
    if (participant == null) return 0;
    return participant.unreadCount;
  }

  // Check if anyone is typing except the given user
  bool isAnyoneTyping(String exceptUserId) {
    for (final entry in participantData.entries) {
      if (entry.key != exceptUserId && entry.value.typingStatus) {
        return true;
      }
    }
    return false;
  }

  // Get conversation display name
  String getDisplayName(String currentUserId) {
    if (isGroupChat && title != null && title!.isNotEmpty) {
      return title!;
    }

    if (!isGroupChat) {
      final otherUserIds = getOtherParticipantIds(currentUserId);
      if (otherUserIds.isNotEmpty) {
        // In a real app, you'd look up the user's name from a user service
        return "Chat with ${otherUserIds.first}";
      }
    }

    // Fallback
    if (isGroupChat) {
      return "Group (${participantIds.length} participants)";
    }

    return "Chat";
  }

  // Get message preview
  String getMessagePreview() {
    if (lastMessage != null) {
      return lastMessage!.getMessagePreview();
    }
    return "No messages yet";
  }

  // Check if the current user is an admin
  bool isUserAdmin(String userId) {
    // Check by admin ID field
    if (adminId == userId) return true;

    // Check by participant role
    final participantData = getParticipantData(userId);
    if (participantData != null) {
      return participantData.isAdmin();
    }

    return false;
  }

  // Check if user is a moderator
  bool isUserModerator(String userId) {
    final participantData = getParticipantData(userId);
    if (participantData != null) {
      return participantData.isModerator();
    }

    return false;
  }

  // Check if user can perform administrative actions
  bool canUserAdminister(String userId) {
    return isUserAdmin(userId) || isUserModerator(userId);
  }

  // Check if a conversation can be messaged (not reported, user not blocked)
  bool canSendMessages(String userId) {
    if (isReported) return false;

    // For 1:1 chat, check if either user blocked the other
    if (!isGroupChat) {
      final otherUserId = getOtherParticipantIds(userId).firstOrNull;
      if (otherUserId != null) {
        if (hasUserBlocked(userId, otherUserId) ||
            isUserBlockedBy(userId, otherUserId)) {
          return false;
        }
      }
    }

    return true;
  }
}
