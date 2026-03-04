import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message) {
    debugPrint('[INFO] $message');
  }

  static void warning(String message) {
    debugPrint('[WARN] $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('  Error: $error');
    if (stackTrace != null) debugPrint('  Stack: $stackTrace');
  }

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
    }
  }

  static void network(String method, String url, {int? statusCode}) {
    final status = statusCode != null ? '[$statusCode]' : '';
    debugPrint('[NET] $method $url $status');
  }
}
