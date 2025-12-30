import 'package:shiv_physio_app/data/base_class/base_repository.dart';
import 'package:shiv_physio_app/data/chat/chat_provider.dart';
import 'package:shiv_physio_app/data/chat/enum/chat_enums.dart';
import 'package:shiv_physio_app/data/chat/model/base_conversation_model.dart';
import 'package:shiv_physio_app/data/chat/model/chat_converation.dart';
import 'package:shiv_physio_app/data/chat/model/chat_message.dart';
import 'package:shiv_physio_app/data/service/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

/// Repository for managing chat functionality
/// Follows clean architecture pattern - all business logic here
class ChatRepository extends BaseRepository {
  final ChatConversationClient _chatClient;
  final StorageService _storageService;
  final SupabaseClient _supabase;

  ChatRepository({
    required ChatConversationClient chatClient,
    required StorageService storageService,
    required SupabaseClient supabase,
  }) : _chatClient = chatClient,
       _storageService = storageService,
       _supabase = supabase;

  /// Get current user ID from storage
  String? _getCurrentUserId() {
    final user = _storageService.getUser();
    return user?.id;
  }

  /// Get or create a direct conversation with another user
  Future<ChatConversation> getOrCreateDirectConversation(
    String otherUserId,
  ) async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      logD('Getting or creating conversation with: $otherUserId');

      // Get all conversations for current user
      final conversations = await _chatClient.getConversationsForUser(
        currentUserId,
      );

      // Check if conversation already exists
      for (final conversation in conversations) {
        if (!conversation.isGroupChat &&
            conversation.participantIds.length == 2 &&
            conversation.participantIds.contains(currentUserId) &&
            conversation.participantIds.contains(otherUserId)) {
          logD('Found existing conversation: ${conversation.id}');
          return conversation;
        }
      }

