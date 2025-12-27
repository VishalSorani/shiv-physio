import 'package:get/get.dart';
import '../../../data/models/content_item.dart';
import '../../../data/modules/content_repository.dart';
import 'upload_content_controller.dart';

class UploadContentBinding extends Bindings {
  final ContentType? initialType;

  UploadContentBinding({this.initialType});

  @override
  void dependencies() {
    // Get existingContent from route arguments if available
    final existingContent = Get.arguments as ContentItem?;
    
    Get.put<UploadContentController>(
      UploadContentController(
        Get.find<ContentRepository>(),
        initialType: initialType,
        existingContent: existingContent,
      ),
    );
  }
}

