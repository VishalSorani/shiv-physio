import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shiv_physio_app/data/clients/device_info/device_info_client.dart';
import 'package:shiv_physio_app/data/clients/network/api_service_base.dart';
import 'package:shiv_physio_app/data/clients/network/backend/api_service.dart';
import 'package:shiv_physio_app/data/clients/network/network_info.dart';
import 'package:shiv_physio_app/data/clients/permission/permission_client.dart';
import 'package:shiv_physio_app/data/clients/permission/permission_handler_client.dart';
import 'package:shiv_physio_app/data/clients/storage/get_storage.dart';
import 'package:shiv_physio_app/data/clients/storage/storage_provider.dart';
import 'package:shiv_physio_app/data/service/backend/backend_api_service.dart';
import 'package:shiv_physio_app/data/service/firebase_service.dart';
import 'package:shiv_physio_app/data/service/navigation_service/navigation_import.dart';
import 'package:shiv_physio_app/data/service/network_service.dart';
import 'package:shiv_physio_app/data/service/storage_service.dart';
import 'package:shiv_physio_app/data/service/theme_service.dart';
import 'package:shiv_physio_app/data/modules/auth_repository.dart';
import 'package:shiv_physio_app/data/modules/availability_repository.dart';
import 'package:shiv_physio_app/data/modules/profile_repository.dart';
import 'package:shiv_physio_app/data/modules/doctor_home_repository.dart';
import 'package:shiv_physio_app/data/modules/appointments_repository.dart';
import 'package:shiv_physio_app/data/modules/patients_repository.dart';
import 'package:shiv_physio_app/data/modules/content_repository.dart';
import 'package:shiv_physio_app/data/modules/notification_repository.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';

Future<void> init() async {
  // Register route observer for navigation tracking
  Get.put(RouteObserver<PageRoute>());

  // Firebase services
  final firebaseService = await FirebaseAppService.initialize();
  Get.put<FirebaseAppService>(firebaseService, permanent: true);

  // Amplitude analytics
  // AmplitudeService? amplitudeService;

  // amplitudeService = await AmplitudeService.initialize('');
  // Get.put<AmplitudeService>(amplitudeService, permanent: true);

  // Core dependencies
  Get.lazyPut<NetworkInfo>(() => NetworkInfoImpl(), fenix: true);

  Get.lazyPut<NetworkService>(
    () => NetworkService(networkInfo: Get.find<NetworkInfo>()),
    fenix: true,
  );

  Get.lazyPut<StorageProvider>(() => GetxStorage(), fenix: true);

  // Register StorageService
  Get.lazyPut<StorageService>(
    () => StorageService(Get.find<StorageProvider>()),
    fenix: true,
  );

  // Theme Service
  Get.lazyPut<ThemeService>(
    () => ThemeService(Get.find<StorageProvider>()),
    fenix: true,
  );

  // Get.lazyPut<FirebaseRemoteConfig>(
  //   () => FirebaseRemoteConfig.instance,
  //   fenix: true,
  // );

  // RevenueCat service configuration
  // Get.lazyPut<RevenueCatService>(() => RevenueCatService(), fenix: true);

  // Ensure RevenueCat SDK is configured before UI starts using it
  // await Get.find<RevenueCatService>().initialize();
  // You need to register ApiService
  Get.lazyPut<ApiClientBase>(
    () => ApiDioClient(), // Or however you initialize ApiService
    fenix: true,
  );

  // BackendApiCallService
  Get.lazyPut<BackendApiCallService>(
    () => BackendApiCallService(apiService: Get.find<ApiClientBase>()),
    fenix: true,
  );

  // ======== Repositories ========
  Get.lazyPut<SupabaseClient>(() => Supabase.instance.client, fenix: true);
  Get.lazyPut<fb_auth.FirebaseAuth>(
    () => fb_auth.FirebaseAuth.instance,
    fenix: true,
  );
  Get.lazyPut<GoogleSignIn>(() => GoogleSignIn.instance, fenix: true);
  Get.lazyPut<AuthRepository>(
    () => AuthRepository(
      supabase: Get.find<SupabaseClient>(),
      storageService: Get.find<StorageService>(),
      firebaseAuth: Get.find<fb_auth.FirebaseAuth>(),
      googleSignIn: Get.find<GoogleSignIn>(),
    ),
    fenix: true,
  );

  Get.lazyPut<AvailabilityRepository>(
    () => AvailabilityRepository(
      supabase: Get.find<SupabaseClient>(),
      storageService: Get.find<StorageService>(),
    ),
    fenix: true,
  );

  Get.lazyPut<ProfileRepository>(
    () => ProfileRepository(
      supabase: Get.find<SupabaseClient>(),
      storageService: Get.find<StorageService>(),
    ),
    fenix: true,
  );

  Get.lazyPut<DoctorHomeRepository>(
    () => DoctorHomeRepository(
      supabase: Get.find<SupabaseClient>(),
      storageService: Get.find<StorageService>(),
    ),
    fenix: true,
  );

  Get.lazyPut<NotificationRepository>(
    () => NotificationRepository(
      supabase: Get.find<SupabaseClient>(),
      storageService: Get.find<StorageService>(),
      dio: Dio(),
    ),
    fenix: true,
  );

  Get.lazyPut<AppointmentsRepository>(
    () => AppointmentsRepository(
      supabase: Get.find<SupabaseClient>(),
      storageService: Get.find<StorageService>(),
      notificationRepository: Get.find<NotificationRepository>(),
    ),
    fenix: true,
  );

  Get.lazyPut<PatientsRepository>(
    () => PatientsRepository(
      supabase: Get.find<SupabaseClient>(),
      storageService: Get.find<StorageService>(),
    ),
    fenix: true,
  );

  Get.lazyPut<ContentRepository>(
    () => ContentRepository(
      supabase: Get.find<SupabaseClient>(),
      storageService: Get.find<StorageService>(),
    ),
    fenix: true,
  );

  // // Subscription repository (wraps RevenueCat service)
  // Get.lazyPut<SubscriptionRepository>(
  //   () => SubscriptionRepository(
  //     revenueCatService: Get.find<RevenueCatService>(),
  //   ),
  //   fenix: true,
  // );

  // Deep link handler service
  // Get.lazyPut<DeepLinkService>(
  //   () => DeepLinkService(navigationService: Get.find<NavigationService>()),
  //   fenix: true,
  // );

  // Navigation dependencies
  Get.lazyPut<NavigationService>(
    () => NavigationService(
      networkService: Get.find<NetworkService>(),
      enableLogging: true,
      firebaseService: firebaseService,
      // amplitudeService: amplitudeService,
    ),
    fenix: true,
  );

  // Register permission client
  Get.lazyPut<PermissionClient>(
    () => const PermissionHandlerClient(),
    fenix: true,
  );

  Get.lazyPut<DeviceInfoClient>(() => DeviceInfoClient(), fenix: true);

  // ======== Repository ========
  // Get.lazyPut<AuthRepository>(
  //   () => AuthRepository(
  //     backendApiCallService: Get.find<BackendApiCallService>(),
  //     networkService: Get.find<NetworkService>(),
  //     storageService: Get.find<StorageService>(),
  //   ),
  //   fenix: true,
  // );

  // Get.lazyPut<UserRepository>(
  //   () => UserRepository(
  //     backendApiClient: Get.find<BackendApiCallService>(),
  //     networkService: Get.find<NetworkService>(),
  //     storageProvider: Get.find<StorageService>(),
  //     deviceInfoClient: Get.find<DeviceInfoClient>(),
  //   ),
  //   fenix: true,
  // );
}
