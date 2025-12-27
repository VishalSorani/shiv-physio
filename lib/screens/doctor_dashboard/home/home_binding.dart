import 'package:get/get.dart';
import '../../../data/modules/doctor_home_repository.dart';
import 'home_controller.dart';

class DoctorHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DoctorHomeController>(
      DoctorHomeController(Get.find<DoctorHomeRepository>()),
    );
  }
}
