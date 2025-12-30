import 'dart:io';
import 'package:shiv_physio_app/data/chat/enum/chat_enums.dart';
import 'package:shiv_physio_app/data/chat/model/base_conversation_model.dart';
import 'package:shiv_physio_app/data/chat/model/chat_converation.dart';
import 'package:shiv_physio_app/data/chat/model/chat_message.dart';
import 'package:shiv_physio_app/data/chat/model/chat_user.dart';

/// Abstract class defining the chat client interface
/// This interface abstracts the underlying implementation details,
/// allowing for easy switching between different implementations (Firebase, REST API, etc.)
abstract class ChatConversationClient {
  /// Create a new conversation
  ///
  /// [participantIds] - List of user IDs who will be in the conversation
  /// [title] - Optional title for the conversation (required for group chats)
  /// [isGroupChat] - Whether this is a group chat or a 1:1 conversation
  /// [creatorId] - ID of the user creating the conversation (becomes admin for group chats)
  Future<ChatConversation> createConversation(
    List<String> participantIds, {
    String? title,
    bool isGroupChat = false,
    String? creatorId,
  });

  /// Send a message to a conversation
  ///
  /// [conversationId] - ID of the conversation
  /// [senderId] - ID of the message sender
  /// [senderName] - Name of the message sender
  /// [content] - Content of the message
  /// [type] - Type of message (text, image, etc.)
  /// [metadata] - Additional message metadata (e.g., file details)
  /// [senderProfileImage] - Optional profile image URL of the sender
  Future<ChatMessage> sendMessage(
    String conversationId,
    String senderId,
    String content, {
    required MessageType type,
    Map<String, dynamic>? metadata,
  });

  /// Get all conversations for a user
  ///
  /// [userId] - ID of the user
  Future<List<ChatConversation>> getConversationsForUser(String userId);

  /// Get a single conversation by ID
  ///
  /// [conversationId] - ID of the conversation to retrieve
  Future<ChatConversation> getConversationById(String conversationId);

