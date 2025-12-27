import '../../../data/base_class/base_controller.dart';

class ProfileController extends BaseController {
  static const String contentId = 'profile_content';

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
  }
}

