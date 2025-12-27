import 'package:get/get.dart';

import '../../data/service/storage_service.dart';
import 'splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(Get.find<StorageService>()),
    );
  }
}
