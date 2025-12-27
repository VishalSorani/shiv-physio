import 'package:get/get.dart';
import '../../../data/modules/availability_repository.dart';
import '../../../data/modules/profile_repository.dart';
import 'profile_controller.dart';

class DoctorProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DoctorProfileController>(
      DoctorProfileController(
        Get.find<AvailabilityRepository>(),
        Get.find<ProfileRepository>(),
      ),
    );
  }
}
