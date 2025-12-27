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
  ];
}
