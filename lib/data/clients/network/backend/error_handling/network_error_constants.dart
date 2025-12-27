/// Constants for network error codes
class NetworkErrorCode {
  // HTTP Status Code Errors
  static const String badRequest = 'NETWORK_BAD_REQUEST'; // 400
  static const String unauthorized = 'NETWORK_UNAUTHORIZED'; // 401
  static const String forbidden = 'NETWORK_FORBIDDEN'; // 403
  static const String notFound = 'NETWORK_NOT_FOUND'; // 404
  static const String methodNotAllowed = 'NETWORK_METHOD_NOT_ALLOWED'; // 405
  static const String requestTimeout = 'NETWORK_REQUEST_TIMEOUT'; // 408
  static const String conflict = 'NETWORK_CONFLICT'; // 409
  static const String gone = 'NETWORK_GONE'; // 410
  static const String unprocessableEntity = 'NETWORK_UNPROCESSABLE_ENTITY'; // 422
  static const String tooManyRequests = 'NETWORK_TOO_MANY_REQUESTS'; // 429
  static const String internalServerError = 'NETWORK_INTERNAL_SERVER_ERROR'; // 500
  static const String badGateway = 'NETWORK_BAD_GATEWAY'; // 502
  static const String serviceUnavailable = 'NETWORK_SERVICE_UNAVAILABLE'; // 503
  static const String gatewayTimeout = 'NETWORK_GATEWAY_TIMEOUT'; // 504
  
  // Connection Errors
  static const String connectionError = 'NETWORK_CONNECTION_ERROR';
  static const String noInternet = 'NETWORK_NO_INTERNET';
  static const String connectionTimeout = 'NETWORK_CONNECTION_TIMEOUT';
  static const String sendTimeout = 'NETWORK_SEND_TIMEOUT';
  static const String receiveTimeout = 'NETWORK_RECEIVE_TIMEOUT';
  static const String cancelError = 'NETWORK_REQUEST_CANCELLED';
  
  // Data Errors
  static const String invalidResponse = 'NETWORK_INVALID_RESPONSE';
  static const String parsingError = 'NETWORK_PARSING_ERROR';
  static const String validationError = 'NETWORK_VALIDATION_ERROR';
  
  // General Errors
  static const String unknown = 'NETWORK_UNKNOWN_ERROR';
  static const String notInitialized = 'NETWORK_NOT_INITIALIZED';
}

/// Constants for user-friendly network error messages
class NetworkErrorMessage {
  // Connection Errors
  static const String noInternet = 'No Internet Connection';
  
  // HTTP Status Code Messages
  static const String badRequest = 'Invalid request. Please check your input.';
  static const String unauthorized = 'You are not authorized to access this resource. Please log in again.';
  static const String forbidden = 'You do not have permission to access this resource.';
  static const String notFound = 'The requested resource was not found.';
  static const String methodNotAllowed = 'This operation is not supported.';
  static const String requestTimeout = 'The request timed out. Please try again.';
  static const String conflict = 'There was a conflict with the current state of the resource.';
  static const String gone = 'The requested resource is no longer available.';
  static const String unprocessableEntity = 'The request could not be processed due to validation errors.';
  static const String tooManyRequests = 'Too many requests. Please try again later.';
  static const String internalServerError = 'An internal server error occurred. Please try again later.';
  static const String badGateway = 'The server received an invalid response. Please try again later.';
  static const String serviceUnavailable = 'The service is temporarily unavailable. Please try again later.';
  static const String gatewayTimeout = 'The server took too long to respond. Please try again later.';
  
  // Connection Messages
  static const String connectionError = 'Unable to connect to the server. Please check your internet connection.';
  static const String connectionTimeout = 'Connection timed out. Please check your internet connection and try again.';
  static const String sendTimeout = 'Failed to send data to the server. Please try again.';
  static const String receiveTimeout = 'Failed to receive data from the server. Please try again.';
  static const String cancelError = 'The request was cancelled.';
  
  // Data Messages
  static const String invalidResponse = 'The server returned an invalid response. Please try again later.';
  static const String parsingError = 'Failed to process the server response. Please try again later.';
  static const String validationError = 'The data provided did not pass validation checks.';
  
  // General Messages
  static const String unknown = 'An unexpected network error occurred. Please try again.';
  static const String notInitialized = 'Network service not initialized. Please try again.';
}
