

import 'package:shiv_physio_app/data/chat/enum/chat_enums.dart';
import 'package:shiv_physio_app/data/chat/helper/timestamp_parser_helper.dart';
import 'package:shiv_physio_app/data/chat/model/base_conversation_model.dart';

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final Map<String, dynamic> readStatus; // userId: timestamp
  final bool isDeleted;
  final bool isEdited;
  final DateTime? editedAt;
  final Map<String, dynamic>? metadata; // Additional info like file properties
  final List<String>? mentionedUserIds; // For @mentions
  final Map<String, String>? reactions; // userId: reaction

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.readStatus,
    this.isDeleted = false,
    this.isEdited = false,
    this.editedAt,
    this.metadata,
    this.mentionedUserIds,
    this.reactions,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    Map<String, String>? reactionMap;
    if (json['reactions'] != null) {
      reactionMap = Map<String, String>.from(json['reactions'] as Map);
    }

    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      type: MessageTypeExtension.fromString(json['type'] as String?),
      timestamp: TimestampParser.parseTimestampWithDefault(json['timestamp']),
      readStatus: json['readStatus'] as Map<String, dynamic>? ?? {},
      isDeleted: json['isDeleted'] as bool? ?? false,
      isEdited: json['isEdited'] as bool? ?? false,
      editedAt: TimestampParser.parseTimestamp(json['editedAt']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      mentionedUserIds: json['mentionedUserIds'] != null
          ? List<String>.from(json['mentionedUserIds'])
          : null,
      reactions: reactionMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'type': type.value,
      'timestamp': timestamp,
      'readStatus': readStatus,
      'isDeleted': isDeleted,
      'isEdited': isEdited,
      'editedAt': editedAt,
      'metadata': metadata,
      'mentionedUserIds': mentionedUserIds,
      'reactions': reactions,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderProfileImage,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    Map<String, dynamic>? readStatus,
    bool? isDeleted,
    bool? isEdited,
    DateTime? editedAt,
    Map<String, dynamic>? metadata,
    List<String>? mentionedUserIds,
    Map<String, String>? reactions,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      readStatus: readStatus ?? this.readStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      metadata: metadata ?? this.metadata,
      mentionedUserIds: mentionedUserIds ?? this.mentionedUserIds,
      reactions: reactions ?? this.reactions,
    );
  }

  // Utility methods

  bool isReadBy(String userId) {
    return readStatus.containsKey(userId) && readStatus[userId] != null;
  }

  DateTime? getReadTime(String userId) {
    if (!isReadBy(userId)) return null;

    final timestamp = readStatus[userId];
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  // Get file size in a readable format
  String? getFileSizeFormatted() {
    if (metadata == null || metadata!['fileSize'] == null) return null;

    final int fileSize = metadata!['fileSize'] as int;

    if (fileSize < 1024) {
      return '${fileSize} B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  String getDisplayContent() {
    if (isDeleted) return 'This message was deleted';

    switch (type) {
      case MessageType.text:
        return content;
      case MessageType.image:
        return '📷 Image';
      case MessageType.file:
        return '📎 ${metadata?['fileName'] ?? 'File'}';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.audio:
        return '🎵 Audio';
      case MessageType.location:
        return '📍 Location';
      case MessageType.contact:
        return '👤 Contact';
      case MessageType.sticker:
        return '🎯 Sticker';
    }
  }

  bool isMyMessage(String userId) => senderId == userId;

  // create is All user which are in conversation has Read this message Or Not send Boolean return take BaseConversationModel Model in parameter
  bool isAllUserRead(BaseConversationModel conversation) {
    if (conversation.participantIds.isEmpty) return false;

    for (var userId in conversation.participantIds) {
      if (!isReadBy(userId)) {
        return false;
      }
    }
    return true;
  }
}
