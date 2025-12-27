import 'package:get/get.dart';
import 'appointments/appointments_binding.dart';
import 'chat/chat_binding.dart';
import 'home/home_binding.dart';
import 'profile/profile_binding.dart';
import 'doctor_dashboard_controller.dart';

class DoctorDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Bind all child screen bindings first
    DoctorHomeBinding().dependencies();
    DoctorAppointmentsBinding().dependencies();
    DoctorChatBinding().dependencies();
    DoctorProfileBinding().dependencies();

    // Bind the main dashboard controller
    Get.lazyPut<DoctorDashboardController>(() => DoctorDashboardController());
  }
}
