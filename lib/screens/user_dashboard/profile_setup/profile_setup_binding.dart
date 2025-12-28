import 'package:get/get.dart';
import 'package:shiv_physio_app/data/service/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_setup_controller.dart';

class ProfileSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileSetupController>(
      () => ProfileSetupController(
        Get.find<StorageService>(),
        Get.find<SupabaseClient>(),
      ),
    );
  }
}

