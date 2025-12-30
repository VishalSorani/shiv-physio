import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/base_class/base_controller.dart';
import '../../../data/chat/model/base_conversation_model.dart';
import '../../../data/chat/model/chat_message.dart';
import '../../../data/modules/chat_repository.dart';
import '../../../data/service/storage_service.dart';

class DoctorChatConversationController extends BaseController {
  static const String messageListId = 'message_list';
  static const String inputFieldId = 'input_field';
  static const String sendButtonId = 'send_button';
  static const String typingIndicatorId = 'typing_indicator';

  final ChatRepository _chatRepository;
  final StorageService _storageService;

  String? _conversationId;
  BaseConversationModel? _conversation;
  BaseConversationModel? get conversation => _conversation;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  final TextEditingController _messageController = TextEditingController();
  TextEditingController get messageController => _messageController;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  Timer? _typingTimer;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  StreamSubscription<BaseConversationModel>? _conversationSubscription;

  DoctorChatConversationController(this._chatRepository, this._storageService);

  @override
  void onInit() {
    super.onInit();
    // Track screen view
    trackScreenView('doctor_chat_conversation_screen');

    // Get conversation ID from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      _conversationId = args['conversationId'] as String?;
      _conversation = args['conversation'] as BaseConversationModel?;
    }

    if (_conversationId != null) {
      loadMessages();
      _listenToMessages();
      _listenToConversation();
      markMessagesAsRead();
    }
  }

  Future<void> loadMessages() async {
    if (_conversationId == null) return;

    await handleAsyncOperation(() async {
      _messages = await _chatRepository.getMessages(_conversationId!);
      _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      update([messageListId]);
    });
  }

  void _listenToMessages() {
    if (_conversationId == null) return;

    _messagesSubscription?.cancel();
    _messagesSubscription = _chatRepository
        .listenToMessages(_conversationId!)
        .listen(
          (messages) {
            _messages = messages;
            _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            update([messageListId]);
            markMessagesAsRead();
          },
          onError: (error) {
            log(
              'Error listening to messages: $error',
              name: 'DoctorChatConversationController',
            );
          },
        );
  }

  void _listenToConversation() {
    if (_conversationId == null) return;

    _conversationSubscription?.cancel();
    _conversationSubscription = _chatRepository
        .listenToConversation(_conversationId!)
        .listen(
          (conversation) {
            _conversation = conversation;
            update([messageListId]);
          },
          onError: (error) {
            log(
              'Error listening to conversation: $error',
              name: 'DoctorChatConversationController',
            );
          },
        );
  }

  Future<void> sendMessage() async {
    if (_conversationId == null) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Stop typing indicator
    _stopTyping();

    try {
      await _chatRepository.sendTextMessage(_conversationId!, text);
      _messageController.clear();
      update([inputFieldId, sendButtonId]);

      // Track analytics
      trackAnalyticsEvent(
        'message_sent',
        parameters: {
          'conversation_id': _conversationId,
          'message_type': 'text',
          'user_type': 'doctor',
        },
      );
    } catch (e) {
      log(
        'Error sending message: $e',
        name: 'DoctorChatConversationController',
      );
    }
  }

  Future<void> sendImage(File imageFile) async {
    if (_conversationId == null) return;

    await handleAsyncOperation(() async {
      await _chatRepository.sendImageMessage(_conversationId!, imageFile);

      // Track analytics
      trackAnalyticsEvent(
        'message_sent',
        parameters: {
          'conversation_id': _conversationId,
          'message_type': 'image',
          'user_type': 'doctor',
        },
      );
    });
  }

  void onTextChanged(String text) {
    // Update send button based on text field state
    update([sendButtonId]);
    
    if (text.isNotEmpty && !_isTyping) {
      _startTyping();
    } else if (text.isEmpty && _isTyping) {
      _stopTyping();
    }
  }

  void _startTyping() {
    if (_conversationId == null || _isTyping) return;
    _isTyping = true;
    _chatRepository.sendTypingIndicator(_conversationId!, true);
    update([typingIndicatorId]);

    // Auto-stop typing after 3 seconds
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      _stopTyping();
    });
  }

  void _stopTyping() {
    if (!_isTyping || _conversationId == null) return;
    _isTyping = false;
    _typingTimer?.cancel();
    _chatRepository.sendTypingIndicator(_conversationId!, false);
    update([typingIndicatorId]);
  }

  Future<void> markMessagesAsRead() async {
    if (_conversationId == null) return;
    try {
      await _chatRepository.markMessagesAsRead(_conversationId!);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  String? getCurrentUserId() {
    return _storageService.getUser()?.id;
  }

  bool isMyMessage(ChatMessage message) {
    final currentUserId = getCurrentUserId();
    return currentUserId != null && message.senderId == currentUserId;
  }

  String getSenderName(ChatMessage message) {
    if (isMyMessage(message)) {
      return 'You';
    }

    final participant = _conversation?.findParticipant(message.senderId);
    return participant?.name ?? 'Unknown';
  }

  String? getSenderAvatar(ChatMessage message) {
    if (isMyMessage(message)) {
      return _storageService.getUser()?.avatarUrl;
    }

    final participant = _conversation?.findParticipant(message.senderId);
    return participant?.profileImage;
  }

  @override
  void onClose() {
    _stopTyping();
    _typingTimer?.cancel();
    _messagesSubscription?.cancel();
    _conversationSubscription?.cancel();
    _messageController.dispose();
    super.onClose();
  }

  @override
  void handleNetworkChange(bool isConnected) {
    handleNetworkChangeDefault(isConnected);
    if (isConnected) {
      loadMessages();
    }
  }
}
