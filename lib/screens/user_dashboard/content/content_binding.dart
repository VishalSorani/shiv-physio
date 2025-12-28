import 'package:get/get.dart';
import 'package:shiv_physio_app/data/modules/content_repository.dart';
import 'content_controller.dart';

class ContentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContentController>(
      () => ContentController(
        Get.find<ContentRepository>(),
      ),
    );
  }
}

