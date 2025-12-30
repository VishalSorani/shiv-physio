import 'dart:developer';
import 'package:shiv_physio_app/data/chat/model/base_conversation_model.dart';
import 'package:shiv_physio_app/data/chat/model/base_conversation_participant.dart';
import 'package:shiv_physio_app/data/chat/model/chat_converation.dart';
import 'package:shiv_physio_app/data/chat/model/chat_conversation_participant.dart';
import 'package:shiv_physio_app/data/chat/model/chat_user.dart';


/// Factory class to handle creating enriched conversation models from Firebase data
class FirebaseDataFactory {
  
  /// Convert a Firebase conversation to a base conversation model with user data
  static BaseConversationModel createBaseConversation(
    ChatConversation conversation,
    Map<String, ChatUser> users
  ) {
    try {
      // Create participant data with available user information
      final List<BaseConversationParticipant> participantData = [];
      
      for (final userId in conversation.participantIds) {
        // Get the conversation participant data
        final ConversationParticipant? participant = conversation.participantData[userId];
        
        // Get the user data if available
        final ChatUser? user = users[userId];
        
        if (participant != null) {
          participantData.add(
            BaseConversationParticipant(
              userId: userId,
              name: user?.name ?? "User $userId", // Use user name if available, otherwise fallback
              profileImage: user?.profileImage,
              typingStatus: participant.typingStatus,
              lastActiveAt: user?.lastActiveAt ?? DateTime.now(),
              lastSeenAt: participant.lastSeenAt,
              unreadCount: participant.unreadCount,
              blockedUsers: participant.blockedUsers,
              role: participant.role,
            )
          );
        }
      }
      
      return BaseConversationModel(
        id: conversation.id,
        participantIds: conversation.participantIds,
        participantData: participantData,
        title: conversation.title,
        createdAt: conversation.createdAt,
        lastMessage: conversation.lastMessage,
        isGroupChat: conversation.isGroupChat,
        adminId: conversation.adminId,
        groupImage: conversation.groupImage,
        isReported: conversation.isReported,
        reportReason: conversation.reportReason,
        reportedAt: conversation.reportedAt,
        reportedBy: conversation.reportedBy,
      );
      
    } catch (e) {
      log('Error creating base conversation: $e');
      // Create a minimal fallback model
      return BaseConversationModel(
        id: conversation.id,
        participantIds: conversation.participantIds,
        participantData: [],
        createdAt: conversation.createdAt,
        isGroupChat: conversation.isGroupChat,
      );
    }
  }
  
  /// Create a list of base conversation models from a list of ChatConversation
  static List<BaseConversationModel> createBaseConversations(
    List<ChatConversation> conversations,
    Map<String, ChatUser> users
  ) {
    final List<BaseConversationModel> result = [];
    
    for (final conversation in conversations) {
      result.add(createBaseConversation(conversation, users));
    }
    
    return result;
  }
  
  /// Update a base conversation model with updated conversation data
  static BaseConversationModel updateBaseConversation(
    BaseConversationModel baseConversation,
    ChatConversation updatedConversation
  ) {
    try {
      // Keep the existing participant data (with rich user info)
      final List<BaseConversationParticipant> updatedParticipantData = 
          List.from(baseConversation.participantData);
      
      // Update participant data based on the conversation update
      for (final userId in updatedConversation.participantIds) {
        final ConversationParticipant? updatedParticipant = 
            updatedConversation.participantData[userId];
        
        if (updatedParticipant != null) {
          // Find the existing participant in our list
          final int existingIndex = updatedParticipantData.indexWhere(
            (p) => p.userId == userId
          );
          
          if (existingIndex >= 0) {
            // Update the existing participant
            final existingParticipant = updatedParticipantData[existingIndex];
            updatedParticipantData[existingIndex] = existingParticipant.copyWith(
              typingStatus: updatedParticipant.typingStatus,
              lastSeenAt: updatedParticipant.lastSeenAt,
              unreadCount: updatedParticipant.unreadCount,
              blockedUsers: updatedParticipant.blockedUsers,
              role: updatedParticipant.role,
            );
          } else {
            // This is a new participant - add with minimal data
            updatedParticipantData.add(
              BaseConversationParticipant(
                userId: userId,
                name: "User $userId",
                typingStatus: updatedParticipant.typingStatus,
                lastActiveAt: DateTime.now(),
                lastSeenAt: updatedParticipant.lastSeenAt,
                unreadCount: updatedParticipant.unreadCount,
                blockedUsers: updatedParticipant.blockedUsers,
                role: updatedParticipant.role,
              )
            );
          }
        }
      }
      
      // Create updated base conversation model
      return BaseConversationModel(
        id: updatedConversation.id,
        participantIds: updatedConversation.participantIds,
        participantData: updatedParticipantData,
        title: updatedConversation.title ?? baseConversation.title,
        createdAt: updatedConversation.createdAt,
        lastMessage: updatedConversation.lastMessage,
        isGroupChat: updatedConversation.isGroupChat,
        adminId: updatedConversation.adminId,
        groupImage: updatedConversation.groupImage,
        isReported: updatedConversation.isReported,
        reportReason: updatedConversation.reportReason,
        reportedAt: updatedConversation.reportedAt,
        reportedBy: updatedConversation.reportedBy,
      );
    } catch (e) {
      log('Error updating base conversation: $e');
      return baseConversation;
    }
  }
}