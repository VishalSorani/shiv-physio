import 'dart:developer';

import '/data/service/backend/end_points.dart';
import '/data/clients/network/backend/dio_client.dart';
import 'package:dio/dio.dart';

class ApiBaseHelper {
  late Dio dio;

  // connectTimeout
  static const int _receiveTimeout = 60;
  static const int _connectionTimeout = 60;

  static final ApiBaseHelper _instance = ApiBaseHelper._internal();
  factory ApiBaseHelper() {
    return _instance;
  }

  ApiBaseHelper._internal() {
    log('ApiBaseHelper._internal()', name: 'ApiBaseHelper');
    dio = Dio(_opts);
    dio.interceptors.add(DioInterceptor());

    log(
      'ApiBaseHelper._internal() dio.interceptors.add(DioInterceptor(null));',
      name: 'ApiBaseHelper',
    );
  }

  final BaseOptions _opts = BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    receiveDataWhenStatusError: true,
    responseType: ResponseType.json,
    connectTimeout: const Duration(seconds: _connectionTimeout),
    receiveTimeout: const Duration(seconds: _receiveTimeout),
  );

  // log on every request
  void _logRequest(RequestOptions options) {
    log(
      'REQUEST[${options.method}] => PATH: ${options.path} => DATA : ${options.data}',
      name: 'ApiBaseHelper - onRequest',
    );
  }

  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    _logRequest(options);
    handler.next(options);
  }
}
