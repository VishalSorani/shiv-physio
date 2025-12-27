import '../../../data/base_class/base_controller.dart';

class GalleryController extends BaseController {
  static const String contentId = 'gallery_content';

  @override
  void handleNetworkChange(bool isConnected) {
    // ignore: discarded_futures
    handleNetworkChangeDefault(isConnected);
  }
}

