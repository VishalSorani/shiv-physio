// import 'dart:io';

// import 'package:safecircle/data/base_class/base_repository.dart';
// import 'package:safecircle/data/clients/device_info/device_info_client.dart';
// import 'package:safecircle/data/models/avatar_upload_response.dart';
// import 'package:safecircle/data/models/user.dart';
// import 'package:safecircle/data/models/user_settings.dart';
// import 'package:safecircle/data/service/backend/backend_api_service.dart';
// import 'package:safecircle/data/service/network_service.dart';
// import 'package:safecircle/data/service/storage_service.dart';

// class UserRepository extends BaseRepository {
//   final BackendApiCallService _backendApiClient;
//   final NetworkService _networkService;
//   // ignore: unused_field
//   final StorageService _storageService;

//   UserRepository({
//     required BackendApiCallService backendApiClient,
//     required NetworkService networkService,
//     required StorageService storageProvider,
//     required DeviceInfoClient deviceInfoClient,
//   }) : _backendApiClient = backendApiClient,
//        _storageService = storageProvider,
//        _networkService = networkService;

//   Future<User?> getUserProfile() async {
//     try {
//       await _networkService.checkInternetConnection();
//       final result = await _backendApiClient.getUserProfile();
//       if (result.success) {
//         await setUserToStorage(result.data!);
//         return result.data;
//       } else {
//         throw Exception(result.errors?.first);
//       }
//     } catch (e) {
//       handleRepositoryError(e);
//     }
//   }

//   Future<UserSettings?> getUserSettings() async {
//     try {
//       await _networkService.checkInternetConnection();
//       final result = await _backendApiClient.getUserSettings();
//       if (result.success) {
//         return result.data;
//       } else {
//         throw Exception(result.errors?.first);
//       }
//     } catch (e) {
//       handleRepositoryError(e);
//     }
//   }

//   Future<UserSettings?> updateUserSettings(UserSettings settings) async {
//     try {
//       await _networkService.checkInternetConnection();
//       final result = await _backendApiClient.updateUserSettings(settings);
//       if (result.success) {
//         return result.data;
//       } else {
//         throw Exception(result.errors?.first);
//       }
//     } catch (e) {
//       handleRepositoryError(e);
//     }
//   }

//   Future<bool?> updateUserProfile(User user) async {
//     try {
//       await _networkService.checkInternetConnection();
//       final result = await _backendApiClient.updateUserProfile(user);
//       if (result.success) {
//         return result.success;
//       } else {
//         throw Exception(result.errors?.first);
//       }
//     } catch (e) {
//       handleRepositoryError(e);
//     }
//   }

//   Future<AvatarUploadResponse?> uploadAvatar(File avatarFile) async {
//     try {
//       await _networkService.checkInternetConnection();
//       final result = await _backendApiClient.uploadAvatar(avatarFile);
//       if (result.success && result.data != null) {
//         return result.data;
//       } else {
//         throw Exception(result.errors?.first ?? 'Failed to upload avatar');
//       }
//     } catch (e) {
//       handleRepositoryError(e);
//     }
//   }

//   Future<void> syncUser() async {
//     try {
//       await _networkService.checkInternetConnection();
//       final result = await _backendApiClient.getUserProfile();
//       if (result.data == null) {
//         throw Exception('User not found');
//       }
//       await setUserToStorage(result.data!);
//     } catch (e) {
//       handleRepositoryError(e);
//     }
//   }

//   // has user in storage
//   Future<bool> hasUserInStorage() async {
//     return _storageService.hasUser();
//   }

//   // get user from storage
//   Future<User?> getUser() async {
//     return await hasUserInStorage()
//         ? _storageService.getUser()
//         : await getUserProfile();
//   }

//   // set user to storage
//   Future<void> setUserToStorage(User user) async {
//     await _storageService.setUser(user);
//   }

//   Future<String?> getToken() async {
//     return _storageService.getToken()?.accessToken;
//   }
// }
