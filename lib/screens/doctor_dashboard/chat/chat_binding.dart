import 'package:get/get.dart';
import 'chat_controller.dart';

class DoctorChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DoctorChatController>(DoctorChatController());
  }
}

