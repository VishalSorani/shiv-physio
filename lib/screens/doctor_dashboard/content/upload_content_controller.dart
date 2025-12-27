import 'package:image_picker/image_picker.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/modules/content_repository.dart';
import '../../../data/models/content_item.dart';
import '../../../widgets/app_snackbar.dart';

class UploadContentController extends BaseController {
  static const String contentId = 'upload_content_content';
  static const String typeSelectorId = 'content_type_selector';
  static const String filePreviewId = 'file_preview';
  static const String formId = 'upload_form';

  final ContentRepository _contentRepository;
  final ImagePicker _imagePicker = ImagePicker();
  final ContentType? _initialType;
  final ContentItem? _existingContent;

  UploadContentController(
    this._contentRepository, {
    ContentType? initialType,
    ContentItem? existingContent,
  })  : _initialType = initialType,
        _existingContent = existingContent;

  // Content type (Image or Video)
  ContentType _selectedType = ContentType.image;
  ContentType get selectedType => _selectedType;

  @override
  void onInit() {
    super.onInit();
    // If editing existing content, populate form
    final existing = _existingContent;
    if (existing != null) {
      _selectedType = existing.type;
      _title = existing.title;
      _description = existing.description ?? '';
      _selectedCategory = existing.category;
      // Note: We can't set _selectedFile from existing content URL
      // User would need to re-upload if they want to change the file
      update([typeSelectorId, formId, contentId]);
    } else {
      // Set initial type if provided
      final initialType = _initialType;
      if (initialType != null) {
        _selectedType = initialType;
        update([typeSelectorId]);
      }
    }
  }

  bool get isEditing => _existingContent != null;

  // Selected file
  XFile? _selectedFile;
  XFile? get selectedFile => _selectedFile;
  bool get hasFile => _selectedFile != null;

  // Form fields
  String _title = '';
  String get title => _title;

  ContentCategory _selectedCategory = ContentCategory.promotional;
  ContentCategory get selectedCategory => _selectedCategory;

  String _description = '';
  String get description => _description;

  // Upload state
  bool _isUploading = false;
  bool get isUploading => _isUploading;

  // Validation
  bool get canUpload {
    return hasFile && _title.trim().isNotEmpty && !_isUploading;
  }

  /// Change content type (Image/Video)
  void onTypeChanged(ContentType type) {
    if (_selectedType != type) {
      _selectedType = type;
      _selectedFile = null; // Clear selected file when type changes
      update([typeSelectorId, filePreviewId, contentId]); // Update button state too
    }
  }

  /// Pick file (image or video)
  Future<void> onPickFile() async {
    try {
      final XFile? file;
      if (_selectedType == ContentType.image) {
        file = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
      } else {
        file = await _imagePicker.pickVideo(source: ImageSource.gallery);
      }

      if (file != null) {
        _selectedFile = file;
        update([filePreviewId, contentId]); // Update button state too
      }
    } catch (e) {
      AppSnackBar.error(
        title: 'Error',
        message: 'Failed to pick file: ${e.toString()}',
      );
    }
  }

  /// Update title
  void onTitleChanged(String value) {
    _title = value;
    update([formId, contentId]); // Update button state too
  }

  /// Update category
  void onCategoryChanged(ContentCategory category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      update([formId]);
    }
  }

  /// Update description
  void onDescriptionChanged(String value) {
    _description = value;
    update([formId]);
  }

  /// Upload content
  Future<void> onUpload() async {
    if (!canUpload) {
      AppSnackBar.error(
        title: 'Validation Error',
        message: 'Please select a file and enter a title',
      );
      return;
    }

    await handleAsyncOperation(() async {
      _isUploading = true;
      update([contentId]);

      try {
        final file = _selectedFile!;
        final filePath = file.path;
        final fileName = file.name;

        // Upload file to Firebase Storage
        final fileUrl = await _contentRepository.uploadFileToStorage(
          filePath: filePath,
          fileName: fileName,
          contentType: _selectedType,
        );

        // Generate thumbnail URL if it's a video (for now, use same URL)
        String? thumbnailUrl;
        if (_selectedType == ContentType.video) {
          // TODO: Generate thumbnail from video
          thumbnailUrl = fileUrl;
        } else {
          thumbnailUrl = fileUrl; // For images, use the same URL as thumbnail
        }

        // Save content to Supabase
        await _contentRepository.uploadContent(
          filePath: filePath,
          type: _selectedType,
          category: _selectedCategory,
          title: _title.trim(),
          description: _description.trim().isEmpty ? null : _description.trim(),
          fileUrl: fileUrl,
          thumbnailUrl: thumbnailUrl,
        );

        AppSnackBar.success(
          title: 'Success',
          message: 'Content uploaded successfully',
        );

        // Navigate back
        // ignore: use_build_context_synchronously
        // Get.back(result: true); // Return true to indicate success
      } catch (e) {
        AppSnackBar.error(
          title: 'Upload Failed',
          message: 'Failed to upload content: ${e.toString()}',
        );
        rethrow;
      } finally {
        _isUploading = false;
        update([contentId]);
      }
    });
  }

  /// Cancel upload
  void onCancel() {
    // Clear form
    _selectedFile = null;
    _title = '';
    _description = '';
    _selectedCategory = ContentCategory.promotional;
    update([contentId, filePreviewId, formId]);
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // TODO: implement handleNetworkChange
  }
}
