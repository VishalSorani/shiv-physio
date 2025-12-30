// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shiv_physio_app/data/chat/chat_provider.dart';
import 'package:shiv_physio_app/data/chat/enum/chat_enums.dart';
import 'package:shiv_physio_app/data/chat/helper/firebase_data_factory.dart';
import 'package:shiv_physio_app/data/chat/model/base_conversation_model.dart';
import 'package:shiv_physio_app/data/chat/model/chat_converation.dart';
import 'package:shiv_physio_app/data/chat/model/chat_conversation_participant.dart';
import 'package:shiv_physio_app/data/chat/model/chat_message.dart';
import 'package:shiv_physio_app/data/chat/model/chat_report.dart';
import 'package:shiv_physio_app/data/chat/model/chat_user.dart';
import 'package:shiv_physio_app/data/chat/model/conversation_last_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:external_path/external_path.dart';

/// Implementation of the chat client using Firebase services (Firestore and Storage)
class FirebaseChatClient extends ChatConversationClient {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection path constants
  static const String COLLECTION_CONVERSATIONS = 'conversations';
  static const String COLLECTION_MESSAGES = 'messages';
  static const String COLLECTION_REPORTS = 'reports';
  static const String COLLECTION_USERS = 'users';

  // Firebase current user id
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Collection references
  CollectionReference get _conversationsCollection =>
      _firestore.collection(COLLECTION_CONVERSATIONS);

  CollectionReference _messagesCollection(String conversationId) =>
      _firestore.collection(
          '$COLLECTION_CONVERSATIONS/$conversationId/$COLLECTION_MESSAGES');

  CollectionReference get _reportsCollection =>
      _firestore.collection(COLLECTION_REPORTS);

  CollectionReference get _usersCollection =>
      _firestore.collection(COLLECTION_USERS);

  // Check if the user is logged in
  bool get isLoggedIn => currentUserId != null;

  /// Ensure user is logged in or throw error
  void _checkLoggedIn() {
    if (!isLoggedIn) {
      throw Exception('User is not logged in');
    }
  }

  /// Generate a unique document ID
  String _generateId() {
    return FirebaseFirestore.instance
        .collection(COLLECTION_CONVERSATIONS)
        .doc()
        .id;
  }

  /// Create a new conversation
  @override
  Future<ChatConversation> createConversation(
    List<String> participantIds, {
    String? title,
    bool isGroupChat = false,
    String? creatorId,
  }) async {
    try {
      _checkLoggedIn();

      // For 1:1 chats, check if a conversation already exists with these exact participants
      if (!isGroupChat && participantIds.length == 2) {
        final existingConversations = await _conversationsCollection
            .where('participantIds', arrayContainsAny: participantIds)
            .get();

        for (final doc in existingConversations.docs) {
          final List<dynamic> participants = doc['participantIds'];

          // Check if this is a conversation with exactly these two participants
          if (participants.length == 2 &&
              participants.contains(participantIds[0]) &&
              participants.contains(participantIds[1])) {
            // Return the existing conversation
            return ChatConversation.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });
          }
        }
      }

      // Create a new conversation
      final conversationId = _generateId();
      final now = DateTime.now();

      // Initialize participant data
      Map<String, Map<String, dynamic>> participantDataMap = {};

      for (final userId in participantIds) {
        // Check if this user is the creator (admin for group chats)
        ParticipantRole role = ParticipantRole.member;
        if (isGroupChat && userId == creatorId) {
          role = ParticipantRole.admin;
        }

        // Create participant data
        final participant = ConversationParticipant(
          userId: userId,
          unreadCount: 0,
          lastSeenAt: now,
          typingStatus: false,
          blockedUsers: [],
          role: role,
        );

        participantDataMap[userId] = participant.toJson();
      }

      // Create conversation object
      final conversation = ChatConversation(
        id: conversationId,
        participantIds: participantIds,
        participantData: participantDataMap.map((key, value) =>
            MapEntry(key, ConversationParticipant.fromJson(value))),
        title: title,
        createdAt: now,
        lastMessage: null,
        isGroupChat: isGroupChat,
        adminId: isGroupChat ? creatorId : null,
        groupImage: null,
        isReported: false,
      );

      // Save to Firestore
      await _conversationsCollection
          .doc(conversationId)
          .set(conversation.toJson());

