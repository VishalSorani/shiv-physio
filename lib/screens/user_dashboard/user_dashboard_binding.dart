import 'package:get/get.dart';
import 'appointments/appointments_binding.dart';
import 'home/home_binding.dart';
import 'user_dashboard_controller.dart';

class UserDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Bind all child screen bindings first
    HomeBinding().dependencies();
    AppointmentsBinding().dependencies();

    // Bind the main dashboard controller
    Get.lazyPut<UserDashboardController>(() => UserDashboardController());
  }
}
