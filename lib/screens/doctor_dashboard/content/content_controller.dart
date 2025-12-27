import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/modules/content_repository.dart';
import '../../../data/models/content_item.dart';
import '../../../widgets/app_snackbar.dart';
import 'content_viewer_dialogs.dart' as viewer;
import 'upload_content_binding.dart';
import 'upload_content_screen.dart';

class ContentManagementController extends BaseController {
  static const String contentId = 'content_management_content';
  static const String libraryId = 'content_library';
  static const String tabsId = 'content_tabs';
  static const String countId = 'content_count';

  final ContentRepository _contentRepository;

  ContentManagementController(this._contentRepository);

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Selected category filter
  ContentCategory _selectedCategory = ContentCategory.all;
  ContentCategory get selectedCategory => _selectedCategory;

  // Content items
  List<ContentItem> _allContentItems = [];
  List<ContentItem> get contentItems {
    if (_selectedCategory == ContentCategory.all) {
      return _allContentItems;
    }
    return _allContentItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  // Total count
  int _totalCount = 0;
  int get totalCount => _totalCount;

  /// Load content items from Supabase
  Future<void> loadContentItems({bool showLoading = true}) async {
    await handleAsyncOperation(() async {
      if (showLoading) {
        _isLoading = true;
        update([contentId]);
      }

      try {
        // Load all content items
        _allContentItems = await _contentRepository.getContentItems();

        // Get total count
        _totalCount = await _contentRepository.getContentCount();

        update([libraryId, countId]);
      } finally {
        if (showLoading) {
          _isLoading = false;
          update([contentId]);
        }
      }
    });
  }

  /// Refresh content items (for pull-to-refresh)
  Future<void> refreshContentItems() async {
    await loadContentItems(showLoading: false);
  }

  /// Change selected category filter
  void onCategoryChanged(ContentCategory category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      update([tabsId, libraryId]);
    }
  }

  /// Handle video upload
  void onUploadVideo() {
    // Navigate to upload screen with video type pre-selected
    Get.to(
      () => const UploadContentScreen(initialType: ContentType.video),
      binding: UploadContentBinding(initialType: ContentType.video),
    )?.then((result) {
      // Reload content if upload was successful
      if (result == true) {
        loadContentItems();
      }
    });
  }

  /// Handle image upload
  void onUploadImage() {
    // Navigate to upload screen with image type pre-selected
    Get.to(
      () => const UploadContentScreen(initialType: ContentType.image),
      binding: UploadContentBinding(initialType: ContentType.image),
    )?.then((result) {
      // Reload content if upload was successful
      if (result == true) {
        loadContentItems();
      }
    });
  }

  /// Handle edit content
  void onEditContent(ContentItem item) {
    // Navigate to upload screen with existing content data for editing
    Get.to(
      () => UploadContentScreen(
        initialType: item.type,
        existingContent: item,
      ),
      binding: UploadContentBinding(initialType: item.type),
      arguments: item, // Pass as route argument
    )?.then((result) {
      // Reload content if update was successful
      if (result == true) {
        loadContentItems();
      }
    });
  }

  /// Handle delete content with confirmation
  Future<void> onDeleteContent(ContentItem item) async {
    // Show confirmation dialog
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Content'),
        content: Text(
          'Are you sure you want to delete "${item.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await handleAsyncOperation(() async {
        await _contentRepository.deleteContent(item.id);
        // Reload content
        await loadContentItems();
        AppSnackBar.success(
          title: 'Success',
          message: 'Content deleted successfully',
        );
      });
    }
  }

  /// Handle view/play content
  void onViewContent(ContentItem item) {
    if (item.type == ContentType.video) {
      // Show video player dialog
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: viewer.VideoPlayerDialog(item: item),
        ),
        barrierDismissible: true,
      );
    } else {
      // Show image viewer dialog
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: viewer.ImageViewerDialog(item: item),
        ),
        barrierDismissible: true,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadContentItems();
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
    if (isConnected) {
      loadContentItems();
    }
  }
}