  /// Get messages from a conversation with pagination
  ///
  /// [conversationId] - ID of the conversation
  /// [limit] - Maximum number of messages to retrieve
  /// [lastMessageId] - ID of the last message retrieved (for pagination)
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int limit = 20,
    String? lastMessageId,
  });

  /// Mark messages as read for a specific user
  ///
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user marking messages as read
  Future<void> markMessagesAsRead(String conversationId, String userId);

  /// Delete a message (soft delete)
  ///
  /// [conversationId] - ID of the conversation containing the message
  /// [messageId] - ID of the message to delete
  Future<void> deleteMessage(String conversationId, String messageId);

  /// Edit a message
  ///
  /// [conversationId] - ID of the conversation containing the message
  /// [messageId] - ID of the message to edit
  /// [newContent] - New content for the message
  Future<void> editMessage(
    String conversationId,
    String messageId,
    String newContent,
  );

  /// Delete a conversation
  ///
  /// [conversationId] - ID of the conversation to delete
  Future<void> deleteConversation(String conversationId);

  /// Get unread message count for a user in a specific conversation
  ///
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user
  Future<int> getUnreadMessageCount(String conversationId, String userId);

  /// Listen to new messages in a conversation (real-time)
  ///
  /// [conversationId] - ID of the conversation to listen to
  Stream<List<ChatMessage>> listenToMessages(String conversationId);

  /// Listen to conversation updates (real-time)
  ///
  /// [conversationId] - ID of the conversation to listen to
  Stream<ChatConversation> listenToConversation(String conversationId);

  /// Send a typing indicator
  ///
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user who is typing
  /// [isTyping] - Whether the user is currently typing
  Future<void> sendTypingIndicator(
    String conversationId,
    String userId,
    bool isTyping,
  );

  /// Update user's online status
  ///
  /// [userId] - ID of the user
  /// [isOnline] - Whether the user is currently online
  Future<void> updateOnlineStatus(String userId, bool isOnline);

  /// Upload a file to the conversation (image, document, etc.)
  ///
  /// [conversationId] - ID of the conversation
  /// [senderId] - ID of the user uploading the file
  /// [file] - The file to upload
  /// [fileName] - Name of the file
  /// [fileType] - MIME type of the file
  Future<String> uploadAttachment(
    String conversationId,
    String senderId,
    File file,
    String fileName,
    String fileType,
  );

  /// Block a user in a conversation
  ///
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user doing the blocking
  /// [blockedUserId] - ID of the user being blocked
  Future<void> blockUser(
    String conversationId,
    String userId,
    String blockedUserId,
  );

  /// Unblock a user in a conversation
  ///
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user doing the unblocking
  /// [blockedUserId] - ID of the user being unblocked
  Future<void> unblockUser(
    String conversationId,
    String userId,
    String blockedUserId,
  );

  /// Get list of blocked users for a user in a conversation
  ///
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user
  Future<List<String>> getBlockedUsers(String conversationId, String userId);

  /// Check if a user is blocked by another user
  ///
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user who might be blocked
  /// [otherUserId] - ID of the user who might have done the blocking
  Future<bool> isUserBlocked(
    String conversationId,
    String userId,
    String otherUserId,
  );

  /// Report a conversation or message
  ///
  /// [conversationId] - ID of the conversation
  /// [reportedBy] - ID of the user making the report
  /// [reason] - Reason for the report
  /// [type] - Type of report
  /// [messageId] - Optional ID of a specific message being reported
  /// [attachments] - Optional list of attachment URLs (screenshots, etc.)
  Future<void> reportConversation(
    String conversationId,
    String reportedBy,
    String reason,
    ReportType type, {
    String? messageId,
    List<String>? attachments,
  });

  /// Add a user to a group conversation
  ///
  /// [conversationId] - ID of the group conversation
  /// [userId] - ID of the user to add
  Future<void> addUserToGroup(String conversationId, String userId);

  /// Remove a user from a group conversation
  ///
  /// [conversationId] - ID of the group conversation
  /// [userId] - ID of the user to remove
  Future<void> removeUserFromGroup(String conversationId, String userId);

  /// Make a user admin of a group conversation
  ///
  /// [conversationId] - ID of the group conversation
  /// [userId] - ID of the user to make admin
  Future<void> makeUserAdmin(String conversationId, String userId);

  /// Update group conversation details
  ///
  /// [conversationId] - ID of the group conversation
  /// [title] - New title for the group
  /// [groupImage] - New image URL for the group
  Future<void> updateGroupDetails(
    String conversationId, {
    String? title,
    String? groupImage,
  });

  /// Leave a group conversation
  ///
  /// [conversationId] - ID of the group conversation
  /// [userId] - ID of the user leaving the group
  Future<void> leaveGroup(String conversationId, String userId);

  /// Get user details by ID
  ///
  /// [userId] - ID of the user to retrieve
  Future<ChatUser?> getUserById(String userId);

  /// Search for users
  ///
  /// [query] - Search query string (searches name and email)
  /// [limit] - Maximum number of results to return
  Future<List<ChatUser>> searchUsers(String query, {int limit = 10});

  /// Get total unread message count across all conversations
  ///
  /// [userId] - ID of the user
  Future<int> getTotalUnreadMessageCount(String userId);

  /// Add reaction to a message
  ///
  /// [conversationId] - ID of the conversation
  /// [messageId] - ID of the message
  /// [userId] - ID of the user adding the reaction
  /// [reaction] - Reaction string (emoji or code)
  Future<void> addReaction(
    String conversationId,
    String messageId,
    String userId,
    String reaction,
  );

  /// Remove reaction from a message
  ///
  /// [conversationId] - ID of the conversation
  /// [messageId] - ID of the message
  /// [userId] - ID of the user removing their reaction
  Future<void> removeReaction(
    String conversationId,
    String messageId,
    String userId,
  );

  /// Check User exists
  ///
  /// [userId] - ID of the user
  Future<bool> checkUserExists(String userId);

  /// Create User
  ///
  /// [userId] - ID of the user
  /// [name] - Name of the user
  /// [profileImage] - Optional profile image URL
  /// [typingStatus] - Whether the user is currently typing
  /// [lastActiveAt] - Last active timestamp
  /// [lastSeenAt] - Last seen timestamp
  Future<ChatUser> createUser(
    String userId,
    String name, {
    String? profileImage,
    DateTime? lastActiveAt,
    DateTime? lastSeenAt,
  });

  /// Update User all are optional
  ///
  /// [userId] - ID of the user
  /// [name] - Name of the user
  /// [profileImage] - Optional profile image URL
  /// [typingStatus] - Whether the user is currently typing
  /// [lastActiveAt] - Last active timestamp
  /// [lastSeenAt] - Last seen timestamp
  Future<ChatUser> updateUser(
    String userId, {
    String? name,
    String? profileImage,
    bool? typingStatus,
    DateTime? lastActiveAt,
    DateTime? lastSeenAt,
  });

  /// Get a list of chat users by their IDs
  ///
  /// [userIds] - List of user IDs to fetch
  Future<Map<String, ChatUser>> getChatUsersByIds(List<String> userIds);

  /// Get a BaseConversationModel for a conversation
  ///
  /// [conversationId] - ID of the conversation
  /// [availableChatUsers] - Optional map of already available chat users
  Future<BaseConversationModel> getBaseConversationModel(
    String conversationId, {
    Map<String, ChatUser>? availableChatUsers,
  });

  /// Get a list of BaseConversationModel for all conversations of a user
  ///
  /// [userId] - ID of the user
  /// [availableChatUsers] - Optional map of already available chat users
  Future<List<BaseConversationModel>> getAllBaseConversationModels(
    String userId, {
    Map<String, ChatUser>? availableChatUsers,
  });

  /// Listen to conversation updates and return BaseConversationModel
  ///
  /// [conversationId] - ID of the conversation to listen to
  /// [availableChatUsers] - Optional map of already available chat users
  Stream<BaseConversationModel> listenToBaseConversationModel(
    String conversationId, {
    Map<String, ChatUser>? availableChatUsers,
  });

  /// Listen to all conversations for a user and return a stream of BaseConversationModel list
  ///
  /// [userId] - ID of the user
  /// [availableChatUsers] - Optional map of already available chat users
  Stream<List<BaseConversationModel>> listenToAllBaseConversationModels(
    String userId, {
    Map<String, ChatUser>? availableChatUsers,
  });

  /// Download file from a message
  ///
  /// [fileUrl] - URL of the file to download
  /// [fileName] - Name to save the file as
  /// [customPath] - Optional custom path to save file to
  Future<File?> downloadFile({
    required String fileUrl,
    required String fileName,
    String? customPath,
  });
}



// List of all methods in the ChatConversationClient interface

