import '../../../data/base_class/base_controller.dart';
import '../../../data/modules/content_repository.dart';
import '../../../data/models/content_item.dart';
import '../../../widgets/app_snackbar.dart';

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
  Future<void> onUploadVideo() async {
    // Navigation handled in screen
  }

  /// Handle image upload
  Future<void> onUploadImage() async {
    // Navigation handled in screen
  }

  /// Handle edit content
  Future<void> onEditContent(ContentItem item) async {
    // TODO: Navigate to edit content screen
    AppSnackBar.info(
      title: 'Coming Soon',
      message: 'Edit content feature will be available soon',
    );
  }

  /// Handle delete content
  Future<void> onDeleteContent(ContentItem item) async {
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
