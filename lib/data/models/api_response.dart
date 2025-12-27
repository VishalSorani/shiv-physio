/// Generic API response wrapper for all API calls
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? token;
  final List<String>? errors;

  ApiResponse({required this.success, this.message, this.data, this.errors, this.token});

  /// Creates an ApiResponse from JSON data
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json)? fromJsonT,
  ) {   
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      token: json['token'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : null,
      errors:
          json['errors'] != null
              ? (json['errors'] as List).map((e) => e.toString()).toList()
              : null,
    );
  }

  /// Creates an ApiResponse from JSON data with a list of items
  factory ApiResponse.fromJsonList(
    Map<String, dynamic> json,
    T Function(List<dynamic> jsonList)? fromJsonListT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data:
          json['data'] != null && fromJsonListT != null
              ? fromJsonListT(json['data'] as List<dynamic>)
              : null,
      errors:
          json['errors'] != null
              ? (json['errors'] as List).map((e) => e.toString()).toList()
              : null,
    );
  }

  /// Converts the ApiResponse to JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T data)? toJsonT) {
    return {
      'success': success,
      'message': message,
      'token': token,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : null,
      'errors': errors,
    };
  }

  /// Creates a successful response with data
  factory ApiResponse.success({T? data, String? message}) {
    return ApiResponse(success: true, data: data, message: message);
  }

  /// Creates an error response with error messages
  factory ApiResponse.error({List<String>? errors, String? message}) {
    return ApiResponse(success: false, errors: errors, message: message);
  }
}
