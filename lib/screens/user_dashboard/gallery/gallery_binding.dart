import 'package:get/get.dart';
import '../../../data/modules/chat_repository.dart';
import '../../../data/service/storage_service.dart';
import '../chat/chat_list_controller.dart';

class GalleryBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<UserChatListController>(
      UserChatListController(
        Get.find<ChatRepository>(),
        Get.find<StorageService>(),
      ),
    );
  }
}