      return conversation;
    } catch (e) {
      log('Error creating conversation: $e');
      rethrow;
    }
  }

  /// Send a message to a conversation
  @override
  Future<ChatMessage> sendMessage(
    String conversationId,
    String senderId,
    String content, {
    required MessageType type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _checkLoggedIn();

      // Get the conversation to check permissions and update it afterward
      final conversationDoc =
          await _conversationsCollection.doc(conversationId).get();

      if (!conversationDoc.exists) {
        throw Exception('Conversation not found');
      }

      final conversation = ChatConversation.fromJson({
        'id': conversationDoc.id,
        ...conversationDoc.data() as Map<String, dynamic>,
      });

      // Check if the sender is a participant
      if (!conversation.hasParticipant(senderId)) {
        throw Exception('User is not a participant in this conversation');
      }

      // Check if user is blocked (for 1:1 chats)
      if (!conversation.isGroupChat &&
          conversation.participantIds.length == 2) {
        final otherUserId =
            conversation.getOtherParticipantIds(senderId).firstOrNull;

        if (otherUserId != null) {
          if (conversation.hasUserBlocked(otherUserId, senderId)) {
            throw Exception('You have been blocked by the other user');
          }

          if (conversation.hasUserBlocked(senderId, otherUserId)) {
            throw Exception('You have blocked this user');
          }
        }
      }

      // For group chats, check if the user has appropriate permissions
      if (conversation.isGroupChat) {
        final participantData = conversation.getParticipantData(senderId);

        if (participantData != null) {
          final role = participantData.role;
          if (role.isSendingRestricted()) {
            throw Exception(
                'You do not have permission to send messages in this group');
          }
        }
      }

      // Create new message
      final messageId = _generateId();
      final now = DateTime.now();

      // Initialize read status (sender has read their own message)
      Map<String, dynamic> readStatus = {};
      readStatus[senderId] = now.millisecondsSinceEpoch;

      // Create message object
      final message = ChatMessage(
        id: messageId,
        conversationId: conversationId,
        senderId: senderId,
        content: content,
        type: type,
        timestamp: now,
        readStatus: readStatus,
        metadata: metadata,
      );

      // Save message
      await _messagesCollection(conversationId)
          .doc(messageId)
          .set(message.toJson());

      // Create last message object for conversation
      final lastMessage = LastMessage(
        messageId: messageId,
        senderId: senderId,
        content: content,
        type: type,
        timestamp: now,
      );

      // Update conversation with last message
      final batch = _firestore.batch();
      final conversationRef = _conversationsCollection.doc(conversationId);

      // Update last message
      batch.update(conversationRef, {
        'lastMessage': lastMessage.toJson(),
      });

      // Increment unread count for all other participants
      for (final participantId in conversation.participantIds) {
        if (participantId != senderId) {
          batch.update(conversationRef, {
            'participantData.$participantId.unreadCount':
                FieldValue.increment(1),
          });
        }
      }

      // Commit the batch
      await batch.commit();

      return message;
    } catch (e) {
      log('Error sending message: $e');
      rethrow;
    }
  }

  /// Get all conversations for a user
  @override
  Future<List<ChatConversation>> getConversationsForUser(String userId) async {
    try {
      _checkLoggedIn();

      final querySnapshot = await _conversationsCollection
          .where('participantIds', arrayContains: userId)
          // .orderBy('lastMessage.timestamp', descending: true)
          .get();

      var aa = querySnapshot.docs.map((doc) {
        return ChatConversation.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();

      return aa;
    } catch (e) {
      log('Error getting conversations: $e');
      rethrow;
    }
  }

  /// Get a single conversation by ID
  @override
  Future<ChatConversation> getConversationById(String conversationId) async {
    try {
      _checkLoggedIn();

      final docSnapshot =
          await _conversationsCollection.doc(conversationId).get();

      if (!docSnapshot.exists) {
        throw Exception('Conversation not found');
      }

      return ChatConversation.fromJson({
        'id': docSnapshot.id,
        ...docSnapshot.data() as Map<String, dynamic>,
      });
    } catch (e) {
      log('Error getting conversation: $e');
      rethrow;
    }
  }

  /// Get messages from a conversation with pagination
  @override
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int limit = 20,
    String? lastMessageId,
  }) async {
    try {
      _checkLoggedIn();

      Query query = _messagesCollection(conversationId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (lastMessageId != null) {
        // Get the document snapshot for the last message ID
        final lastMessageDoc =
            await _messagesCollection(conversationId).doc(lastMessageId).get();

        if (lastMessageDoc.exists) {
          query = query.startAfterDocument(lastMessageDoc);
        }
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        return ChatMessage.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    } catch (e) {
      log('Error getting messages: $e');
      rethrow;
    }
  }

  /// Mark messages as read for a specific user
  @override
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      _checkLoggedIn();

      // Create a batch to perform multiple operations
      final batch = _firestore.batch();

      // Get unread messages
      // final unreadMessages = await _messagesCollection(conversationId)
      //     .where('readStatus.$userId', isNull: true)
      //     .get();

      // if (unreadMessages.docs.isEmpty) {
      //   log('No unread messages found for user $userId in conversation $conversationId');
      //   return;
      // }
      // // check which message is unread (my id not in readStatus)
      // final unreadMessageIds = unreadMessages.docs
      //     .where((doc) => !(doc.data() as Map<String, dynamic>)
      //         .containsKey('readStatus.$userId'))
      //     .map((doc) => doc.id)
      //     .toList();

      // // Mark each message as read
      // final now = DateTime.now();
      // final timestamp = now.millisecondsSinceEpoch;

      // // Update the read status for each unread message
      // for (final messageId in unreadMessageIds) {
      //   batch.update(_messagesCollection(conversationId).doc(messageId), {
      //     'readStatus.$userId': timestamp,
      //   });
      // }
      // Get all messages in the conversation
      final messagesSnapshot = await _messagesCollection(conversationId)
          .orderBy('timestamp', descending: true)
          .get();

      // Filter messages where readStatus doesn't contain userId or readStatus doesn't exist
      final unreadMessages = messagesSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final readStatus = data['readStatus'] as Map<String, dynamic>?;
        return readStatus == null || !readStatus.containsKey(userId);
      }).toList();

      if (unreadMessages.isEmpty) {
        log('No unread messages found for user $userId in conversation $conversationId');
        return;
      }

      // Mark each message as read
      final now = DateTime.now();
      final timestamp = now.millisecondsSinceEpoch;

      for (final doc in unreadMessages) {
        batch.update(doc.reference, {
          'readStatus.$userId': timestamp,
        });
      }

      // for (final doc in unreadMessages.docs) {
      //   batch.update(doc.reference, {
      //     'readStatus.$userId': timestamp,
      //   });
      // }

      // Reset unread count for the user
      batch.update(_conversationsCollection.doc(conversationId), {
        'participantData.$userId.unreadCount': 0,
        'participantData.$userId.lastSeenAt': now,
      });

      // // Commit the batch
      await batch.commit();
    } catch (e) {
      log('Error marking messages as read: $e');
      rethrow;
    }
  }

  /// Delete a message (soft delete)
  @override
  Future<void> deleteMessage(String conversationId, String messageId) async {
    try {
      _checkLoggedIn();

      // Get the message to check permissions
      final messageDoc =
          await _messagesCollection(conversationId).doc(messageId).get();

      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      final message = ChatMessage.fromJson({
        'id': messageDoc.id,
        ...messageDoc.data() as Map<String, dynamic>,
      });

      // Check if the current user is the sender or has admin rights
      final userId = currentUserId!;
      final conversation = await getConversationById(conversationId);

      if (message.senderId != userId &&
          !conversation.canUserAdminister(userId)) {
        throw Exception('You do not have permission to delete this message');
      }

      // Soft delete the message
      await _messagesCollection(conversationId).doc(messageId).update({
        'isDeleted': true,
        'content': '',
        'metadata': {},
      });

      // If this was the last message, update the conversation
      if (conversation.lastMessage?.messageId == messageId) {
        await _updateLastMessageAfterDeletion(conversationId, messageId);
      }
    } catch (e) {
      log('Error deleting message: $e');
      rethrow;
    }
  }

  /// Helper method to update the last message after deletion
  Future<void> _updateLastMessageAfterDeletion(
      String conversationId, String messageId) async {
    try {
      // Find the previous message
      final previousMessages = await _messagesCollection(conversationId)
          .orderBy('timestamp', descending: true)
          .limit(
              2) // Get two messages because one might be the one we just deleted
          .get();

      if (previousMessages.docs.length > 1) {
        // Get the second message (which is the previous one)
        var newLastMessage = previousMessages.docs[1];

        // Check if this is the deleted message
        if (newLastMessage.id == messageId) {
          newLastMessage = previousMessages.docs[0];
        }

        // Create LastMessage object from the document
        final message = ChatMessage.fromJson({
          'id': newLastMessage.id,
          ...newLastMessage.data() as Map<String, dynamic>,
        });

        // Create new LastMessage
        final lastMessage = LastMessage(
          messageId: message.id,
          senderId: message.senderId,
          content: message.isDeleted ? '' : message.content,
          type: message.type,
          timestamp: message.timestamp,
        );

        // Update the conversation
        await _conversationsCollection.doc(conversationId).update({
          'lastMessage': lastMessage.toJson(),
        });
      } else {
        // This was the only message, remove last message info
        await _conversationsCollection.doc(conversationId).update({
          'lastMessage': null,
        });
      }
    } catch (e) {
      log('Error updating last message after deletion: $e');
      rethrow;
    }
  }

  /// Edit a message
  @override
  Future<void> editMessage(
    String conversationId,
    String messageId,
    String newContent,
  ) async {
    try {
      _checkLoggedIn();

      // Get the message to check permissions
      final messageDoc =
          await _messagesCollection(conversationId).doc(messageId).get();

      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      final message = ChatMessage.fromJson({
        'id': messageDoc.id,
        ...messageDoc.data() as Map<String, dynamic>,
      });

      // Only the sender can edit their message
      final userId = currentUserId!;
      if (message.senderId != userId) {
        throw Exception('You can only edit your own messages');
      }

      // Check if message is already deleted
      if (message.isDeleted) {
        throw Exception('Cannot edit a deleted message');
      }

      // Update the message
      final now = DateTime.now();
      await _messagesCollection(conversationId).doc(messageId).update({
        'content': newContent,
        'isEdited': true,
        'editedAt': now,
      });

      // If this is the last message, update the conversation
      final conversation = await getConversationById(conversationId);
      if (conversation.lastMessage?.messageId == messageId) {
        await _conversationsCollection.doc(conversationId).update({
          'lastMessage.content': newContent,
        });
      }
    } catch (e) {
      log('Error editing message: $e');
      rethrow;
    }
  }

  /// Delete a conversation
  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      _checkLoggedIn();

      // Check permissions - only admin can delete a group chat
      final conversation = await getConversationById(conversationId);
      final userId = currentUserId!;

      if (conversation.isGroupChat && !conversation.isUserAdmin(userId)) {
        throw Exception('Only group admins can delete the conversation');
      }

      // For 1:1 chat, either participant can delete
      if (!conversation.isGroupChat &&
          !conversation.participantIds.contains(userId)) {
        throw Exception('You are not a participant in this conversation');
      }

      // Delete all messages
      final batch = _firestore.batch();
      final messagesSnapshot = await _messagesCollection(conversationId).get();

      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the conversation document
      batch.delete(_conversationsCollection.doc(conversationId));

      // Commit the batch
      await batch.commit();

      // Note: In a production app, this would be better handled by a Firebase Cloud Function
      // to ensure all subcollections are properly deleted
    } catch (e) {
      log('Error deleting conversation: $e');
      rethrow;
    }
  }

  /// Get unread message count for a user in a specific conversation
  @override
  Future<int> getUnreadMessageCount(
      String conversationId, String userId) async {
    try {
      _checkLoggedIn();

      final conversation = await getConversationById(conversationId);
      return conversation.getUnreadCountForUser(userId);
    } catch (e) {
      log('Error getting unread count: $e');
      rethrow;
    }
  }

  /// Listen to new messages in a conversation (real-time)
  @override
  Stream<List<ChatMessage>> listenToMessages(String conversationId) {
    try {
      if (!isLoggedIn) {
        throw Exception('User is not logged in');
      }

      return _messagesCollection(conversationId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        markMessagesAsRead(conversationId, currentUserId!);

        return snapshot.docs.map((doc) {
          return ChatMessage.fromJson({
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          });
        }).toList();
      });
    } catch (e) {
      log('Error listening to messages: $e');
      rethrow;
    }
  }

  /// Listen to conversation updates (real-time)
  @override
  Stream<ChatConversation> listenToConversation(String conversationId) {
    try {
      if (!isLoggedIn) {
        throw Exception('User is not logged in');
      }

      return _conversationsCollection
          .doc(conversationId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          throw Exception('Conversation not found');
        }

        return ChatConversation.fromJson({
          'id': snapshot.id,
          ...snapshot.data() as Map<String, dynamic>,
        });
      });
    } catch (e) {
      log('Error listening to conversation: $e');
      rethrow;
    }
  }

  /// Send a typing indicator
  @override
  Future<void> sendTypingIndicator(
    String conversationId,
    String userId,
    bool isTyping,
  ) async {
    try {
      _checkLoggedIn();

      await _conversationsCollection.doc(conversationId).update({
        'participantData.$userId.typingStatus': isTyping,
      });
    } catch (e) {
      log('Error sending typing indicator: $e');
      rethrow;
    }
  }

  /// Update user's online status
  @override
  Future<void> updateOnlineStatus(
    String userId,
    bool isOnline,
  ) async {
    try {
      _checkLoggedIn();

      final now = DateTime.now();

      // Get all conversations where the user is a participant
      final conversations = await getConversationsForUser(userId);

      // Update the user's online status in all conversations
      final batch = _firestore.batch();

      for (final conversation in conversations) {
        final conversationRef = _conversationsCollection.doc(conversation.id);

        batch.update(conversationRef, {
          'participantData.$userId.lastActiveAt': now,
        });
      }

      // Also update user document if it exists
      final userDoc = await _usersCollection.doc(userId).get();
      if (userDoc.exists) {
        batch.update(userDoc.reference, {
          'lastActiveAt': now,
          'isOnline': isOnline,
        });
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      log('Error updating online status: $e');
      rethrow;
    }
  }

  /// Upload a file to the conversation (image, document, etc.)
  @override
  Future<String> uploadAttachment(
    String conversationId,
    String senderId,
    File file,
    String fileName,
    String fileType,
  ) async {
    try {
      _checkLoggedIn();

      // Generate a unique filename
      final extension = path.extension(fileName);
      final uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}$extension';

      // Create the storage reference
      final storageRef = _storage
          .ref()
          .child(COLLECTION_CONVERSATIONS)
          .child(conversationId)
          .child(uniqueFileName);

      // Upload the file
      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(contentType: fileType),
      );

      // Wait for the upload to complete and show progress
      await uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        log('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      }).asFuture(); // Convert stream to future to wait for completion

      // Get the download URL
      final downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      log('Error uploading attachment: $e');
      rethrow;
    }
  }

  /// Block a user in a conversation
  @override
  Future<void> blockUser(
    String conversationId,
    String userId,
    String blockedUserId,
  ) async {
    try {
      _checkLoggedIn();

      // Check if the conversation exists and is a 1:1 chat
      final conversation = await getConversationById(conversationId);

      if (conversation.isGroupChat) {
        throw Exception('You cannot block users in a group chat');
      }

      if (!conversation.hasParticipant(userId) ||
          !conversation.hasParticipant(blockedUserId)) {
        throw Exception('User is not a participant in this conversation');
      }

      // Update the user's blocked list
      await _conversationsCollection.doc(conversationId).update({
        'participantData.$userId.blockedUsers':
            FieldValue.arrayUnion([blockedUserId]),
      });
    } catch (e) {
      log('Error blocking user: $e');
      rethrow;
    }
  }

  /// Unblock a user in a conversation
  @override
  Future<void> unblockUser(
    String conversationId,
    String userId,
    String blockedUserId,
  ) async {
    try {
      _checkLoggedIn();

      // Check if the conversation exists
      final conversation = await getConversationById(conversationId);

      if (!conversation.hasParticipant(userId) ||
          !conversation.hasParticipant(blockedUserId)) {
        throw Exception('User is not a participant in this conversation');
      }

      // Update the user's blocked list
      await _conversationsCollection.doc(conversationId).update({
        'participantData.$userId.blockedUsers':
            FieldValue.arrayRemove([blockedUserId]),
      });
    } catch (e) {
      log('Error unblocking user: $e');
      rethrow;
    }
  }

  /// Get list of blocked users for a user in a conversation
  @override
  Future<List<String>> getBlockedUsers(
    String conversationId,
    String userId,
  ) async {
    try {
      _checkLoggedIn();

      final conversation = await getConversationById(conversationId);
      return conversation.getUsersBlockedBy(userId);
    } catch (e) {
      log('Error getting blocked users: $e');
      rethrow;
    }
  }

  /// Check if a user is blocked by another user
  @override
  Future<bool> isUserBlocked(
    String conversationId,
    String userId,
    String otherUserId,
  ) async {
    try {
      _checkLoggedIn();

      final conversation = await getConversationById(conversationId);
      return conversation.isUserBlockedBy(userId, otherUserId);
    } catch (e) {
      log('Error checking if user is blocked: $e');
      rethrow;
    }
  }

  /// Report a conversation or message
  @override
  Future<void> reportConversation(
    String conversationId,
    String reportedBy,
    String reason,
    ReportType type, {
    String? messageId,
    List<String>? attachments,
  }) async {
    try {
      _checkLoggedIn();

      final reportId = _generateId();
      final now = DateTime.now();

      // Create report object
      final report = ChatReport(
        id: reportId,
        conversationId: conversationId,
        reportedBy: reportedBy,
        messageId: messageId,
        type: type,
        reason: reason,
        createdAt: now,
        status: ReportStatus.pending,
        attachments: attachments,
      );

      // Save report
      await _reportsCollection.doc(reportId).set(report.toJson());

      // Mark conversation as reported
      await _conversationsCollection.doc(conversationId).update({
        'isReported': true,
        'reportReason': reason,
        'reportedAt': now,
        'reportedBy': reportedBy,
      });
    } catch (e) {
      log('Error reporting conversation: $e');
      rethrow;
    }
  }

  /// Add a user to a group conversation
  @override
  Future<void> addUserToGroup(
    String conversationId,
    String userId,
  ) async {
    try {
      _checkLoggedIn();

      // Check if the conversation exists and is a group chat
      final conversation = await getConversationById(conversationId);

      if (!conversation.isGroupChat) {
        throw Exception('This is not a group chat');
      }

      if (conversation.hasParticipant(userId)) {
        throw Exception('User is already a participant in this conversation');
      }

      // Create new participant data
      final participant = ConversationParticipant(
        userId: userId,
        unreadCount: 0,
        lastSeenAt: DateTime.now(),
        typingStatus: false,
        blockedUsers: [],
        role: ParticipantRole.member,
      );

      // Add user to participants
      await _conversationsCollection.doc(conversationId).update({
        'participantIds': FieldValue.arrayUnion([userId]),
        'participantData.$userId': participant.toJson(),
      });
    } catch (e) {
      log('Error adding user to group: $e');
      rethrow;
    }
  }

  /// Remove a user from a group conversation
  @override
  Future<void> removeUserFromGroup(
    String conversationId,
    String userId,
  ) async {
    try {
      _checkLoggedIn();

      // Check if the conversation exists and is a group chat
      final conversation = await getConversationById(conversationId);

      if (!conversation.isGroupChat) {
        throw Exception('This is not a group chat');
      }

      if (!conversation.hasParticipant(userId)) {
        throw Exception('User is not a participant in this conversation');
      }

      // Check if the current user has permission to remove users
      final currentUserId = this.currentUserId!;
      if (userId != currentUserId &&
          !conversation.canUserAdminister(currentUserId)) {
        throw Exception(
            'You do not have permission to remove users from this group');
      }

      // Remove user from participants
      final batch = _firestore.batch();
      final conversationRef = _conversationsCollection.doc(conversationId);

      batch.update(conversationRef, {
        'participantIds': FieldValue.arrayRemove([userId]),
      });

      // Remove user's participant data
      batch.update(conversationRef, {
        'participantData.$userId': FieldValue.delete(),
      });

      // Commit the batch
      await batch.commit();
    } catch (e) {
      log('Error removing user from group: $e');
      rethrow;
    }
  }

  /// Make a user admin of a group conversation
  @override
  Future<void> makeUserAdmin(
    String conversationId,
    String userId,
  ) async {
    try {
      _checkLoggedIn();

      // Check if the conversation exists and is a group chat
      final conversation = await getConversationById(conversationId);

      if (!conversation.isGroupChat) {
        throw Exception('This is not a group chat');
      }

      if (!conversation.hasParticipant(userId)) {
        throw Exception('User is not a participant in this conversation');
      }

      // Check if the current user is an admin
      final currentUserId = this.currentUserId!;
      if (!conversation.isUserAdmin(currentUserId)) {
        throw Exception('Only admins can promote users to admin');
      }

      // Update user's role to admin
      await _conversationsCollection.doc(conversationId).update({
        'adminId': userId,
        'participantData.$userId.role': ParticipantRole.admin.value,
      });
    } catch (e) {
      log('Error making user admin: $e');
      rethrow;
    }
  }

  /// Update group conversation details
  @override
  Future<void> updateGroupDetails(
    String conversationId, {
    String? title,
    String? groupImage,
  }) async {
    try {
      _checkLoggedIn();

      // Check if the conversation exists and is a group chat
      final conversation = await getConversationById(conversationId);

      if (!conversation.isGroupChat) {
        throw Exception('This is not a group chat');
      }

      // Check if the current user has permission to update group details
      final currentUserId = this.currentUserId!;
      if (!conversation.canUserAdminister(currentUserId)) {
        throw Exception('You do not have permission to update group details');
      }

      // Update group details
      final updates = <String, dynamic>{};

      if (title != null) {
        updates['title'] = title;
      }

      if (groupImage != null) {
        updates['groupImage'] = groupImage;
      }

      if (updates.isNotEmpty) {
        await _conversationsCollection.doc(conversationId).update(updates);
      }
    } catch (e) {
      log('Error updating group details: $e');
      rethrow;
    }
  }

  /// Leave a group conversation
  @override
  Future<void> leaveGroup(
    String conversationId,
    String userId,
  ) async {
    try {
      _checkLoggedIn();

      // Check if the conversation exists and is a group chat
      final conversation = await getConversationById(conversationId);

      if (!conversation.isGroupChat) {
        throw Exception('This is not a group chat');
      }

      if (!conversation.hasParticipant(userId)) {
        throw Exception('User is not a participant in this conversation');
      }

      // Check if the user is the admin
      if (conversation.isUserAdmin(userId)) {
        // If there are other participants, assign a new admin
        if (conversation.participantIds.length > 1) {
          // Find another participant to make admin
          final newAdminId = conversation.participantIds.firstWhere(
            (id) => id != userId,
            orElse: () => '',
          );

          if (newAdminId.isNotEmpty) {
            await makeUserAdmin(conversationId, newAdminId);
          }
        } else {
          // This was the last participant, delete the conversation
          await deleteConversation(conversationId);
          return;
        }
      }

      // Remove the user from the group
      await removeUserFromGroup(conversationId, userId);
    } catch (e) {
      log('Error leaving group: $e');
      rethrow;
    }
  }

  /// Get user details by ID
  @override
  Future<ChatUser?> getUserById(String userId) async {
    try {
      _checkLoggedIn();

      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) {
        return null;
      }

      return ChatUser.fromJson({
        'id': userDoc.id,
        ...userDoc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      log('Error getting user: $e');
      rethrow;
    }
  }

  /// Search for users
  @override
  Future<List<ChatUser>> searchUsers(String query, {int limit = 10}) async {
    try {
      _checkLoggedIn();

      // Search by name
      final nameQuery = await _usersCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .limit(limit)
          .get();

      final users = nameQuery.docs.map((doc) {
        return ChatUser.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();

      // If we didn't get enough results, also search by email
      if (users.length < limit) {
        final emailQuery = await _usersCollection
            .where('email', isGreaterThanOrEqualTo: query)
            .limit(limit - users.length)
            .get();

        // Add email results, avoiding duplicates
        final userIds = users.map((u) => u.id).toSet();

        for (final doc in emailQuery.docs) {
          if (!userIds.contains(doc.id)) {
            users.add(ChatUser.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }));
            userIds.add(doc.id);
          }
        }
      }

      return users;
    } catch (e) {
      log('Error searching users: $e');
      rethrow;
    }
  }

  /// Get total unread message count across all conversations
  @override
  Future<int> getTotalUnreadMessageCount(String userId) async {
    try {
      _checkLoggedIn();

      final conversations = await getConversationsForUser(userId);

      int totalCount = 0;
      for (final conversation in conversations) {
        totalCount += conversation.getUnreadCountForUser(userId);
      }

      return totalCount;
    } catch (e) {
      log('Error getting total unread count: $e');
      rethrow;
    }
  }

  /// Add reaction to a message
  @override
  Future<void> addReaction(
    String conversationId,
    String messageId,
    String userId,
    String reaction,
  ) async {
    try {
      _checkLoggedIn();

      // Add the reaction
      await _messagesCollection(conversationId).doc(messageId).update({
        'reactions.$userId': reaction,
      });
    } catch (e) {
      log('Error adding reaction: $e');
      rethrow;
    }
  }

  /// Remove reaction from a message
  @override
  Future<void> removeReaction(
    String conversationId,
    String messageId,
    String userId,
  ) async {
    try {
      _checkLoggedIn();

      // Remove the reaction
      await _messagesCollection(conversationId).doc(messageId).update({
        'reactions.$userId': FieldValue.delete(),
      });
    } catch (e) {
      log('Error removing reaction: $e');
      rethrow;
    }
  }

  @override
  Future<bool> checkUserExists(
    String userId,
  ) async {
    try {
      _checkLoggedIn();

      final userDoc = await _usersCollection.doc(userId).get();
      return userDoc.exists;
    } catch (e) {
      log('Error checking user existence: $e');
      rethrow;
    }
  }

  @override
  Future<ChatUser> createUser(
    String userId,
    String name, {
    String? profileImage,
    DateTime? lastActiveAt,
    DateTime? lastSeenAt,
  }) async {
    try {
      _checkLoggedIn();

      final user = ChatUser(
        id: userId,
        name: name,
        profileImage: profileImage,
        lastActiveAt: lastActiveAt ?? DateTime.now(),
        lastSeenAt: lastSeenAt ?? DateTime.now(),
      );

      await _usersCollection.doc(userId).set(user.toJson());

      return user;
    } catch (e) {
      log('Error creating user: $e');
      rethrow;
    }
  }

  @override
  Future<ChatUser> updateUser(
    String userId, {
    String? name,
    String? profileImage,
    bool? typingStatus,
    DateTime? lastActiveAt,
    DateTime? lastSeenAt,
  }) async {
    try {
      _checkLoggedIn();

      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (profileImage != null) updates['profileImage'] = profileImage;
      if (typingStatus != null) updates['typingStatus'] = typingStatus;
      if (lastActiveAt != null) updates['lastActiveAt'] = lastActiveAt;
      if (lastSeenAt != null) updates['lastSeenAt'] = lastSeenAt;

      await _usersCollection.doc(userId).update(updates);

      // Fetch the updated user
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      return ChatUser.fromJson({
        'id': userDoc.id,
        ...userDoc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      log('Error updating user: $e');
      rethrow;
    }
  }

  /// Get users by IDs in batch
  @override
  Future<Map<String, ChatUser>> getChatUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    final Map<String, ChatUser> users = {};

    // Fetch users in batches of 10 to avoid Firestore limitations
    for (int i = 0; i < userIds.length; i += 10) {
      final end = (i + 10 < userIds.length) ? i + 10 : userIds.length;
      final batch = userIds.sublist(i, end);

      final querySnapshot = await _usersCollection
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (final doc in querySnapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;
        users[doc.id] = ChatUser.fromJson({
          'id': doc.id,
          ...userData,
        });
      }
    }

    return users;
  }

  /// Get a conversation as BaseConversationModel with rich user data
  @override
  Future<BaseConversationModel> getBaseConversationModel(
    String conversationId, {
    Map<String, ChatUser>? availableChatUsers,
  }) async {
    // Get the conversation
    final conversation = await getConversationById(conversationId);

    // Use provided chat users or fetch them
    final Map<String, ChatUser> chatUsers = availableChatUsers ?? {};

    // Check if we need to fetch any missing users
    final List<String> missingUserIds = conversation.participantIds
        .where((id) => !chatUsers.containsKey(id))
        .toList();

    if (missingUserIds.isNotEmpty) {
      final newUsers = await getChatUsersByIds(missingUserIds);
      chatUsers.addAll(newUsers);
    }

    // Use the factory to create the base model
    return FirebaseDataFactory.createBaseConversation(conversation, chatUsers);
  }

  /// Get all conversations as BaseConversationModel list
  @override
  Future<List<BaseConversationModel>> getAllBaseConversationModels(
    String userId, {
    Map<String, ChatUser>? availableChatUsers,
  }) async {
    // Get all conversations for the user
    final conversations = await getConversationsForUser(userId);

    // Use provided chat users or fetch them
    final Map<String, ChatUser> chatUsers = availableChatUsers ?? {};

    // Collect all participant IDs from all conversations
    final Set<String> allParticipantIds = {};
    for (final conversation in conversations) {
      allParticipantIds.addAll(conversation.participantIds);
    }

    // Check if we need to fetch any missing users
    final List<String> missingUserIds =
        allParticipantIds.where((id) => !chatUsers.containsKey(id)).toList();

    if (missingUserIds.isNotEmpty) {
      final newUsers = await getChatUsersByIds(missingUserIds);
      chatUsers.addAll(newUsers);
    }

    // Convert each conversation to a base model
    final List<BaseConversationModel> baseConversations = [];
    for (final conversation in conversations) {
      final baseConversation = FirebaseDataFactory.createBaseConversation(
        conversation,
        chatUsers,
      );
      baseConversations.add(baseConversation);
    }

    return baseConversations;
  }

  /// Listen to a conversation as BaseConversationModel stream
  @override
  Stream<BaseConversationModel> listenToBaseConversationModel(
    String conversationId, {
    Map<String, ChatUser>? availableChatUsers,
  }) {
    final chatUsersMap = availableChatUsers ?? {};

    return listenToConversation(conversationId).asyncMap((conversation) async {
      // Check if we need to fetch any missing users
      final List<String> missingUserIds = conversation.participantIds
          .where((id) => !chatUsersMap.containsKey(id))
          .toList();

      if (missingUserIds.isNotEmpty) {
        final newUsers = await getChatUsersByIds(missingUserIds);
        chatUsersMap.addAll(newUsers);
      }

      // Use the factory to create the base model
      return FirebaseDataFactory.createBaseConversation(
        conversation,
        chatUsersMap,
      );
    });
  }

  //   @override
  // Stream<List<ChatMessage>> listenToMessages(String conversationId) {
  //   try {
  //     if (!isLoggedIn) {
  //       throw Exception('User is not logged in');
  //     }

  //     return _messagesCollection(conversationId)
  //         .orderBy('timestamp', descending: true)
  //         .snapshots()
  //         .map((snapshot) {
  //       return snapshot.docs.map((doc) {
  //         return ChatMessage.fromJson({
  //           'id': doc.id,
  //           ...doc.data() as Map<String, dynamic>,
  //         });
  //       }).toList();
  //     });
  //   } catch (e) {
  //     log('Error listening to messages: $e');
  //     rethrow;
  //   }
  // }

  // @override
  // Stream<List<BaseConversationModel>> listenToAllBaseConversationModels(
  //   String userId, {
  //   Map<String, ChatUser>? availableChatUsers,
  // }) {
  //   // Create a stream controller for the list of conversations
  //   final controller = StreamController<List<BaseConversationModel>>.broadcast();

  //   // Map to store all conversations
  //   final Map<String, BaseConversationModel> conversations = {};

  //   // Listen to all conversations for the user
  //   _conversationsCollection
  //       .where('participantIds', arrayContains: userId)
  //       .snapshots()
  //       .listen(
  //     (snapshot) async {
  //       try {
  //         // Process each conversation
  //         for (final change in snapshot.docChanges) {
  //           final conversationId = change.doc.id;
  //           final conversationData = change.doc.data() as Map<String, dynamic>;

  //           // Create a ChatConversation from the data
  //           final chatConversation = ChatConversation.fromJson(conversationData);

  //           // Create a base conversation model
  //           final conversation = FirebaseFactory.createBaseConversation(
  //             chatConversation,
  //             availableChatUsers ?? {},
  //           );

  //           // Check what users we're missing
  //           final missingUserIds = FirebaseFactory.getMissingUserIds(
  //             chatConversation,
  //             availableChatUsers ?? {},
  //           );

  //           // Fetch missing users
  //           final users = await _fetchMissingUsers(missingUserIds);

  //           // Update the conversation with the new user data
  //           final enrichedConversation = FirebaseFactory.updateBaseConversationWithUsers(
  //             conversation,
  //             users,
  //           );

  //           // Update the conversations map based on the change type
  //           if (change.type == DocumentChangeType.removed) {
  //             conversations.remove(conversationId);
  //           } else {
  //             conversations[conversationId] = enrichedConversation;
  //           }

  //           // Emit the updated list
  //           controller.add(conversations.values.toList());
  //         }
  //       } catch (e) {
  //         print('Error processing conversation updates: $e');
  //         controller.addError(e);
  //       }
  //     },
  //     onError: (e) {
  //       print('Error in conversation stream: $e');
  //       controller.addError(e);
  //     },
  //   );

  //   // Clean up when the stream is closed
  //   controller.onCancel = () {
  //     controller.close();
  //   };

  //   return controller.stream;
  // }
  @override
  Stream<List<BaseConversationModel>> listenToAllBaseConversationModels(
    String userId, {
    Map<String, ChatUser>? availableChatUsers,
  }) {
    try {
      if (!isLoggedIn) {
        throw Exception('User is not logged in');
      }

      final chatUsersMap = availableChatUsers ?? {};

      return _conversationsCollection
          .where('participantIds', arrayContains: userId)
          .snapshots()
          .asyncMap((snapshot) async {
        final List<BaseConversationModel> conversations = [];
        final Set<String> allParticipantIds = {};

        // Extract all participant IDs from all conversations
        for (final doc in snapshot.docs) {
          final conversation = ChatConversation.fromJson({
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          });
          allParticipantIds.addAll(conversation.participantIds);
        }

        // Fetch any missing user data
        final List<String> missingUserIds = allParticipantIds
            .where((id) => !chatUsersMap.containsKey(id))
            .toList();

        if (missingUserIds.isNotEmpty) {
          final newUsers = await getChatUsersByIds(missingUserIds);
          chatUsersMap.addAll(newUsers);
        }

        // Convert each conversation document to a BaseConversationModel
        for (final doc in snapshot.docs) {
          final conversation = ChatConversation.fromJson({
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          });

          final baseConversation = FirebaseDataFactory.createBaseConversation(
            conversation,
            chatUsersMap,
          );

          conversations.add(baseConversation);
        }

        return conversations;
      });
    } catch (e) {
      log('Error listening to all conversations: $e');
      rethrow;
    }
  }

  /// Fetch missing users for a conversation
  // ignore: unused_element
  Future<Map<String, ChatUser>> _fetchMissingUsers(List<String> userIds) async {
    final users = <String, ChatUser>{};
    if (userIds.isEmpty) return users;

    for (final userId in userIds) {
      try {
        final user = await getUserById(userId);
        if (user != null) {
          users[userId] = user;
        }
      } catch (e) {
        print('Error fetching user $userId: $e');
      }
    }
    return users;
  }

  /// Helper to get public download directory path (Android: Download, iOS: Documents)
  Future<String> _getPublicDownloadDirectoryPath(String fileName) async {
    if (Platform.isAndroid) {
      String downloadsPath =
          await ExternalPath.getExternalStoragePublicDirectory(
              ExternalPath.DIRECTORY_DOWNLOAD);
      return '$downloadsPath/$fileName';
    } else {
      // iOS fallback: use Documents directory
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}/$fileName';
    }
  }

  /// Download file from a message
  @override
  Future<File?> downloadFile({
    required String fileUrl,
    required String fileName,
    String? customPath,
  }) async {
    try {
      if (fileUrl.isEmpty) {
        throw Exception('File URL is empty');
      }

      // Use public Downloads directory unless customPath is provided
      File file;
      if (customPath != null) {
        file = File(customPath);
      } else {
        final filePath = await _getPublicDownloadDirectoryPath(fileName);
        file = File(filePath);
      }

      // If the file already exists, return it
      if (await file.exists()) {
        return file;
      }

      // If it's a Firebase Storage URL, download using firebase_storage
      if (fileUrl.contains('firebasestorage.googleapis.com')) {
        try {
          final Reference ref = FirebaseStorage.instance.refFromURL(fileUrl);
          await ref.writeToFile(file);
          return file;
        } catch (e) {
          log('Error downloading from Firebase Storage: $e');
          rethrow;
        }
      } else {
        throw Exception('Non-Firebase storage URLs are not supported yet');
      }
    } catch (e) {
      log('Error downloading file: $e');
      return null;
    }
  }
}