      // Create new conversation
      logD('Creating new conversation');
      return await _chatClient.createConversation(
        [currentUserId, otherUserId],
        isGroupChat: false,
        creatorId: currentUserId,
      );
    } catch (e) {
      logE('Error getting or creating conversation', error: e);
      handleRepositoryError(e);
    }
  }

  /// Get all conversations for current user
  Future<List<BaseConversationModel>> getConversations() async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      logD('Fetching conversations for user: $currentUserId');
      final conversations = await _chatClient.getAllBaseConversationModels(
        currentUserId,
      );
      logI('Fetched ${conversations.length} conversations');
      return conversations;
    } catch (e) {
      logE('Error fetching conversations', error: e);
      handleRepositoryError(e);
    }
  }

  /// Listen to conversations for current user (real-time)
  Stream<List<BaseConversationModel>> listenToConversations() {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      logD('Listening to conversations for user: $currentUserId');
      return _chatClient.listenToAllBaseConversationModels(currentUserId);
    } catch (e) {
      logE('Error listening to conversations', error: e);
      handleRepositoryError(e);
    }
  }

  /// Get messages for a conversation
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int limit = 50,
    String? lastMessageId,
  }) async {
    try {
      logD('Fetching messages for conversation: $conversationId');
      final messages = await _chatClient.getMessages(
        conversationId,
        limit: limit,
        lastMessageId: lastMessageId,
      );
      logI('Fetched ${messages.length} messages');
      return messages;
    } catch (e) {
      logE('Error fetching messages', error: e);
      handleRepositoryError(e);
    }
  }

  /// Listen to messages in a conversation (real-time)
  Stream<List<ChatMessage>> listenToMessages(String conversationId) {
    try {
      logD('Listening to messages for conversation: $conversationId');
      return _chatClient.listenToMessages(conversationId);
    } catch (e) {
      logE('Error listening to messages', error: e);
      handleRepositoryError(e);
    }
  }

  /// Send a text message
  Future<ChatMessage> sendTextMessage(
    String conversationId,
    String content,
  ) async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      logD('Sending text message to conversation: $conversationId');
      final message = await _chatClient.sendMessage(
        conversationId,
        currentUserId,
        content,
        type: MessageType.text,
      );
      logI('Message sent successfully: ${message.id}');
      return message;
    } catch (e) {
      logE('Error sending message', error: e);
      handleRepositoryError(e);
    }
  }

  /// Send an image message
  Future<ChatMessage> sendImageMessage(
    String conversationId,
    File imageFile,
  ) async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      logD('Sending image message to conversation: $conversationId');

      // Upload image first
      final imageUrl = await _chatClient.uploadAttachment(
        conversationId,
        currentUserId,
        imageFile,
        imageFile.path.split('/').last,
        'image/jpeg',
      );

      // Send message with image URL
      final message = await _chatClient.sendMessage(
        conversationId,
        currentUserId,
        imageUrl,
        type: MessageType.image,
        metadata: {
          'fileName': imageFile.path.split('/').last,
          'fileSize': await imageFile.length(),
          'mimeType': 'image/jpeg',
        },
      );

      logI('Image message sent successfully: ${message.id}');
      return message;
    } catch (e) {
      logE('Error sending image message', error: e);
      handleRepositoryError(e);
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      logD('Marking messages as read for conversation: $conversationId');
      await _chatClient.markMessagesAsRead(conversationId, currentUserId);
      logI('Messages marked as read');
    } catch (e) {
      logE('Error marking messages as read', error: e);
      handleRepositoryError(e);
    }
  }

  /// Get unread message count for a conversation
  Future<int> getUnreadCount(String conversationId) async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        return 0;
      }

      return await _chatClient.getUnreadMessageCount(
        conversationId,
        currentUserId,
      );
    } catch (e) {
      logE('Error getting unread count', error: e);
      return 0;
    }
  }

  /// Get total unread message count across all conversations
  Future<int> getTotalUnreadCount() async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        return 0;
      }

      return await _chatClient.getTotalUnreadMessageCount(currentUserId);
    } catch (e) {
      logE('Error getting total unread count', error: e);
      return 0;
    }
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator(String conversationId, bool isTyping) async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        return;
      }

      await _chatClient.sendTypingIndicator(
        conversationId,
        currentUserId,
        isTyping,
      );
    } catch (e) {
      logE('Error sending typing indicator', error: e);
      // Don't throw - typing indicator is not critical
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String conversationId, String messageId) async {
    try {
      logD('Deleting message: $messageId');
      await _chatClient.deleteMessage(conversationId, messageId);
      logI('Message deleted successfully');
    } catch (e) {
      logE('Error deleting message', error: e);
      handleRepositoryError(e);
    }
  }

  /// Get conversation by ID
  Future<BaseConversationModel> getConversation(String conversationId) async {
    try {
      logD('Fetching conversation: $conversationId');
      final conversation = await _chatClient.getBaseConversationModel(
        conversationId,
      );
      logI('Conversation fetched successfully');
      return conversation;
    } catch (e) {
      logE('Error fetching conversation', error: e);
      handleRepositoryError(e);
    }
  }

  /// Listen to conversation updates (real-time)
  Stream<BaseConversationModel> listenToConversation(String conversationId) {
    try {
      logD('Listening to conversation: $conversationId');
      return _chatClient.listenToBaseConversationModel(conversationId);
    } catch (e) {
      logE('Error listening to conversation', error: e);
      handleRepositoryError(e);
    }
  }

  /// Get the doctor ID using Supabase function
  Future<String?> getDoctorId() async {
    try {
      logD('Fetching doctor ID');
      final doctorIdResponse = await _supabase.rpc('get_doctor_id');
      final doctorId = doctorIdResponse?.toString();

      if (doctorId == null || doctorId.isEmpty) {
        logW('No doctor ID found');
        return null;
      }

      logI('Doctor ID fetched: $doctorId');
      return doctorId;
    } catch (e) {
      logE('Error fetching doctor ID', error: e);
      return null;
    }
  }

  /// Get or create conversation with doctor for current user
  /// Also ensures ChatUser records exist for both user and doctor
  Future<ChatConversation> getOrCreateDoctorConversation() async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      final doctorId = await getDoctorId();
      if (doctorId == null) {
        throw Exception('Doctor not found');
      }

      // Ensure ChatUser records exist for both users
      await _ensureChatUsersExist([currentUserId, doctorId]);

      logD('Getting or creating conversation with doctor: $doctorId');
      return await getOrCreateDirectConversation(doctorId);
    } catch (e) {
      logE('Error getting or creating doctor conversation', error: e);
      handleRepositoryError(e);
      rethrow;
    }
  }

  /// Get or create a conversation with a patient (for doctors)
  /// Also ensures ChatUser records exist for both doctor and patient
  Future<ChatConversation> getOrCreatePatientConversation(
    String patientId,
  ) async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      if (patientId.isEmpty) {
        throw Exception('Patient ID is required');
      }

      // Ensure ChatUser records exist for both users
      await _ensureChatUsersExist([currentUserId, patientId]);

      logD('Getting or creating conversation with patient: $patientId');
      return await getOrCreateDirectConversation(patientId);
    } catch (e) {
      logE('Error getting or creating patient conversation', error: e);
      handleRepositoryError(e);
      rethrow;
    }
  }

  /// Ensure ChatUser records exist in Firebase for the given user IDs
  /// Fetches user data from Supabase and creates/updates ChatUser in Firebase
  Future<void> _ensureChatUsersExist(List<String> userIds) async {
    try {
      for (final userId in userIds) {
        // Check if ChatUser exists
        final userExists = await _chatClient.checkUserExists(userId);

        if (!userExists) {
          // Fetch user data from Supabase
          final userData = await _getUserDataFromSupabase(userId);

          if (userData != null) {
            // Create ChatUser in Firebase
            await _chatClient.createUser(
              userId,
              userData['name'] ?? 'User',
              profileImage: userData['avatar_url'],
              lastActiveAt: DateTime.now(),
            );
            logD('Created ChatUser for: $userId');
          } else {
            // Fallback: create with minimal data
            await _chatClient.createUser(
              userId,
              'User',
              lastActiveAt: DateTime.now(),
            );
            logW('Created ChatUser with fallback name for: $userId');
          }
        } else {
          // Update existing user if needed (to sync name/avatar from Supabase)
          final userData = await _getUserDataFromSupabase(userId);
          if (userData != null) {
            await _chatClient.updateUser(
              userId,
              name: userData['name'],
              profileImage: userData['avatar_url'],
            );
            logD('Updated ChatUser for: $userId');
          }
        }
      }
    } catch (e) {
      logE('Error ensuring ChatUsers exist', error: e);
      // Don't throw - this is not critical, conversation can still be created
    }
  }

  /// Get user data from Supabase
  Future<Map<String, dynamic>?> _getUserDataFromSupabase(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('full_name, avatar_url')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        logW('User not found in Supabase: $userId');
        return null;
      }

      final fullName = response['full_name'] as String?;
      final avatarUrl = response['avatar_url'] as String?;

      // Use full_name if available, otherwise use a default name
      final name = fullName?.trim();
      if (name == null || name.isEmpty) {
        logW('User has no full_name in Supabase: $userId');
        return {
          'name': 'User', // Fallback name
          'avatar_url': avatarUrl,
        };
      }

      return {'name': name, 'avatar_url': avatarUrl};
    } catch (e) {
      logE('Error fetching user data from Supabase', error: e);
      return null;
    }
  }
}
