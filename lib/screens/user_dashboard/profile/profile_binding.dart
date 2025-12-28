import 'package:get/get.dart';
import 'package:shiv_physio_app/data/service/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ProfileController>(
      ProfileController(Get.find<StorageService>(), Get.find<SupabaseClient>()),
    );
  }
}
