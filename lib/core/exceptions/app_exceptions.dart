class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalError});
}

class AuthException extends AppException {
  AuthException(super.message, {super.code, super.originalError});
}

class ServerException extends AppException {
  ServerException(super.message, {super.code, super.originalError});
}

class UnknownException extends AppException {
  UnknownException(super.message, {super.code, super.originalError});
}
