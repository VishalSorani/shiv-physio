import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/base_class/base_controller.dart';
import '../../../data/models/content_item.dart';
import '../../../data/modules/content_repository.dart';
import '../../doctor_dashboard/content/content_viewer_dialogs.dart' as viewer;

class ContentController extends BaseController {
  static const String contentListId = 'content_list';
  static const String appBarId = 'content_appbar';

  final ContentRepository _contentRepository;

  ContentController(this._contentRepository);

  List<ContentItem> _contentItems = [];
  List<ContentItem> get contentItems => _contentItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @override
  void onInit() {
    super.onInit();
    loadContent();
  }

  Future<void> loadContent() async {
    await handleAsyncOperation(() async {
      _isLoading = true;
      update([contentListId]);

      try {
        _contentItems = await _contentRepository.getContentItemsForPatients();
        update([contentListId]);
      } finally {
        _isLoading = false;
        update([contentListId]);
      }
    }, showLoadingIndicator: false);
  }

  void onBack() {
    navigationService.goBack();
  }

  void onContentTap(int index) {
    if (index < 0 || index >= _contentItems.length) return;
    final content = _contentItems[index];
    HapticFeedback.lightImpact();

    // For images, show image viewer dialog
    // Videos play inline in the card, so no action needed on tap
    if (content.type == ContentType.image) {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: viewer.ImageViewerDialog(item: content),
        ),
        barrierDismissible: true,
      );
    }
  }

  String? getContentImageUrl(ContentItem content) {
    if (content.type == ContentType.video) {
      return content.thumbnailUrl ?? content.fileUrl;
    }
    return content.fileUrl;
  }

  String? getContentBadge(ContentItem content) {
    switch (content.category) {
      case ContentCategory.exercise:
        if (content.description?.toLowerCase().contains('beginner') == true) {
          return 'Beginner';
        } else if (content.description?.toLowerCase().contains('advanced') ==
            true) {
          return 'Advanced';
        }
        return null;
      case ContentCategory.promotional:
        return 'Recovery Journey';
      default:
        return null;
    }
  }

  Color? getContentBadgeColor(ContentItem content) {
    final badge = getContentBadge(content);
    if (badge == 'Beginner') {
      return Colors.white;
    } else if (badge == 'Advanced') {
      return AppColors.primary;
    } else if (badge == 'Recovery Journey') {
      return Colors.white;
    }
    return null;
  }

  Color? getContentBadgeTextColor(ContentItem content) {
    final badge = getContentBadge(content);
    if (badge == 'Beginner') {
      return const Color(0xFF333333);
    } else if (badge == 'Advanced') {
      return Colors.white;
    } else if (badge == 'Recovery Journey') {
      return const Color(0xFF333333);
    }
    return null;
  }

  bool hasPlayButton(ContentItem content) {
    return content.type == ContentType.video;
  }

  String? getDuration(ContentItem content) {
    if (content.duration != null) {
      final minutes = content.duration! ~/ 60;
      final seconds = content.duration! % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return null;
  }

  @override
  void handleNetworkChange(bool isConnected) {
    handleNetworkChangeDefault(isConnected);
    if (isConnected && _contentItems.isEmpty) {
      loadContent();
    }
  }
}
