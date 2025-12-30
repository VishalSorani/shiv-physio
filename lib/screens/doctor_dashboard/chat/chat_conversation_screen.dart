import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../data/chat/enum/chat_enums.dart';
import '../../../data/chat/model/base_conversation_model.dart';
import '../../../data/chat/model/chat_message.dart';
import '../../../widgets/app_custom_app_bar.dart';
import 'chat_conversation_controller.dart';

class DoctorChatConversationScreen
    extends BaseScreenView<DoctorChatConversationController> {
  static const String chatConversationScreen = '/doctor-chat-conversation';

  const DoctorChatConversationScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(context, controller, isDark),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: GetBuilder<DoctorChatConversationController>(
                id: DoctorChatConversationController.messageListId,
                builder: (controller) {
                  if (controller.messages.isEmpty) {
                    return _buildEmptyState(context, isDark);
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(AppConstants.spacing4),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      return _buildMessageItem(
                        context,
                        controller,
                        message,
                        isDark,
                        index,
                      );
                    },
                  );
                },
              ),
            ),
            // Input Field
            _buildInputField(context, controller, isDark),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    DoctorChatConversationController controller,
    bool isDark,
  ) {
    final conversation = controller.conversation;
    final title = conversation != null
        ? _getConversationTitle(controller, conversation)
        : 'Chat';
    final avatar = conversation != null
        ? _getConversationAvatar(controller, conversation)
        : null;

    return AppCustomAppBar(
      title: title,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          HapticFeedback.lightImpact();
          controller.navigationService.goBack();
        },
      ),
      action: avatar != null
          ? Padding(
              padding: const EdgeInsets.only(right: AppConstants.spacing2),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: NetworkImage(avatar),
              ),
            )
          : null,
    );
  }

  String _getConversationTitle(
    DoctorChatConversationController controller,
    BaseConversationModel conversation,
  ) {
    if (conversation.isGroupChat) {
      return conversation.title ?? 'Group Chat';
    }

    final currentUserId = controller.getCurrentUserId();
    if (currentUserId == null) return 'Chat';

    final otherParticipant = conversation.participantData.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => conversation.participantData.first,
    );

    return otherParticipant.name;
  }

  String? _getConversationAvatar(
    DoctorChatConversationController controller,
    BaseConversationModel conversation,
  ) {
    if (conversation.isGroupChat) {
      return conversation.groupImage;
    }

    final currentUserId = controller.getCurrentUserId();
    if (currentUserId == null) return null;

    final otherParticipant = conversation.participantData.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => conversation.participantData.first,
    );

    return otherParticipant.profileImage;
  }

  Widget _buildMessageItem(
    BuildContext context,
    DoctorChatConversationController controller,
    ChatMessage message,
    bool isDark,
    int index,
  ) {
    final isMyMessage = controller.isMyMessage(message);
    final showAvatar =
        !isMyMessage &&
        (index == controller.messages.length - 1 ||
            controller.messages[index + 1].senderId != message.senderId);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacing2),
      child: Row(
        mainAxisAlignment: isMyMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage && showAvatar)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: controller.getSenderAvatar(message) != null
                  ? NetworkImage(controller.getSenderAvatar(message)!)
                  : null,
              child: controller.getSenderAvatar(message) == null
                  ? Text(
                      controller.getSenderName(message)[0].toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: AppConstants.captionSize,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            )
          else if (!isMyMessage)
            const SizedBox(width: 32),
          const SizedBox(width: AppConstants.spacing2),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing4,
                vertical: AppConstants.spacing2,
              ),
              decoration: BoxDecoration(
                color: isMyMessage
                    ? AppColors.primary
                    : (isDark ? AppColors.surfaceDark : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMyMessage)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.spacing1,
                      ),
                      child: Text(
                        controller.getSenderName(message),
                        style: TextStyle(
                          fontSize: AppConstants.captionSize,
                          fontWeight: FontWeight.bold,
                          color: isMyMessage
                              ? Colors.white70
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  // Show image preview for image messages
                  if (message.type == MessageType.image)
                    _buildImagePreview(message, isDark, isMyMessage)
                  else
                    Text(
                      message.getDisplayContent(),
                      style: TextStyle(
                        fontSize: AppConstants.body2Size,
                        color: isMyMessage
                            ? Colors.white
                            : (isDark ? Colors.white : AppColors.textPrimary),
                      ),
                    ),
                  const SizedBox(height: AppConstants.spacing1),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: AppConstants.captionSize,
                      color: isMyMessage
                          ? Colors.white70
                          : (isDark
                                ? Colors.grey.shade400
                                : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMyMessage) const SizedBox(width: 32),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Widget _buildImagePreview(
    ChatMessage message,
    bool isDark,
    bool isMyMessage,
  ) {
    final imageUrl = message.content; // For image messages, content is the URL

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 200,
          height: 200,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          width: 200,
          height: 200,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          child: Icon(
            Icons.broken_image,
            color: isMyMessage ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context,
    DoctorChatConversationController controller,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Image picker button
            IconButton(
              icon: Icon(Icons.image, color: AppColors.primary),
              onPressed: () async {
                HapticFeedback.lightImpact();
                await _pickImage(context, controller);
              },
            ),
            // Text input
            Expanded(
              child: GetBuilder<DoctorChatConversationController>(
                id: DoctorChatConversationController.inputFieldId,
                builder: (controller) {
                  return TextField(
                    controller: controller.messageController,
                    onChanged: controller.onTextChanged,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusCircular,
                        ),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.backgroundDark
                          : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing4,
                        vertical: AppConstants.spacing3,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  );
                },
              ),
            ),
            const SizedBox(width: AppConstants.spacing2),
            // Send button
            GetBuilder<DoctorChatConversationController>(
              id: DoctorChatConversationController.sendButtonId,
              builder: (controller) {
                final hasText = controller.messageController.text
                    .trim()
                    .isNotEmpty;
                return Opacity(
                  opacity: hasText ? 1.0 : 0.5,
                  child: Material(
                    color: hasText ? AppColors.primary : Colors.grey,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusCircular,
                    ),
                    child: InkWell(
                      onTap: hasText
                          ? () {
                              HapticFeedback.lightImpact();
                              controller.sendMessage();
                            }
                          : null,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusCircular,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppConstants.spacing3),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    DoctorChatConversationController controller,
  ) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await controller.sendImage(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: AppConstants.h3Size,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing2),
            Text(
              'Start the conversation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.body2Size,
                color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
