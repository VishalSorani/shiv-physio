// Doctor chat screen replaced with chat list screen
// Import chat list screen instead
import 'chat_list_screen.dart';
import 'chat_list_controller.dart';

class DoctorChatScreen extends DoctorChatListScreen {
  const DoctorChatScreen({super.key});
}

// Keep chat controller for backward compatibility but use chat list controller
class DoctorChatController extends DoctorChatListController {
  DoctorChatController(super.chatRepository, super.storageService);
}
