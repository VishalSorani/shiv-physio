import 'package:get/get.dart';

import '../../../data/modules/chat_repository.dart';
import '../../../data/service/storage_service.dart';
import 'chat_list_controller.dart';

class UserChatListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserChatListController>(
      () => UserChatListController(
        Get.find<ChatRepository>(),
        Get.find<StorageService>(),
      ),
    );
  }
}

