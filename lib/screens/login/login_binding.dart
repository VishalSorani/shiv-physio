import 'package:get/get.dart';

import '../../data/modules/auth_repository.dart';
import '../../data/service/remote_config_service.dart';
import '../../data/service/storage_service.dart';
import 'login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(
        Get.find<AuthRepository>(),
        Get.find<StorageService>(),
        RemoteConfigService.instance,
      ),
    );
  }
}
