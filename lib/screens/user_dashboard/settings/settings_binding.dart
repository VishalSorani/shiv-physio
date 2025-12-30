import 'package:get/get.dart';
import '../../../data/modules/auth_repository.dart';
import '../../../data/service/navigation_service/navigation_import.dart';
import '../../../data/service/remote_config_service.dart';
import 'settings_controller.dart';

class UserSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<UserSettingsController>(
      UserSettingsController(
        Get.find<AuthRepository>(),
        Get.find<NavigationService>(),
        RemoteConfigService.instance,
      ),
    );
  }
}
