import 'package:shiv_physio_app/core/exceptions/app_exceptions.dart';
import 'package:shiv_physio_app/data/service/logger.dart';

/// Base repository class that provides logging functionality to all repositories
abstract class BaseRepository {
  final Logger _logger = Logger.instance;

  /// Log a debug message (only shown in debug mode)
  void logD(String message) => _logger.d('${runtimeType.toString()}: $message');

  /// Log an info message (always shown)
  void logI(String message) => _logger.i('${runtimeType.toString()}: $message');

  /// Log a warning message (always shown)
  void logW(String message) => _logger.w('${runtimeType.toString()}: $message');

  /// Log an error message (always shown)
  void logE(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.e('${runtimeType.toString()}: $message', error, stackTrace);

  /// Simple log method (always shown)
  void log(String message) =>
      _logger.log('${runtimeType.toString()}: $message');

  // Future<T> handleAsyncOperation<T>(Future<T> Function() operation) async {
  //   try {
  //     final result = await operation();
  //     // check  result is T type else throw error
  //     if (result.runtimeType is! T) {
  //       throw Exception('Result is not of type $T');
  //     }
  //     return result;
  //   } on NetworkException catch (e) {
  //     throw e.message;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // comman error handle function
  Never handleRepositoryError(dynamic error) {
    if (error is AppException) {
      throw error;
    }
    if (error is NetworkException) {
      throw error;
    }
    throw UnknownException(error.toString(), originalError: error);
  }
}
