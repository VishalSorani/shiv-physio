import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:shiv_physio_app/data/service/storage_service.dart';

/// DioInterceptor class for logging and handling request/response/error
class DioInterceptor extends Interceptor {
  final bool enableRequestLogs;
  final bool enableResponseLogs;
  final bool enableErrorLogs;
  final bool enableHeaders;
  final bool enableRequestBody;
  final bool enableResponseBody;

  /// Constructor with default values
  DioInterceptor({
    this.enableRequestLogs = true,
    this.enableResponseLogs = true,
    this.enableErrorLogs = true,
    this.enableHeaders = true,
    this.enableRequestBody = true,
    this.enableResponseBody = true,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (enableRequestLogs) {
      _logRequest(options);
    }
    try {
      // Get the authentication client from your dependency injection
      final storageService = getx.Get.find<StorageService>();
      // final authClient = getx.Get.find<AuthApi>();

      // Check if user is logged in

      String? isLoggedIn;
      if (options.headers.containsKey('Authorization')) {
        isLoggedIn = options.headers['Authorization'] as String;
        //remove Bearer from the token
        isLoggedIn = isLoggedIn.replaceAll('Bearer ', '');
      } else {
        isLoggedIn = storageService.getAccessToken();
      }

      if (isLoggedIn != null && isLoggedIn != '') {
        // Get token and add it to headers
        final token = isLoggedIn;
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        log('User not logged in, no token added', name: 'AuthInterceptor');
      }
    } catch (e) {
      log('Error getting auth token: $e', name: 'AuthInterceptor');
    }

    // final header
    log(
      'REQUEST[${options.method}] => PATH: ${options.path} => DATA : ${options.data} => HEADER : ${options.headers}',
      name: 'ApiBaseHelper - onRequest',
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enableResponseLogs) {
      _logResponse(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (enableErrorLogs) {
      _logError(err);
    }
    if (err.response?.statusCode == 401
    //  || err.response?.statusCode == 404
    // err.response?.statusCode == 403 ||
    // err.response?.statusCode == 400 ||
    // err.response?.statusCode == 500
    ) {
      //TODO: Implement Authentication Error Handling
    }
    handler.next(err);
  }

  /// Log request details
  void _logRequest(RequestOptions options) {
    final logParts = [
      '┌── Request ──────────────────────────────────────────────',
      '│ Method: ${options.method}',
      '│ URL: ${options.uri}',
    ];

    if (enableHeaders && options.headers.isNotEmpty) {
      logParts.add('│ Headers:');
      options.headers.forEach((key, value) {
        // Don't log sensitive headers like Authorization in full
        if (key.toLowerCase() == 'authorization') {
          final authValue = value.toString();
          final redactedValue = authValue.length > 10
              ? '${authValue.substring(0, 10)}...[REDACTED]'
              : '[REDACTED]';
          logParts.add('│   $key: $redactedValue');
        } else {
          logParts.add('│   $key: $value');
        }
      });
    }

    if (enableRequestBody && options.data != null) {
      logParts.add('│ Body:');

      String body;
      if (options.data is FormData) {
        final formData = options.data as FormData;
        body =
            'FormData fields: ${formData.fields}, files: ${formData.files.length} files';
      } else {
        body = options.data.toString();
        // For long bodies, truncate
        if (body.length > 1000) {
          body = '${body.substring(0, 1000)}... [truncated]';
        }
      }

      logParts.add('│   $body');
    }

    logParts.add('└────────────────────────────────────────────────────');
    // log(logParts.join('\n'), name: 'Dio');
  }

  /// Log response details
  void _logResponse(Response response) {
    final logParts = [
      '┌── Response ─────────────────────────────────────────────',
      '│ Status: ${response.statusCode}',
      '│ URL: ${response.requestOptions.uri}',
    ];

    if (enableHeaders && response.headers.map.isNotEmpty) {
      logParts.add('│ Headers:');
      response.headers.map.forEach((key, values) {
        for (var value in values) {
          logParts.add('│   $key: $value');
        }
      });
    }

    if (enableResponseBody && response.data != null) {
      logParts.add('│ Body:');

      String body = response.data.toString();
      // For long bodies, truncate
      if (body.length > 1000) {
        body = '${body.substring(0, 1000)}... [truncated]';
      }

      logParts.add('│   $body');
    }

    // Add response time if available
    if (response.extra.containsKey('responseTime')) {
      logParts.add('│ Response Time: ${response.extra['responseTime']}ms');
    }

    logParts.add('└────────────────────────────────────────────────────');
    log(logParts.join('\n'), name: 'Dio');
  }

  /// Log error details
  void _logError(DioException err) {
    final logParts = [
      '┌── Error ────────────────────────────────────────────────',
      '│ Type: ${err.type}',
      '│ URL: ${err.requestOptions.uri}',
      '│ Message: ${err.message}',
    ];

    if (err.response != null) {
      logParts.add('│ Status: ${err.response?.statusCode}');

      if (enableResponseBody && err.response?.data != null) {
        logParts.add('│ Response:');

        String errorData = err.response!.data.toString();
        // For long error responses, truncate
        if (errorData.length > 1000) {
          errorData = '${errorData.substring(0, 1000)}... [truncated]';
        }

        logParts.add('│   $errorData');
      }
    }

    logParts.add('└────────────────────────────────────────────────────');
    log(logParts.join('\n'), name: 'Dio');
  }
}
