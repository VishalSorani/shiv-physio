import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/base_class/base_screen.dart';
import '../../../data/models/content_item.dart';
import 'upload_content_controller.dart';

class UploadContentScreen extends BaseScreenView<UploadContentController> {
  const UploadContentScreen({super.key});

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
              child: GetBuilder<UploadContentController>(
                id: UploadContentController.contentId,
                builder: (ctrl) {
                  if (ctrl.isUploading) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: AppConstants.spacing4),
                          Text(
                            'Uploading content...',
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

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Content Type Selector
                        _buildTypeSelector(context, ctrl, isDark),
                        const SizedBox(height: AppConstants.spacing6),
                        // Upload Area
                        _buildUploadArea(context, ctrl, isDark),
                        const SizedBox(height: AppConstants.spacing6),
                        // Form Fields
                        GetBuilder<UploadContentController>(
                          id: UploadContentController.formId,
                          builder: (formCtrl) =>
                              _buildFormFields(context, formCtrl, isDark),
                        ),
                        // Bottom spacing for button
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button
      bottomNavigationBar: _buildBottomButton(context, controller, isDark),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    UploadContentController controller,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing4,
          vertical: AppConstants.spacing3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Cancel button
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
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing2),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: AppConstants.body1Size,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.grey.shade400
                          : const Color(0xFF60778A),
                    ),
                  ),
                ),
              ),
            ),
            // Title
            Text(
              'Upload Content',
              style: TextStyle(
                fontSize: AppConstants.h3Size,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111518),
                letterSpacing: -0.015,
              ),
            ),
            // Post button (disabled for now, will use bottom button)
            const SizedBox(width: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(
    BuildContext context,
    UploadContentController controller,
    bool isDark,
  ) {
    final bgColor = isDark ? Colors.grey.shade800 : const Color(0xFFF0F2F5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Content Type',
            style: TextStyle(
              fontSize: AppConstants.body2Size,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade200 : const Color(0xFF111518),
            ),
          ),
          const SizedBox(height: AppConstants.spacing3),
          GetBuilder<UploadContentController>(
            id: UploadContentController.typeSelectorId,
            builder: (controller) => Container(
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              padding: const EdgeInsets.all(AppConstants.spacing1),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeOption(
                      context,
                      controller,
                      ContentType.image,
                      Icons.image,
                      'Image',
                      isDark,
                      bgColor,
                    ),
                  ),
                  Expanded(
                    child: _buildTypeOption(
                      context,
                      controller,
                      ContentType.video,
                      Icons.videocam,
                      'Video',
                      isDark,
                      bgColor,
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

  Widget _buildTypeOption(
    BuildContext context,
    UploadContentController controller,
    ContentType type,
    IconData icon,
    String label,
    bool isDark,
    Color bgColor,
  ) {
    final isSelected = controller.selectedType == type;
    final selectedBgColor = isDark ? Colors.grey.shade700 : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          controller.onTypeChanged(type);
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: AnimatedContainer(
          duration: AppConstants.shortAnimation,
          height: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? selectedBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.grey.shade400 : const Color(0xFF60778A)),
              ),
              const SizedBox(width: AppConstants.spacing2),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.body2Size,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                            ? Colors.grey.shade400
                            : const Color(0xFF60778A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadArea(
    BuildContext context,
    UploadContentController controller,
    bool isDark,
  ) {
    final borderColor = isDark ? Colors.grey.shade700 : const Color(0xFFDBE1E6);
    final bgColor = isDark ? Colors.grey.shade900 : const Color(0xFFF8F9FA);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
      child: GetBuilder<UploadContentController>(
        id: UploadContentController.filePreviewId,
        builder: (controller) {
          if (controller.hasFile) {
            return _buildFilePreview(context, controller, isDark);
          }

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                controller.onPickFile();
              },
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing6,
                  vertical: 40,
                ),
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
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_upload,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      'Tap to upload file',
                      style: TextStyle(
                        fontSize: AppConstants.body1Size,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF111518),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing1),
                    Text(
                      controller.selectedType == ContentType.image
                          ? 'JPG, PNG (Max 10MB)'
                          : 'MP4, MOV (Max 500MB)',
                      style: TextStyle(
                        fontSize: AppConstants.body2Size,
                        color: isDark
                            ? Colors.grey.shade400
                            : const Color(0xFF60778A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilePreview(
    BuildContext context,
    UploadContentController controller,
    bool isDark,
  ) {
    final file = controller.selectedFile!;
    final isImage = controller.selectedType == ContentType.image;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : const Color(0xFFDBE1E6),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            child: AspectRatio(
              aspectRatio: isImage ? 16 / 9 : 4 / 3,
              child: isImage
                  ? Image.file(File(file.path), fit: BoxFit.cover)
                  : Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 64,
                              color: Colors.white,
                            ),
                            const SizedBox(height: AppConstants.spacing2),
                            Text(
                              file.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: AppConstants.body2Size,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          // Remove button
          Positioned(
            top: AppConstants.spacing2,
            right: AppConstants.spacing2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.onCancel();
                },
                borderRadius: BorderRadius.circular(
                  AppConstants.radiusCircular,
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(
    BuildContext context,
    UploadContentController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Input
          _buildTextField(
            context,
            label: 'Title',
            hint: 'e.g., Knee Rehabilitation Exercise',
            value: controller.title,
            onChanged: controller.onTitleChanged,
            isDark: isDark,
          ),
          const SizedBox(height: AppConstants.spacing6),
          // Category Selection
          _buildCategorySelector(context, controller, isDark),
          const SizedBox(height: AppConstants.spacing6),
          // Description Input
          _buildTextArea(
            context,
            label: 'Description',
            hint:
                'Enter a brief description to help patients understand this content...',
            value: controller.description,
            onChanged: controller.onDescriptionChanged,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
    required bool isDark,
  }) {
    final bgColor = isDark ? Colors.grey.shade800 : const Color(0xFFF0F2F5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade200 : const Color(0xFF111518),
          ),
        ),
        const SizedBox(height: AppConstants.spacing2),
        TextField(
          onChanged: onChanged,
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade500 : const Color(0xFF60778A),
            ),
            filled: true,
            fillColor: bgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(AppConstants.spacing4),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF111518),
            fontSize: AppConstants.body1Size,
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea(
    BuildContext context, {
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
    required bool isDark,
  }) {
    final bgColor = isDark ? Colors.grey.shade800 : const Color(0xFFF0F2F5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade200 : const Color(0xFF111518),
          ),
        ),
        const SizedBox(height: AppConstants.spacing2),
        TextField(
          onChanged: onChanged,
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          maxLines: 5,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade500 : const Color(0xFF60778A),
            ),
            filled: true,
            fillColor: bgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(AppConstants.spacing4),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF111518),
            fontSize: AppConstants.body1Size,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(
    BuildContext context,
    UploadContentController controller,
    bool isDark,
  ) {
    final categories = [
      ContentCategory.promotional,
      ContentCategory.exercise,
      ContentCategory.videos,
      ContentCategory.images,
    ];

    final categoryLabels = {
      ContentCategory.promotional: 'About Clinic',
      ContentCategory.exercise: 'Exercise Guides',
      ContentCategory.videos: 'Treatment Videos',
      ContentCategory.images: 'Patient Testimonials',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: AppConstants.body2Size,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade200 : const Color(0xFF111518),
          ),
        ),
        const SizedBox(height: AppConstants.spacing2),
        Wrap(
          spacing: AppConstants.spacing2,
          runSpacing: AppConstants.spacing2,
          children: categories.map((category) {
            final isSelected = controller.selectedCategory == category;
            return Material(
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
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusCircular,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                                ? Colors.grey.shade700
                                : const Color(0xFFDBE1E6)),
                    ),
                  ),
                  child: Text(
                    categoryLabels[category] ?? category.toDb(),
                    style: TextStyle(
                      fontSize: AppConstants.body2Size,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                                ? Colors.grey.shade300
                                : const Color(0xFF60778A)),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    UploadContentController controller,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.backgroundDark : Colors.white).withOpacity(
          0.95,
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          ),
        ),
      ),
      child: GetBuilder<UploadContentController>(
        id: UploadContentController.contentId,
        builder: (controller) => Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.canUpload
                ? () {
                    HapticFeedback.lightImpact();
                    controller.onUpload();
                  }
                : null,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            child: AnimatedContainer(
              duration: AppConstants.shortAnimation,
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: controller.canUpload
                    ? AppColors.primary
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                boxShadow: controller.canUpload
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload, color: Colors.white, size: 20),
                  const SizedBox(width: AppConstants.spacing2),
                  Text(
                    'Upload Content',
                    style: const TextStyle(
                      fontSize: AppConstants.body1Size,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
