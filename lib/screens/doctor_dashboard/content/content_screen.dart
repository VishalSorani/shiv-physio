import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../data/models/content_item.dart';
import 'content_controller.dart';
import 'upload_content_binding.dart';
import 'upload_content_screen.dart';

class ContentManagementScreen
    extends BaseScreenView<ContentManagementController> {
  const ContentManagementScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(context, controller, isDark),
            // Content
            Expanded(
              child: GetBuilder<ContentManagementController>(
                id: ContentManagementController.contentId,
                builder: (controller) {
                  if (controller.isLoading && controller.contentItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: AppConstants.spacing4),
                          Text(
                            'Loading content...',
                            style: TextStyle(
                              fontSize: AppConstants.body2Size,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.refreshContentItems(),
                    color: AppColors.primary,
                    child: CustomScrollView(
                      slivers: [
                        // Upload Cards
                        SliverToBoxAdapter(
                          child: _buildUploadCards(context, controller, isDark),
                        ),
                        // Library Section
                        SliverToBoxAdapter(
                          child: _buildLibrarySection(context, controller, isDark),
                        ),
                        // Content Grid
                        SliverToBoxAdapter(
                          child: GetBuilder<ContentManagementController>(
                            id: ContentManagementController.libraryId,
                            builder: (controller) =>
                                _buildContentGrid(context, controller, isDark),
                          ),
                        ),
                        // Bottom spacing
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 100),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Floating action button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          // Show upload options
          _showUploadOptions(context, controller, isDark);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ContentManagementController controller,
    bool isDark,
  ) {
    final headerBgColor = isDark ? AppColors.backgroundDark : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: headerBgColor.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing4,
          vertical: AppConstants.spacing2,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.back();
                    },
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusCircular,
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: isDark ? Colors.white : const Color(0xFF111518),
                      ),
                    ),
                  ),
                ),
                // Settings button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // TODO: Navigate to settings
                    },
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusCircular,
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.settings,
                        size: 20,
                        color: isDark ? Colors.white : const Color(0xFF111518),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Content Management',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF111518),
                  ),
                ),
                GetBuilder<ContentManagementController>(
                  id: ContentManagementController.countId,
                  builder: (controller) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing2,
                      vertical: AppConstants.spacing1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),
                    child: Text(
                      '${controller.totalCount} Items',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCards(
    BuildContext context,
    ContentManagementController controller,
    bool isDark,
  ) {
    final surfaceColor = isDark ? Colors.white.withOpacity(0.05) : AppColors.backgroundLight;
    final borderColor = isDark ? Colors.grey.shade800 : const Color(0xFFDBE1E6);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      child: Row(
        children: [
          Expanded(
            child: _buildUploadCard(
              context,
              Icons.movie,
              'Add Video',
              'MP4, MOV (Max 500MB)',
              AppColors.primary,
              isDark,
              surfaceColor,
              borderColor,
              () => controller.onUploadVideo(),
            ),
          ),
          const SizedBox(width: AppConstants.spacing3),
          Expanded(
            child: _buildUploadCard(
              context,
              Icons.image,
              'Add Photo',
              'JPG, PNG (Max 10MB)',
              Colors.green,
              isDark,
              surfaceColor,
              borderColor,
              () => controller.onUploadImage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
    bool isDark,
    Color bgColor,
    Color borderColor,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacing6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: borderColor,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: AppConstants.spacing3),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111518),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacing1),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibrarySection(
    BuildContext context,
    ContentManagementController controller,
    bool isDark,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Library',
                style: TextStyle(
                  fontSize: AppConstants.h4Size,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111518),
                ),
              ),
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Show search
                      },
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusCircular,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacing2),
                        child: Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Show filter
                      },
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusCircular,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacing2),
                        child: Icon(
                          Icons.filter_list,
                          size: 20,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacing2),
        // Category chips
        GetBuilder<ContentManagementController>(
          id: ContentManagementController.tabsId,
          builder: (controller) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
            child: Row(
              children: ContentCategory.values.map((category) {
                final isSelected = controller.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: AppConstants.spacing3),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        controller.onCategoryChanged(category);
                      },
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusCircular,
                      ),
                      child: AnimatedContainer(
                        duration: AppConstants.shortAnimation,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing4,
                          vertical: AppConstants.spacing2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? Colors.white : const Color(0xFF111518))
                              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusCircular,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                          ),
                        ),
                        child: Text(
                          _getCategoryLabel(category),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white : const Color(0xFF111518)),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing4),
        Divider(
          height: 1,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
        const SizedBox(height: AppConstants.spacing4),
      ],
    );
  }

  String _getCategoryLabel(ContentCategory category) {
    switch (category) {
      case ContentCategory.all:
        return 'All';
      case ContentCategory.videos:
        return 'Videos';
      case ContentCategory.images:
        return 'Images';
      case ContentCategory.promotional:
        return 'Promotional';
      case ContentCategory.exercise:
        return 'Exercise';
    }
  }

  Widget _buildContentGrid(
    BuildContext context,
    ContentManagementController controller,
    bool isDark,
  ) {
    final items = controller.contentItems;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppConstants.spacing8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.perm_media_outlined,
                size: 64,
                color: isDark ? Colors.grey.shade600 : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: AppConstants.spacing4),
              Text(
                'No Content',
                style: TextStyle(
                  fontSize: AppConstants.h3Size,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111518),
                ),
              ),
              const SizedBox(height: AppConstants.spacing2),
              Text(
                'Upload videos or images to get started',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  color: isDark
                      ? Colors.grey.shade400
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.spacing4,
          mainAxisSpacing: AppConstants.spacing4,
          childAspectRatio: 4 / 3,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildContentCard(context, items[index], controller, isDark);
        },
      ),
    );
  }

  Widget _buildContentCard(
    BuildContext context,
    ContentItem item,
    ContentManagementController controller,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // TODO: View content details
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: item.thumbnailUrl != null
                    ? Image.network(
                        item.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder(item, isDark);
                        },
                      )
                    : _buildPlaceholder(item, isDark),
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          // Type badge
          Positioned(
            top: AppConstants.spacing2,
            right: AppConstants.spacing2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing2,
                vertical: AppConstants.spacing1 / 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.type == ContentType.video ? Icons.videocam : Icons.image,
                    size: 10,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppConstants.spacing1),
                  Text(
                    item.type == ContentType.video
                        ? (item.formattedDuration ?? 'Video')
                        : (item.fileFormat ?? 'Image'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Hover actions
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                    color: Colors.black.withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            controller.onEditContent(item);
                          },
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusCircular,
                          ),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing3),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            controller.onDeleteContent(item);
                          },
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusCircular,
                          ),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Title and category
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: AppConstants.body2Size,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spacing1 / 2),
                  Text(
                    '${item.categoryDisplayName} • ${item.type == ContentType.video ? "Video" : "Image"}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getCategoryColor(item.categoryColorName),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(ContentItem item, bool isDark) {
    return Container(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      child: Center(
        child: Icon(
          item.type == ContentType.video ? Icons.movie : Icons.image,
          size: 48,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  void _showUploadOptions(
    BuildContext context,
    ContentManagementController controller,
    bool isDark,
  ) {
    // Navigate directly to upload screen
    Get.to(
      () => const UploadContentScreen(),
      binding: UploadContentBinding(),
    )?.then((result) {
      // Reload content if upload was successful
      if (result == true) {
        controller.loadContentItems();
      }
    });
  }

  Color _getCategoryColor(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'teal':
        return Colors.teal;
      case 'green':
        return Colors.green;
      case 'grey':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

