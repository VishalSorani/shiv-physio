import 'package:get/get.dart';
import '../../../data/modules/chat_repository.dart';
import '../../../data/modules/patients_repository.dart';
import 'patient_detail_controller.dart';

class PatientDetailBinding extends Bindings {
  final String patientId;

  PatientDetailBinding(this.patientId);

  @override
  void dependencies() {
    Get.put<PatientDetailController>(
      PatientDetailController(
        Get.find<PatientsRepository>(),
        Get.find<ChatRepository>(),
        patientId,
      ),
    );
  }
}

