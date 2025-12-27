import 'package:get/get.dart';
import '../../../data/modules/content_repository.dart';
import 'upload_content_controller.dart';

class UploadContentBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<UploadContentController>(
      UploadContentController(Get.find<ContentRepository>()),
    );
  }
}

