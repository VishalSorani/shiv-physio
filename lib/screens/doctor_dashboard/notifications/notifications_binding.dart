import 'package:get/get.dart';
import '../../../data/modules/notification_repository.dart';
import 'notifications_controller.dart';

class DoctorNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DoctorNotificationsController>(
      DoctorNotificationsController(
        Get.find<NotificationRepository>(),
      ),
    );
  }
}

