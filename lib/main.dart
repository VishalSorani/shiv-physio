import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shiv_physio_app/core/di/injection.dart'
    as dependenciesInjection;
import 'package:shiv_physio_app/core/constants/supabase_config.dart';
import 'package:shiv_physio_app/data/service/firebase_service.dart';
import 'package:shiv_physio_app/data/service/theme_service.dart';
import 'package:shiv_physio_app/data/service/onesignal_service.dart';
import 'package:shiv_physio_app/routes/route_imports.dart';
import 'package:shiv_physio_app/screens/user_dashboard/home/home_controller.dart';
import 'package:shiv_physio_app/screens/user_dashboard/appointments/appointments_controller.dart';
import 'package:shiv_physio_app/screens/doctor_dashboard/home/home_controller.dart' as doctor_home;
import 'package:shiv_physio_app/screens/doctor_dashboard/appointments/appointments_controller.dart' as doctor_appointments;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handle foreground notification - refresh screens
void _handleForegroundNotification(dynamic notification) {
  try {
    // Refresh user home screen if controller exists
    try {
      final homeController = Get.find<HomeController>();
      homeController.loadData();
      homeController.loadUnreadNotificationCount(); // Refresh unread count
    } catch (e) {
      // Controller not found, ignore
    }

    // Refresh user appointments screen if controller exists
    try {
      final appointmentsController = Get.find<AppointmentsController>();
      appointmentsController.refreshAppointments();
    } catch (e) {
      // Controller not found, ignore
    }

    // Refresh doctor home screen if controller exists
    try {
      final doctorHomeController = Get.find<doctor_home.DoctorHomeController>();
      doctorHomeController.refreshHomeData();
    } catch (e) {
      // Controller not found, ignore
    }

    // Refresh doctor appointments screen if controller exists
    try {
      final doctorAppointmentsController = Get.find<doctor_appointments.DoctorAppointmentsController>();
      doctorAppointmentsController.refreshAppointmentRequests();
    } catch (e) {
      // Controller not found, ignore
    }
  } catch (e) {
    debugPrint('Error handling foreground notification: $e');
  }
}

/// Handle notification opened
void _handleNotificationOpened(dynamic result) {
  try {
    // Extract notification data if available
    final data = (result as dynamic).notification?.additionalData;
    if (data != null) {
      // Handle navigation based on notification type
      // TODO: Implement navigation logic
    }
  } catch (e) {
    debugPrint('Error handling notification opened: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseAppService.initialize();

  // Supabase must be initialized before repositories/controllers use it.
  if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
    throw Exception(
      'Supabase is not configured. Please set SupabaseConfig.url and SupabaseConfig.anonKey.',
    );
  }
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Initialize OneSignal with notification handlers
  try {
    await OneSignalService.initialize(
      onNotificationReceived: _handleForegroundNotification,
      onNotificationOpened: _handleNotificationOpened,
    );
  } catch (e) {
    // OneSignal initialization failure shouldn't break the app
    debugPrint('OneSignal initialization failed: $e');
  }

  await dependenciesInjection.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.routes,
      themeMode: themeService.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
    );
  }
}
