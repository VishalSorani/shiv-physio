import 'package:get/get.dart';
import '../../../data/modules/appointments_repository.dart';
import 'appointments_controller.dart';

class AppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AppointmentsController>(
      AppointmentsController(Get.find<AppointmentsRepository>()),
    );
  }
}
