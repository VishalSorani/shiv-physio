import 'package:intl/intl.dart';
import 'package:shiv_physio_app/data/chat/enum/chat_enums.dart';
import 'package:shiv_physio_app/data/chat/helper/timestamp_parser_helper.dart';

const String kAppdateFormatConversation = 'dd-MMM-yyyy';
const String kAppTimeFormatConversation = 'hh:mm a';

class LastMessage {
  final String? messageId;
  final String? senderId;
  final String? content;
  final MessageType type;
  final DateTime timestamp;

  LastMessage({
    this.messageId,
    this.senderId,
    this.content,
    this.type = MessageType.text,
    required this.timestamp,
  });



  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      messageId: json['messageId'] as String?,
      senderId: json['senderId'] as String?,
      content: json['content'] as String?,
      type: MessageTypeExtension.fromString(json['type'] as String?),
      timestamp: TimestampParser.parseTimestampWithDefault(json['timestamp']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'content': content,
      'type': type.value,
      'timestamp': timestamp,
    };
  }

  LastMessage copyWith({
    String? messageId,
    String? senderId,
    String? senderName,
    String? content,
    MessageType? type,
    DateTime? timestamp,
  }) {
    return LastMessage(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Get a message preview for the conversation list
  String getMessagePreview() {
    switch (type) {
      case MessageType.text:
        return content ?? "No messages yet";
      case MessageType.image:
        return "📷 Image";
      case MessageType.file:
        return "📎 File";
      case MessageType.video:
        return "📹 Video";
      case MessageType.audio:
        return "🎵 Audio";
      case MessageType.location:
        return "📍 Location";
      case MessageType.contact:
        return "👤 Contact";
      case MessageType.sticker:
        return "🎯 Sticker";
      default:
        return "No messages yet";
    }
  }

  // time only
  String get timeOnly {
    return DateFormat(kAppTimeFormatConversation).format(timestamp);
  }

  // get Time format for the last message
  String get lastMessageTimeFormated {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return timeOnly;
    } else if (messageDate == yesterday) {
      return 'Yesterday, $timeOnly';
    } else if (now.difference(timestamp).inDays < 7) {
      return '${DateFormat('EEEE').format(timestamp)}, $timeOnly'; // Day of week + time
    } else if (timestamp.year == now.year) {
      return DateFormat('MMM d, $kAppTimeFormatConversation')
          .format(timestamp); // Month, day + time
    } else {
      return DateFormat('MMM d, yyyy, $kAppTimeFormatConversation')
          .format(timestamp); // Full date and time
    }
  }
}
