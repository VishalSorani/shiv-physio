import 'dart:io';


import '../../clients/network/api_service_base.dart';
import '../../clients/network/backend/api_service.dart';

// Using ApiResponse from models/api_response.dart

/// BackendApiCallService: Implementation of all API endpoints from the Postman collection
class BackendApiCallService {
  final ApiClientBase _apiService;

  BackendApiCallService({ApiClientBase? apiService})
    : _apiService = apiService ?? ApiDioClient();

  // //signup
  // Future<ApiResponse<SignupResponse>> signup(
  //   String email,
  //   String password,
  //   String fullName,
  //   String phone,
  // ) async {
  //   return await _apiService.post(
  //     ApiEndpoints.signUp,
  //     data: {
  //       'email': email,
  //       'password': password,
  //       'full_name': fullName,
  //       'phone': phone,
  //     },
  //     fromJson: (data) {
  //       final signupResponse = SignupResponse.fromJson(data['data']);
  //       return ApiResponse<SignupResponse>(
  //         success: data['success'],
  //         data: signupResponse,
  //         errors: data['error'] != null ? [data['error']['message']] : null,
  //       );
  //     },
  //   );
  // }

}
