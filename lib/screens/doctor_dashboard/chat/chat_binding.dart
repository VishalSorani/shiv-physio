import 'package:get/get.dart';
import '../../../data/modules/chat_repository.dart';
import '../../../data/service/storage_service.dart';
import 'chat_list_controller.dart';

class DoctorChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DoctorChatListController>(
      DoctorChatListController(
        Get.find<ChatRepository>(),
        Get.find<StorageService>(),
      ),
    );
  }
}
