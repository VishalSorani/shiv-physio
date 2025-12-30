import 'dart:developer';
import 'package:shiv_physio_app/data/chat/model/base_conversation_model.dart';
import 'package:shiv_physio_app/data/chat/model/base_conversation_participant.dart';
import 'package:shiv_physio_app/data/chat/model/chat_converation.dart';
import 'package:shiv_physio_app/data/chat/model/chat_conversation_participant.dart';
import 'package:shiv_physio_app/data/chat/model/chat_user.dart';



/// Factory class to handle merging Firebase data into our enhanced base models
class FirebaseFactory {
  
  /// Analyze a conversation and determine which user IDs need to be fetched
  static List<String> getMissingUserIds(
    ChatConversation conversation,
    Map<String, ChatUser> existingUsers
  ) {
    final List<String> missingUserIds = [];
    
    for (final userId in conversation.participantIds) {
      if (!existingUsers.containsKey(userId)) {
        missingUserIds.add(userId);
      }
    }
    
    return missingUserIds;
  }
  
  /// Convert a Firebase conversation to a base conversation model 
  /// with the available user data
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
  
  /// Update a base conversation model with new user data
  static BaseConversationModel updateBaseConversationWithUsers(
    BaseConversationModel baseConversation,
    Map<String, ChatUser> additionalUsers
  ) {
    try {
      // Create a copy of existing participant data
      final List<BaseConversationParticipant> updatedParticipantData = 
          List.from(baseConversation.participantData);
      
      // Update participant data with new user information
      for (final userId in baseConversation.participantIds) {
        // Get additional user data if available
        final ChatUser? user = additionalUsers[userId];
        
        if (user != null) {
          // Find existing participant
          final int participantIndex = updatedParticipantData.indexWhere(
            (participant) => participant.userId == userId
          );
          
          if (participantIndex >= 0) {
            // Update existing participant with user data
            final existingParticipant = updatedParticipantData[participantIndex];
            updatedParticipantData[participantIndex] = existingParticipant.copyWith(
              name: user.name,
              profileImage: user.profileImage,
              lastActiveAt: user.lastActiveAt,
            );
          } else {
            // Create new participant with default values
            updatedParticipantData.add(
              BaseConversationParticipant(
                userId: userId,
                name: user.name,
                profileImage: user.profileImage,
                typingStatus: false,
                lastActiveAt: user.lastActiveAt,
                unreadCount: 0,
                blockedUsers: [],
              )
            );
          }
        }
      }
      
      // Create an updated base conversation
      return baseConversation.copyWith(
        participantData: updatedParticipantData,
      );
      
    } catch (e) {
      log('Error updating base conversation: $e');
      return baseConversation;
    }
  }
  
  /// Merge a conversation update with an existing base conversation model
  static BaseConversationModel mergeConversationUpdate(
    BaseConversationModel existingBase,
    ChatConversation updatedConversation,
    Map<String, ChatUser> users
  ) {
    try {
      // First create a copy of participant data
      final List<BaseConversationParticipant> mergedParticipantData = 
          List.from(existingBase.participantData);
      
      // Update participant data based on conversation update
      for (final userId in updatedConversation.participantIds) {
        final ConversationParticipant? updatedParticipant = 
            updatedConversation.participantData[userId];
        
        if (updatedParticipant != null) {
          // Find index of existing participant
          final int participantIndex = mergedParticipantData.indexWhere(
            (participant) => participant.userId == userId
          );
          
          // Get user data
          final ChatUser? user = users[userId];
          
          if (participantIndex >= 0) {
            // Update existing participant
            final existingBaseParticipant = mergedParticipantData[participantIndex];
            mergedParticipantData[participantIndex] = existingBaseParticipant.copyWith(
              typingStatus: updatedParticipant.typingStatus,
              lastSeenAt: updatedParticipant.lastSeenAt,
              unreadCount: updatedParticipant.unreadCount,
              blockedUsers: updatedParticipant.blockedUsers,
              role: updatedParticipant.role,
            );
          } else if (user != null) {
            // Create new participant with user data
            mergedParticipantData.add(
              BaseConversationParticipant(
                userId: userId,
                name: user.name,
                profileImage: user.profileImage,
                typingStatus: updatedParticipant.typingStatus,
                lastActiveAt: user.lastActiveAt,
                lastSeenAt: updatedParticipant.lastSeenAt,
                unreadCount: updatedParticipant.unreadCount,
                blockedUsers: updatedParticipant.blockedUsers,
                role: updatedParticipant.role,
              )
            );
          } else {
            // Create new participant with limited data
            mergedParticipantData.add(
              BaseConversationParticipant(
                userId: userId,
                name: "User $userId", // Default name
                profileImage: null,
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
      
      // Create an updated base conversation
      return BaseConversationModel(
        id: updatedConversation.id,
        participantIds: updatedConversation.participantIds,
        participantData: mergedParticipantData,
        title: updatedConversation.title ?? existingBase.title,
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
      log('Error merging conversation update: $e');
      return existingBase;
    }
  }
}