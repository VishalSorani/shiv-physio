import 'package:get/get.dart';
import 'appointments_controller.dart';

class AppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AppointmentsController>(AppointmentsController());
  }
}
