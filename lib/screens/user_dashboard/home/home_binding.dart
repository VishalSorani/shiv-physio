import 'package:get/get.dart';
import '../../../../data/service/storage_service.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<StorageService>()),
    );
  }
}

