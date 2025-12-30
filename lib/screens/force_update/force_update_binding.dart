import 'package:get/get.dart';

import '../../data/service/remote_config_service.dart';
import 'force_update_controller.dart';

class ForceUpdateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForceUpdateController>(
      () => ForceUpdateController(RemoteConfigService.instance),
    );
  }
}

