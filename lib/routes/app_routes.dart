part of 'route_imports.dart';

class AppPages {
  AppPages._();

  static final String initialRoute = SplashScreen.splashScreen;
  static final List<GetPage> routes = [
    GetPage(
      name: SplashScreen.splashScreen,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: LoginScreen.loginScreen,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: DoctorDashboardScreen.doctorDashboardScreen,
      page: () => const DoctorDashboardScreen(),
      binding: DoctorDashboardBinding(),
    ),
    GetPage(
      name: UserDashboardScreen.userDashboardScreen,
      page: () => const UserDashboardScreen(),
      binding: UserDashboardBinding(),
    ),
    GetPage(
      name: ProfileSetupScreen.profileSetupScreen,
      page: () => const ProfileSetupScreen(),
      binding: ProfileSetupBinding(),
    ),
    GetPage(
      name: ContentScreen.contentScreen,
      page: () => const ContentScreen(),
      binding: ContentBinding(),
    ),
    GetPage(
      name: BookAppointmentScreen.bookAppointmentScreen,
      page: () => const BookAppointmentScreen(),
      binding: BookAppointmentBinding(),
    ),
    GetPage(
      name: AppointmentConfirmationScreen.appointmentConfirmationScreen,
      page: () => const AppointmentConfirmationScreen(),
      binding: AppointmentConfirmationBinding(),
    ),
    GetPage(
      name: ForceUpdateScreen.forceUpdateScreen,
      page: () => const ForceUpdateScreen(),
      binding: ForceUpdateBinding(),
    ),
    // User Chat Routes
    GetPage(
      name: UserChatListScreen.chatListScreen,
      page: () => const UserChatListScreen(),
      binding: UserChatListBinding(),
    ),
    GetPage(
      name: UserChatConversationScreen.chatConversationScreen,
      page: () => const UserChatConversationScreen(),
      binding: UserChatConversationBinding(),
    ),
    // Doctor Chat Routes
    GetPage(
      name: DoctorChatListScreen.chatListScreen,
      page: () => const DoctorChatListScreen(),
      binding: DoctorChatListBinding(),
    ),
    GetPage(
      name: DoctorChatConversationScreen.chatConversationScreen,
      page: () => const DoctorChatConversationScreen(),
      binding: DoctorChatConversationBinding(),
    ),
  ];
}
