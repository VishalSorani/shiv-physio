import '../../../data/base_class/base_controller.dart';

class DoctorChatController extends BaseController {
  static const String contentId = 'doctor_chat_content';

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
  }
}

