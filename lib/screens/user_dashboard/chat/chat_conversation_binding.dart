import 'package:get/get.dart';

import '../../../data/modules/chat_repository.dart';
import '../../../data/service/storage_service.dart';
import 'chat_conversation_controller.dart';

class UserChatConversationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserChatConversationController>(
      () => UserChatConversationController(
        Get.find<ChatRepository>(),
        Get.find<StorageService>(),
      ),
    );
  }
}

