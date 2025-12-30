import 'package:get/get.dart';
import 'package:shiv_physio_app/screens/user_dashboard/profile/profile_binding.dart';
import 'appointments/appointments_binding.dart';
import 'gallery/gallery_binding.dart';
import 'home/home_binding.dart';
import 'settings/settings_binding.dart';
import 'user_dashboard_controller.dart';

class UserDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Bind all child screen bindings first
    HomeBinding().dependencies();
    AppointmentsBinding().dependencies();
    GalleryBinding().dependencies(); // Chat/Messages tab
    ProfileBinding().dependencies();
    UserSettingsBinding().dependencies();

    // Bind the main dashboard controller
    Get.lazyPut<UserDashboardController>(() => UserDashboardController());
  }
}
