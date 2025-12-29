import 'package:get/get.dart';
import '../../../data/modules/notification_repository.dart';
import 'notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NotificationsController>(
      NotificationsController(
        Get.find<NotificationRepository>(),
      ),
    );
  }
}

