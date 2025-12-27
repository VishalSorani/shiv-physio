import 'dart:io';

import 'package:dio/dio.dart';

/// Abstract base class for API service implementations
abstract class ApiClientBase {
  /// Generic GET method
  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    required T Function(dynamic data) fromJson,
  });

  /// Generic POST method
  Future<T> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required T Function(dynamic data) fromJson,
  });

  /// Generic PUT method
  Future<T> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required T Function(dynamic data) fromJson,
  });

  /// Generic PATCH method
  Future<T> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required T Function(dynamic data) fromJson,
  });

  /// Generic DELETE method
  Future<T> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic data) fromJson,
  });

  /// Upload a file
  Future<T> uploadFile<T>(
    String endpoint, {
    required File file,
    String fileKey,
    String fileName,
    String mimeType,
    Map<String, dynamic>? extraData,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    required T Function(dynamic data) fromJson,
  });

  /// Download a file
  Future<File> downloadFile(
    String endpoint, {
    required String savePath,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });
}

