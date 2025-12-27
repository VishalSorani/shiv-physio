import 'package:get/get.dart';
import '../../../data/modules/content_repository.dart';
import 'content_controller.dart';

class ContentManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ContentManagementController>(
      ContentManagementController(Get.find<ContentRepository>()),
    );
  }
}

