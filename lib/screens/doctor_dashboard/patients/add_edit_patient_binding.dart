import 'package:get/get.dart';
import '../../../data/modules/patients_repository.dart';
import '../../../data/models/user.dart' as app_models;
import 'add_edit_patient_controller.dart';

class AddEditPatientBinding extends Bindings {
  final app_models.User? patient;

  AddEditPatientBinding({this.patient});

  @override
  void dependencies() {
    Get.lazyPut<AddEditPatientController>(
      () => AddEditPatientController(
        Get.find<PatientsRepository>(),
        existingPatient: patient,
      ),
    );
  }
}

