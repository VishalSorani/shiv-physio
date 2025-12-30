import 'package:get/get.dart';

import '../../../data/modules/chat_repository.dart';
import '../../../data/service/storage_service.dart';
import 'chat_conversation_controller.dart';

class DoctorChatConversationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorChatConversationController>(
      () => DoctorChatConversationController(
        Get.find<ChatRepository>(),
        Get.find<StorageService>(),
      ),
    );
  }
}

