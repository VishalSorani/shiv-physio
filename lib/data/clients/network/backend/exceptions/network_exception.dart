import 'dart:io';

import 'package:dio/dio.dart';
import '../error_handling/network_error_constants.dart';

/// Custom exception class for network errors
class NetworkException implements Exception {
  /// The error code associated with this exception
  final String code;

  /// A user-friendly message describing the error
  final String message;

  /// HTTP status code if applicable
  final int? statusCode;

  /// Original error for debugging purposes
  final dynamic originalError;

  /// Additional error details
  final Map<String, dynamic>? details;

  NetworkException({
    required this.code,
    required this.message,
    this.statusCode,
    this.originalError,
    this.details,
  });

  @override
  String toString() {
    return 'NetworkException(code: $code, message: $message${statusCode != null ? ', statusCode: $statusCode' : ''}${originalError != null ? ', originalError: $originalError' : ''})';
  }

  /// Creates a new [NetworkException] from an HTTP status code
  factory NetworkException.fromStatusCode(
    int statusCode, [
    String? customMessage,
  ]) {
    switch (statusCode) {
      case 400:
        return NetworkException(
          code: NetworkErrorCode.badRequest,
          message: customMessage ?? NetworkErrorMessage.badRequest,
          statusCode: statusCode,
        );
      case 401:
        return NetworkException(
          code: NetworkErrorCode.unauthorized,
          message: customMessage ?? NetworkErrorMessage.unauthorized,
          statusCode: statusCode,
        );
      case 403:
        return NetworkException(
          code: NetworkErrorCode.forbidden,
          message: customMessage ?? NetworkErrorMessage.forbidden,
          statusCode: statusCode,
        );
      case 404:
        return NetworkException(
          code: NetworkErrorCode.notFound,
          message: customMessage ?? NetworkErrorMessage.notFound,
          statusCode: statusCode,
        );
      case 405:
        return NetworkException(
          code: NetworkErrorCode.methodNotAllowed,
          message: customMessage ?? NetworkErrorMessage.methodNotAllowed,
          statusCode: statusCode,
        );
      case 408:
        return NetworkException(
          code: NetworkErrorCode.requestTimeout,
          message: customMessage ?? NetworkErrorMessage.requestTimeout,
          statusCode: statusCode,
        );
      case 409:
        return NetworkException(
          code: NetworkErrorCode.conflict,
          message: customMessage ?? NetworkErrorMessage.conflict,
          statusCode: statusCode,
        );
      case 410:
        return NetworkException(
          code: NetworkErrorCode.gone,
          message: customMessage ?? NetworkErrorMessage.gone,
          statusCode: statusCode,
        );
      case 422:
        return NetworkException(
          code: NetworkErrorCode.unprocessableEntity,
          message: customMessage ?? NetworkErrorMessage.unprocessableEntity,
          statusCode: statusCode,
        );
      case 429:
        return NetworkException(
          code: NetworkErrorCode.tooManyRequests,
          message: customMessage ?? NetworkErrorMessage.tooManyRequests,
          statusCode: statusCode,
        );
      case 500:
        return NetworkException(
          code: NetworkErrorCode.internalServerError,
          message: customMessage ?? NetworkErrorMessage.internalServerError,
          statusCode: statusCode,
        );
      case 502:
        return NetworkException(
          code: NetworkErrorCode.badGateway,
          message: customMessage ?? NetworkErrorMessage.badGateway,
          statusCode: statusCode,
        );
      case 503:
        return NetworkException(
          code: NetworkErrorCode.serviceUnavailable,
          message: customMessage ?? NetworkErrorMessage.serviceUnavailable,
          statusCode: statusCode,
        );
      case 504:
        return NetworkException(
          code: NetworkErrorCode.gatewayTimeout,
          message: customMessage ?? NetworkErrorMessage.gatewayTimeout,
          statusCode: statusCode,
        );
      default:
        return NetworkException(
          code: NetworkErrorCode.unknown,
          message: customMessage ?? NetworkErrorMessage.unknown,
          statusCode: statusCode,
        );
    }
  }

  /// Created a new [NetworkException] from a NetworkException
  factory NetworkException.fromNetworkException(NetworkException error) {
    return NetworkException(
      code: error.code,
      message: error.message,
      statusCode: error.statusCode,
      originalError: error.originalError,
      details: error.details,
    );
  }

  /// Creates a new [NetworkException] from a Dio error
  factory NetworkException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          code: NetworkErrorCode.connectionTimeout,
          message: NetworkErrorMessage.connectionTimeout,
          originalError: error,
        );
      case DioExceptionType.sendTimeout:
        return NetworkException(
          code: NetworkErrorCode.sendTimeout,
          message: NetworkErrorMessage.sendTimeout,
          originalError: error,
        );
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          code: NetworkErrorCode.receiveTimeout,
          message: NetworkErrorMessage.receiveTimeout,
          originalError: error,
        );
      case DioExceptionType.badResponse:
        final response = error.response;
        final statusCode = response?.statusCode;
        String? errorMessage;

        if (response?.data != null) {
          if (response!.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            // Prefer nested API error message shape: { success: false, error: { code, message } }
            if (data['error'] is Map<String, dynamic>) {
              final err = data['error'] as Map<String, dynamic>;
              errorMessage = err['message'] as String?;
            }
            // Fallback to top-level message if present
            errorMessage = errorMessage ?? data['message'] as String?;
          } else if (response.data is String) {
            errorMessage = response.data as String;
          }
        }

        if (statusCode != null) {
          return NetworkException.fromStatusCode(statusCode, errorMessage);
        }
        return NetworkException(
          code: NetworkErrorCode.invalidResponse,
          message: errorMessage ?? NetworkErrorMessage.invalidResponse,
          originalError: error,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          code: NetworkErrorCode.cancelError,
          message: NetworkErrorMessage.cancelError,
          originalError: error,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          code: NetworkErrorCode.connectionError,
          message: NetworkErrorMessage.connectionError,
          originalError: error,
        );
      default:
        return NetworkException(
          code: NetworkErrorCode.unknown,
          message: NetworkErrorMessage.unknown,
          originalError: error,
        );
    }
  }

  /// Creates a new [NetworkException] from a socket error
  factory NetworkException.fromSocketException(SocketException error) {
    return NetworkException(
      code: NetworkErrorCode.connectionError,
      message: NetworkErrorMessage.connectionError,
      originalError: error,
    );
  }

  /// Creates a new [NetworkException] for parsing errors
  factory NetworkException.parsingError(dynamic error) {
    return NetworkException(
      code: NetworkErrorCode.parsingError,
      message: NetworkErrorMessage.parsingError,
      originalError: error,
    );
  }

  /// Creates a new [NetworkException] for validation errors
  factory NetworkException.validationError(
    String message, [
    Map<String, dynamic>? details,
  ]) {
    return NetworkException(
      code: NetworkErrorCode.validationError,
      message: message,
      details: details,
    );
  }
}
