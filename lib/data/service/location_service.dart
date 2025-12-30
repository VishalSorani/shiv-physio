import 'dart:developer';

import 'package:dio/dio.dart';

/// Model for IP API response
class LocationData {
  final String? ip;
  final String? city;
  final String? region;
  final String? country;
  final String? countryCode;
  final double? latitude;
  final double? longitude;

  LocationData({
    this.ip,
    this.city,
    this.region,
    this.country,
    this.countryCode,
    this.latitude,
    this.longitude,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      ip: json['ip'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      country: json['country_name'] as String?,
      countryCode: json['country_code'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
    );
  }
}

/// Service for fetching user location based on IP
class LocationService {
  static LocationService? _instance;
  static const String _apiUrl = 'https://ipapi.co/json/';

  LocationService._();

  /// Get singleton instance
  static LocationService get instance {
    _instance ??= LocationService._();
    return _instance!;
  }

  /// Fetch location data from IP API
  Future<LocationData?> getLocation() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        _apiUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.statusCode == 200) {
        return LocationData.fromJson(response.data);
      } else {
        log('IP API returned status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching location: $e');
      return null;
    }
  }

  /// Get city name from location
  Future<String?> getCity() async {
    final location = await getLocation();
    return location?.city;
  }
}
