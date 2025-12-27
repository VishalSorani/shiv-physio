import 'dart:developer' as dev;

/// A simple logger class for application-wide logging
abstract class Logger {
  static bool _isDebugMode = false;
  static final Logger _instance = _LoggerImpl();

  /// Enable or disable debug mode
  static void setDebugMode(bool isDebug) {
    _isDebugMode = isDebug;
  }

  /// Get the logger instance
  static Logger get instance => _instance;

  /// Log a debug message (only shown in debug mode)
  void d(String message);

  /// Log an info message (always shown)
  void i(String message);

  /// Log a warning message (always shown)
  void w(String message);

  /// Log an error message (always shown)
  void e(String message, [dynamic error, StackTrace? stackTrace]);

  /// Simple log method (always shown)
  void log(String message);
}

/// Implementation of the Logger abstract class
class _LoggerImpl implements Logger {
  @override
  void d(String message) {
    if (Logger._isDebugMode) {
      _log('🔍 DEBUG: $message');
    }
  }

  @override
  void i(String message) {
    _log('ℹ️  INFO: $message');
  }

  @override
  void w(String message) {
    _log('⚠️  WARNING: $message');
  }

  @override
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('❌ ERROR: $message');
    if (error != null) {
      _log('Error details: $error');
    }
    if (stackTrace != null) {
      _log('Stack trace: $stackTrace');
    }
  }

  @override
  void log(String message) {
    _log('📝 LOG: $message');
  }

  void _log(String message) {
    // Avoid infinite recursion and excessive memory usage
    String out = message;
    if (out.length > 2000) {
      out = '${out.substring(0, 2000)}... [truncated]';
    }
    dev.log(out, name: 'App');
  }
}
