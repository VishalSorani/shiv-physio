import 'dart:developer';
import 'dart:io';
import 'dart:async';
import '/data/clients/network/api_service_base.dart';
import '/data/clients/network/backend/api_base_helper.dart';
import '/data/clients/network/backend/exceptions/network_exception.dart';
import '/data/clients/network/backend/error_handling/network_error_constants.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';

import 'package:dio/dio.dart';

/// ApiDioClient: Common class for handling all API calls
class ApiDioClient implements ApiClientBase {
  late Dio _dio;
  static final ApiDioClient _singleton = ApiDioClient._internal();

  factory ApiDioClient() {
    return _singleton;
  }

  ApiDioClient._internal() {
    _dio = ApiBaseHelper().dio;
  }

  /// Log method for API service
  void _log(
    String message, {
    String? methodName,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      message,
      name: "ApiDioClient${methodName != null ? ' -> $methodName' : ''}",
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Generic GET method
  @override
  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    required T Function(dynamic data) fromJson,
  }) async {
    try {
      _log('GET Request started', methodName: endpoint);

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      _log(
        'GET Request successful, response-> $response ',
        methodName: endpoint,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      _log(
        'GET Request failed',
        methodName: endpoint,
        error: e,
        stackTrace: e.stackTrace,
      );
      throw _handleDioError(e);
    } on SocketException catch (e) {
      _log(
        'GET Request failed with socket exception',
        methodName: endpoint,
        error: e,
      );
      throw NetworkException.fromSocketException(e);
    } on TimeoutException catch (e) {
      _log('GET Request timed out', methodName: endpoint, error: e);
      throw NetworkException(
        code: NetworkErrorCode.receiveTimeout,
        message: NetworkErrorMessage.receiveTimeout,
        originalError: e,
      );
    } catch (e, stackTrace) {
      _log(
        'GET Request failed with unexpected error',
        methodName: endpoint,
        error: e,
        stackTrace: stackTrace,
      );
      throw NetworkException(
        code: NetworkErrorCode.unknown,
        message: NetworkErrorMessage.unknown,
        originalError: e,
      );
    }
  }

  /// Generic POST method
  @override
  Future<T> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required T Function(dynamic data) fromJson,
  }) async {
    try {
      _log('POST Request started', methodName: endpoint);

      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      _log(
        'POST Request successful, response-> $response ',
        methodName: endpoint,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      _log(
        'POST Request failed',
        methodName: endpoint,
        error: e,
        stackTrace: e.stackTrace,
      );
      throw _handleDioError(e);
    } on SocketException catch (e) {
      _log(
        'POST Request failed with socket exception',
        methodName: endpoint,
        error: e,
      );
      throw NetworkException.fromSocketException(e);
    } on TimeoutException catch (e) {
      _log('POST Request timed out', methodName: endpoint, error: e);
      throw NetworkException(
        code: NetworkErrorCode.receiveTimeout,
        message: NetworkErrorMessage.receiveTimeout,
        originalError: e,
      );
    } catch (e, stackTrace) {
      _log(
        'POST Request failed with unexpected error',
        methodName: endpoint,
        error: e,
        stackTrace: stackTrace,
      );
      throw NetworkException(
        code: NetworkErrorCode.unknown,
        message: NetworkErrorMessage.unknown,
        originalError: e,
      );
    }
  }

  /// Generic PUT method
  @override
  Future<T> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required T Function(dynamic data) fromJson,
  }) async {
    try {
      _log('PUT Request started', methodName: endpoint);

      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      _log(
        'PUT Request successful, response-> $response ',
        methodName: endpoint,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      _log(
        'PUT Request failed',
        methodName: endpoint,
        error: e,
        stackTrace: e.stackTrace,
      );
      throw _handleDioError(e);
    } on SocketException catch (e) {
      _log(
        'PUT Request failed with socket exception',
        methodName: endpoint,
        error: e,
      );
      throw NetworkException.fromSocketException(e);
    } on TimeoutException catch (e) {
      _log('PUT Request timed out', methodName: endpoint, error: e);
      throw NetworkException(
        code: NetworkErrorCode.receiveTimeout,
        message: NetworkErrorMessage.receiveTimeout,
        originalError: e,
      );
    } catch (e, stackTrace) {
      _log(
        'PUT Request failed with unexpected error',
        methodName: endpoint,
        error: e,
        stackTrace: stackTrace,
      );
      throw NetworkException(
        code: NetworkErrorCode.unknown,
        message: NetworkErrorMessage.unknown,
        originalError: e,
      );
    }
  }

  @override
  Future<T> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required T Function(dynamic data) fromJson,
  }) async {
    try {
      _log('PATCH Request started', methodName: endpoint);

      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      _log(
        'PATCH Request successful, response-> $response ',
        methodName: endpoint,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      _log(
        'PATCH Request failed',
        methodName: endpoint,
        error: e,
        stackTrace: e.stackTrace,
      );
      throw _handleDioError(e);
    } on SocketException catch (e) {
      _log(
        'PATCH Request failed with socket exception',
        methodName: endpoint,
        error: e,
      );
      throw NetworkException.fromSocketException(e);
    } on TimeoutException catch (e) {
      _log('PATCH Request timed out', methodName: endpoint, error: e);
      throw NetworkException(
        code: NetworkErrorCode.receiveTimeout,
        message: NetworkErrorMessage.receiveTimeout,
        originalError: e,
      );
    } catch (e, stackTrace) {
      _log(
        'PATCH Request failed with unexpected error',
        methodName: endpoint,
        error: e,
        stackTrace: stackTrace,
      );
      throw NetworkException(
        code: NetworkErrorCode.unknown,
        message: NetworkErrorMessage.unknown,
        originalError: e,
      );
    }
  }

  /// Generic DELETE method
  @override
  Future<T> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic data) fromJson,
  }) async {
    try {
      _log('DELETE Request started', methodName: endpoint);

      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      _log(
        'DELETE Request successful, response-> $response ',
        methodName: endpoint,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      _log(
        'DELETE Request failed',
        methodName: endpoint,
        error: e,
        stackTrace: e.stackTrace,
      );
      throw _handleDioError(e);
    } on SocketException catch (e) {
      _log(
        'DELETE Request failed with socket exception',
        methodName: endpoint,
        error: e,
      );
      throw NetworkException.fromSocketException(e);
    } on TimeoutException catch (e) {
      _log('DELETE Request timed out', methodName: endpoint, error: e);
      throw NetworkException(
        code: NetworkErrorCode.receiveTimeout,
        message: NetworkErrorMessage.receiveTimeout,
        originalError: e,
      );
    } catch (e, stackTrace) {
      _log(
        'DELETE Request failed with unexpected error',
        methodName: endpoint,
        error: e,
        stackTrace: stackTrace,
      );
      throw NetworkException(
        code: NetworkErrorCode.unknown,
        message: NetworkErrorMessage.unknown,
        originalError: e,
      );
    }
  }

  /// Handle Dio errors using NetworkException
  NetworkException _handleDioError(DioException error) {
    // Create and return a NetworkException
    return NetworkException.fromDioError(error);
  }

  /// Upload a file
  @override
  Future<T> uploadFile<T>(
    String endpoint, {
    required File file,
    String fileKey = 'file',
    String fileName = 'file',
    String mimeType = 'application/octet-stream',
    Map<String, dynamic>? extraData,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    required T Function(dynamic data) fromJson,
  }) async {
    try {
      _log('UPLOAD Request started', methodName: endpoint);

      // Create form data
      final formData = FormData();

      // Add file
      formData.files.add(
        MapEntry(
          fileKey,
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: mimeType.isNotEmpty ? MediaType.parse(mimeType) : null,
          ),
        ),
      );

      // Add extra data if provided
      if (extraData != null) {
        extraData.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );

      _log(
        'UPLOAD Request successful, response-> $response ',
        methodName: endpoint,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      _log(
        'UPLOAD Request failed',
        methodName: endpoint,
        error: e,
        stackTrace: e.stackTrace,
      );
      throw _handleDioError(e);
    } on SocketException catch (e) {
      _log(
        'UPLOAD Request failed with socket exception',
        methodName: endpoint,
        error: e,
      );
      throw NetworkException.fromSocketException(e);
    } on TimeoutException catch (e) {
      _log('UPLOAD Request timed out', methodName: endpoint, error: e);
      throw NetworkException(
        code: NetworkErrorCode.receiveTimeout,
        message: NetworkErrorMessage.receiveTimeout,
        originalError: e,
      );
    } catch (e, stackTrace) {
      _log(
        'UPLOAD Request failed with unexpected error',
        methodName: endpoint,
        error: e,
        stackTrace: stackTrace,
      );
      throw NetworkException(
        code: NetworkErrorCode.unknown,
        message: 'An unexpected error occurred during file upload',
        originalError: e,
      );
    }
  }

  /// Download a file
  @override
  Future<File> downloadFile(
    String endpoint, {
    required String savePath,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      _log('DOWNLOAD Request started', methodName: endpoint);

      // final response =
      await _dio.download(
        endpoint,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      _log('DOWNLOAD Request successful', methodName: endpoint);
      return File(savePath);
    } on DioException catch (e) {
      _log(
        'DOWNLOAD Request failed',
        methodName: endpoint,
        error: e,
        stackTrace: e.stackTrace,
      );
      throw _handleDioError(e);
    } on SocketException catch (e) {
      _log(
        'DOWNLOAD Request failed with socket exception',
        methodName: endpoint,
        error: e,
      );
      throw NetworkException.fromSocketException(e);
    } on TimeoutException catch (e) {
      _log('DOWNLOAD Request timed out', methodName: endpoint, error: e);
      throw NetworkException(
        code: NetworkErrorCode.receiveTimeout,
        message: NetworkErrorMessage.receiveTimeout,
        originalError: e,
      );
    } catch (e, stackTrace) {
      _log(
        'DOWNLOAD Request failed with unexpected error',
        methodName: endpoint,
        error: e,
        stackTrace: stackTrace,
      );
      throw NetworkException(
        code: NetworkErrorCode.unknown,
        message: 'An unexpected error occurred during file download',
        originalError: e,
      );
    }
  }
}
