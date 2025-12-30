import 'package:shiv_physio_app/data/chat/model/base_conversation_participant.dart';
import 'package:shiv_physio_app/data/chat/model/conversation_last_message.dart';


/// Enhanced base model for conversations that includes rich participant data
class BaseConversationModel {
  final String id;
  final List<String> participantIds; // List of user references/IDs
  final List<BaseConversationParticipant> participantData; // Changed to List
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

  BaseConversationModel({
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

  // Create a copy with modified fields
  BaseConversationModel copyWith({
    String? id,
    List<String>? participantIds,
    List<BaseConversationParticipant>? participantData,
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
    return BaseConversationModel(
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
  BaseConversationParticipant? getParticipantData(String userId) {
    return participantData.firstWhere(
      (participant) => participant.userId == userId,
      // ignore: cast_from_null_always_fails
      orElse: () => null as BaseConversationParticipant, // This will cause a runtime error if no match is found
    );
  }

  // Safe version that returns null if participant not found
  BaseConversationParticipant? findParticipant(String userId) {
    try {
      return participantData.firstWhere(
        (participant) => participant.userId == userId,
      );
    } catch (_) {
      return null;
    }
  }

  // Get other participant IDs (excluding specified user)
  List<String> getOtherParticipantIds(String userId) {
    return participantIds.where((id) => id != userId).toList();
  }

  // Get other participants (excluding specified user)
  List<BaseConversationParticipant> getOtherParticipants(String userId) {
    return participantData.where((participant) => participant.userId != userId).toList();
  }

  // Check if a user has blocked another user
  bool hasUserBlocked(String userId, String otherUserId) {
    final participant = findParticipant(userId);
    if (participant == null) return false;
    return participant.hasBlockedUser(otherUserId);
  }

  // Check if a user is blocked by another user
  bool isUserBlockedBy(String userId, String otherUserId) {
    final otherParticipant = findParticipant(otherUserId);
    if (otherParticipant == null) return false;
    return otherParticipant.hasBlockedUser(userId);
  }

  // Get a list of users blocked by a specific user
  List<String> getUsersBlockedBy(String userId) {
    final participant = findParticipant(userId);
    if (participant == null) return [];
    return participant.blockedUsers;
  }

  // Check if a participant is typing
  bool isParticipantTyping(String userId) {
    final participant = findParticipant(userId);
    if (participant == null) return false;
    return participant.typingStatus;
  }

  // Get unread count for a specific user
  int getUnreadCountForUser(String userId) {
    final participant = findParticipant(userId);
    if (participant == null) return 0;
    return participant.unreadCount;
  }

  // Check if anyone is typing except the given user
  bool isAnyoneTyping(String exceptUserId) {
    return participantData.any(
      (participant) => participant.userId != exceptUserId && participant.typingStatus
    );
  }

  // Get conversation display name
  String getDisplayName(String currentUserId) {
    if (isGroupChat && title != null && title!.isNotEmpty) {
      return title!;
    }

    if (!isGroupChat) {
      final otherParticipant = getOtherParticipant(currentUserId);
      if (otherParticipant != null) {
        return otherParticipant.name;
      }
    }

    // Fallback
    if (isGroupChat) {
      return "Group (${participantIds.length} participants)";
    }

    return "Chat";
  }

  // Get the other participant in a 1:1 chat
  BaseConversationParticipant? getOtherParticipant(String currentUserId) {
    if (isGroupChat) return null;
    
    try {
      return participantData.firstWhere(
        (participant) => participant.userId != currentUserId
      );
    } catch (_) {
      return null;
    }
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
    final participant = findParticipant(userId);
    if (participant != null) {
      return participant.isAdmin();
    }

    return false;
  }

  // Check if user is a moderator
  bool isUserModerator(String userId) {
    final participant = findParticipant(userId);
    if (participant != null) {
      return participant.isModerator();
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
      final otherUserIds = getOtherParticipantIds(userId);
      if (otherUserIds.isNotEmpty) {
        final otherUserId = otherUserIds.first;
        if (hasUserBlocked(userId, otherUserId) ||
            isUserBlockedBy(userId, otherUserId)) {
          return false;
        }
      }
    }

    return true;
  }

  // Update a participant's data
  BaseConversationModel updateParticipant(BaseConversationParticipant updatedParticipant) {
    final newParticipantData = List<BaseConversationParticipant>.from(participantData);
    
    // Find the index of the participant to update
    final index = newParticipantData.indexWhere(
      (participant) => participant.userId == updatedParticipant.userId
    );
    
    if (index != -1) {
      // Replace the participant at that index
      newParticipantData[index] = updatedParticipant;
    } else {
      // Add as a new participant if not found
      newParticipantData.add(updatedParticipant);
    }
    
    return copyWith(participantData: newParticipantData);
  }
}