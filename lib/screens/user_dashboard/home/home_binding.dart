import 'package:get/get.dart';
import '../../../../data/modules/appointments_repository.dart';
import '../../../../data/modules/content_repository.dart';
import '../../../../data/modules/notification_repository.dart';
import '../../../../data/service/storage_service.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(
      HomeController(
        Get.find<StorageService>(),
        Get.find<AppointmentsRepository>(),
        Get.find<ContentRepository>(),
        Get.find<NotificationRepository>(),
      ),
    );
  }
}
