import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../data/models/content_item.dart';
import '../../../widgets/app_custom_app_bar.dart';
import '../../../widgets/inline_video_player.dart';
import 'content_controller.dart';

class ContentScreen extends BaseScreenView<ContentController> {
  const ContentScreen({super.key});

  static const String contentScreen = '/content';

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : const Color(0xFFF5F5F5);
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final secondaryTextColor = isDark
        ? Colors.grey.shade400
        : const Color(0xFF666666);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppCustomAppBar(
        title: 'Clinic Content',
        centerTitle: true,
        leading: GetBuilder<ContentController>(
          id: ContentController.appBarId,
          builder: (controller) => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.onBack,
              borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : const Color(0xFF333333),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Content List
            Expanded(
              child: GetBuilder<ContentController>(
                id: ContentController.contentListId,
                builder: (controller) {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.contentItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_library_outlined,
                            size: 64,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(height: AppConstants.spacing4),
                          Text(
                            'No content available',
                            style: TextStyle(
                              fontSize: AppConstants.body1Size,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.spacing5),
                    itemCount: controller.contentItems.length,
                    itemBuilder: (context, index) {
                      final content = controller.contentItems[index];
                      return _buildContentCard(
                        context,
                        content,
                        controller,
                        textColor,
                        secondaryTextColor,
                        isDark,
                        index,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildContentCard(
    BuildContext context,
    ContentItem content,
    ContentController controller,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
    int index,
  ) {
    final imageUrl = controller.getContentImageUrl(content);
    final badge = controller.getContentBadge(content);
    final badgeColor = controller.getContentBadgeColor(content);
    final badgeTextColor = controller.getContentBadgeTextColor(content);
    final hasPlay = controller.hasPlayButton(content);
    final duration = controller.getDuration(content);

    return Container(
      margin: EdgeInsets.only(
        bottom: index < controller.contentItems.length - 1
            ? AppConstants.spacing6
            : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video/Image Container with badges
          GestureDetector(
            onTap: content.type == ContentType.image
                ? () => controller.onContentTap(index)
                : null,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                color: Colors.grey.shade200,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Video player or Image
                  content.type == ContentType.video
                      ? InlineVideoPlayer(
                          content: content,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width * 0.75,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusXLarge,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusXLarge,
                          ),
                          child: (imageUrl?.isNotEmpty ?? false)
                              ? Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlaceholder(isDark),
                                )
                              : _buildPlaceholder(isDark),
                        ),
                  // Badge (top right) - for both videos and images
                  if (badge != null)
                    Positioned(
                      top: AppConstants.spacing3,
                      right: AppConstants.spacing3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusCircular,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  // Duration (bottom left for videos)
                  if (hasPlay && duration != null)
                    Positioned(
                      bottom: AppConstants.spacing3,
                      left: AppConstants.spacing3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing2,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: AppConstants.spacing1),
                            Text(
                              duration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Recovery Journey badge (bottom left for images)
                  if (!hasPlay && badge == 'Recovery Journey')
                    Positioned(
                      bottom: AppConstants.spacing3,
                      left: AppConstants.spacing3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing3,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusCircular,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: AppConstants.spacing2),
                            Text(
                              badge ?? '',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing3),
          // Title and Description
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: TextStyle(
                    fontSize: AppConstants.h4Size,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
                if (content.description != null) ...[
                  const SizedBox(height: AppConstants.spacing1),
                  Text(
                    content.description!,
                    style: TextStyle(
                      fontSize: AppConstants.body2Size,
                      color: secondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
      ),
    );
  }
}
