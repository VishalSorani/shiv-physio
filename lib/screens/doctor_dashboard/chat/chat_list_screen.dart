import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../data/chat/model/base_conversation_model.dart';
import '../../../widgets/app_custom_app_bar.dart';
import 'chat_list_controller.dart';

class DoctorChatListScreen extends BaseScreenView<DoctorChatListController> {
  static const String chatListScreen = '/doctor-chat-list';

  const DoctorChatListScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppCustomAppBar(title: 'Patients', centerTitle: true),
      body: SafeArea(
        bottom: false,
        child: GetBuilder<DoctorChatListController>(
          id: DoctorChatListController.conversationListId,
          builder: (controller) {
            if (controller.isEmpty) {
              return GetBuilder<DoctorChatListController>(
                id: DoctorChatListController.emptyStateId,
                builder: (_) => _buildEmptyState(context, isDark),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadConversations,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.spacing4),
                itemCount: controller.conversations.length,
                itemBuilder: (context, index) {
                  final conversation = controller.conversations[index];
                  return _buildConversationItem(
                    context,
                    controller,
                    conversation,
                    isDark,
                    index,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    DoctorChatListController controller,
    BaseConversationModel conversation,
    bool isDark,
    int index,
  ) {
    final unreadCount = controller.getUnreadCount(conversation);
    final title = controller.getConversationTitle(conversation);
    final avatar = controller.getConversationAvatar(conversation);
    final lastMessage = conversation.lastMessage;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          controller.onConversationTap(conversation);
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: AnimatedContainer(
          duration: AppConstants.shortAnimation,
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: AppConstants.spacing2),
          padding: const EdgeInsets.all(AppConstants.spacing4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                child: avatar == null
                    ? Text(
                        title.isNotEmpty ? title[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: AppConstants.body1Size,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppConstants.spacing4),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: AppConstants.body1Size,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastMessage != null)
                          Text(
                            _formatTime(lastMessage.timestamp),
                            style: TextStyle(
                              fontSize: AppConstants.captionSize,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacing1),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage?.getMessagePreview() ??
                                'No messages yet',
                            style: TextStyle(
                              fontSize: AppConstants.body2Size,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : AppColors.textSecondary,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacing2,
                              vertical: AppConstants.spacing1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusCircular,
                              ),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: AppConstants.captionSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final localTimestamp = timestamp.toLocal();
    final difference = now.difference(localTimestamp);

    if (difference.inDays == 0) {
      // Today - show time
      final hour = localTimestamp.hour;
      final minute = localTimestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[localTimestamp.weekday - 1];
    } else {
      // Older - show date
      return '${localTimestamp.day}/${localTimestamp.month}';
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
              Icons.group,
              size: 80,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.spacing5),
            Text(
              'No Patients',
              style: TextStyle(
                fontSize: AppConstants.h3Size,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing2),
            Text(
              'Your patient conversations will appear here',
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
