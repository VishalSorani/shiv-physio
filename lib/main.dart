import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shiv_physio_app/core/di/injection.dart'
    as dependenciesInjection;
import 'package:shiv_physio_app/core/constants/supabase_config.dart';
import 'package:shiv_physio_app/data/service/firebase_service.dart';
import 'package:shiv_physio_app/data/service/theme_service.dart';
import 'package:shiv_physio_app/routes/route_imports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
