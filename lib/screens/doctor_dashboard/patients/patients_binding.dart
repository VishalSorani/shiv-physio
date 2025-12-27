import 'package:get/get.dart';
import '../../../data/modules/patients_repository.dart';
import 'patients_controller.dart';

class PatientManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PatientManagementController>(
      PatientManagementController(Get.find<PatientsRepository>()),
    );
  }
}

