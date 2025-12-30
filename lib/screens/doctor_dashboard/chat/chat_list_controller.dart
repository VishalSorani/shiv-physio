import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../data/base_class/base_controller.dart';
import '../../../data/chat/model/base_conversation_model.dart';
import '../../../data/modules/chat_repository.dart';
import '../../../data/service/storage_service.dart';
import 'chat_conversation_screen.dart';

class DoctorChatListController extends BaseController {
  static const String conversationListId = 'conversation_list';
  static const String emptyStateId = 'empty_state';
  static const String unreadBadgeId = 'unread_badge';

  final ChatRepository _chatRepository;
  final StorageService _storageService;

  DoctorChatListController(this._chatRepository, this._storageService);

  // State
  List<BaseConversationModel> _conversations = [];
  List<BaseConversationModel> get conversations => _conversations;

  int _totalUnreadCount = 0;
  int get totalUnreadCount => _totalUnreadCount;

  bool get isEmpty => _conversations.isEmpty && !isLoading;

  StreamSubscription<List<BaseConversationModel>>? _conversationsSubscription;

  @override
  void onInit() {
    super.onInit();
    // Track screen view
    trackScreenView('doctor_chat_list_screen');
    loadConversations();
    _listenToConversations();
    _loadUnreadCount();
  }

  Future<void> loadConversations() async {
    await handleAsyncOperation(() async {
      _conversations = await _chatRepository.getConversations();
      update([conversationListId, emptyStateId]);
    });
  }

  void _listenToConversations() {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = _chatRepository.listenToConversations().listen(
      (conversations) {
        _conversations = conversations;
        update([conversationListId, emptyStateId]);
        _loadUnreadCount();
      },
      onError: (error) {
        log(
          'Error listening to conversations: $error',
          name: 'DoctorChatListController',
        );
      },
    );
  }

  Future<void> _loadUnreadCount() async {
    try {
      _totalUnreadCount = await _chatRepository.getTotalUnreadCount();
      update([unreadBadgeId]);
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  void onConversationTap(BaseConversationModel conversation) {
    navigationService.navigateToRoute(
      DoctorChatConversationScreen.chatConversationScreen,
      arguments: {
        'conversationId': conversation.id,
        'conversation': conversation,
      },
    );
  }

  String? getCurrentUserId() {
    return _storageService.getUser()?.id;
  }

  String getConversationTitle(BaseConversationModel conversation) {
    final currentUserId = getCurrentUserId();
    if (currentUserId == null) return 'Unknown';

    if (conversation.isGroupChat) {
      return conversation.title ?? 'Group Chat';
    }

    // For 1:1 chat, get the other participant's name
    final otherParticipant = conversation.participantData.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => conversation.participantData.first,
    );

    return otherParticipant.name ?? 'Unknown';
  }

  String? getConversationAvatar(BaseConversationModel conversation) {
    final currentUserId = getCurrentUserId();
    if (currentUserId == null) return null;

    if (conversation.isGroupChat) {
      return conversation.groupImage;
    }

    // For 1:1 chat, get the other participant's avatar
    final otherParticipant = conversation.participantData.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => conversation.participantData.first,
    );

    return otherParticipant.profileImage;
  }

  int getUnreadCount(BaseConversationModel conversation) {
    final currentUserId = getCurrentUserId();
    if (currentUserId == null) return 0;

    final participant = conversation.findParticipant(currentUserId);
    return participant?.unreadCount ?? 0;
  }

  @override
  void onClose() {
    _conversationsSubscription?.cancel();
    super.onClose();
  }

  @override
  void handleNetworkChange(bool isConnected) {
    handleNetworkChangeDefault(isConnected);
    if (isConnected) {
      loadConversations();
    }
  }
}
