// Gallery screen replaced with chat list screen
// Import chat list screen instead
import '../chat/chat_list_screen.dart';

/// Gallery screen now shows chat list
/// Uses UserChatListScreen and UserChatListController
class GalleryScreen extends UserChatListScreen {
  const GalleryScreen({super.key});
}
