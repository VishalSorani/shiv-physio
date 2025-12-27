/// API Endpoints for the SafeCircle application
class ApiEndpoints {
  // Base URLs production
  static const String baseUrl = 'https://safecircle.cricvision.ai';
  static const String apiPrefix = "api/v1";

  static const String apiBase = '$baseUrl/$apiPrefix';

  // ==================== UTILITY METHODS ====================
  static String buildPath(String endpoint, Map<String, dynamic> params) {
    String path = endpoint;
    params.forEach((key, value) {
      path = path.replaceAll('{$key}', value.toString());
    });
    return path;
  }

  static String buildUrl(String endpoint, Map<String, dynamic> queryParams) {
    if (queryParams.isEmpty) return endpoint;

    final Uri uri = Uri.parse(endpoint);
    final finalUri = uri.replace(
      queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    return finalUri.toString();
  }

  // ==================== Auth Endpoints ====================
  static String signUp = '$apiBase/auth/signup';
  static String signIn = '$apiBase/auth/signin';
  static String verifyOtp = '$apiBase/auth/verify-otp';
  static String resendOtp = '$apiBase/auth/resend-otp';
  static String refreshToken = '$apiBase/auth/refresh';
  static String logout = '$apiBase/auth/logout';

  // ==================== User Endpoints ====================
  static String userProfile = '$apiBase/users/profile';
  static String userSettings = '$apiBase/users/settings';

  // ==================== Circle Endpoints ====================
  static String circles = '$apiBase/circles';
  static String joinCircle = '$apiBase/circles/join';

  // ==================== Location Endpoints ====================
  static String updateLocation = '$apiBase/locations/submit';
  static String getLocation = '$apiBase/locations/latest';
  static String locationHistory = '$apiBase/locations/history';

  // ==================== SOS Endpoints ====================
  static String sos = '$apiBase/sos';

  // ==================== Check-In Endpoints ====================
  static String checkIn = '$apiBase/checkins';

  // ==================== Places Endpoints ====================
  static String places = '$apiBase/places';

  // ==================== Upload Endpoints ====================
  static String uploadAvatar = '$apiBase/uploads/avatar';
}
