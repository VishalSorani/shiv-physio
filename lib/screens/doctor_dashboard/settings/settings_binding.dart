import 'package:get/get.dart';
import '../../../data/modules/auth_repository.dart';
import '../../../data/service/navigation_service/navigation_import.dart';
import 'settings_controller.dart';

class DoctorSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DoctorSettingsController>(
      DoctorSettingsController(
        Get.find<AuthRepository>(),
        Get.find<NavigationService>(),
      ),
    );
  }
}
