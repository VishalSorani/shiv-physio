import 'package:get/get.dart';
import '../../../data/modules/appointments_repository.dart';
import 'appointments_controller.dart';

class DoctorAppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DoctorAppointmentsController>(
      DoctorAppointmentsController(Get.find<AppointmentsRepository>()),
    );
  }
}
