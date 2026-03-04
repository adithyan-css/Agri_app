import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that logs request/response details in debug mode
/// and transforms error responses into user-friendly messages.
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('✖ ${err.response?.statusCode} ${err.requestOptions.uri}');
    debugPrint('  Error: ${err.message}');

    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Please check your internet.';
        break;
      case DioExceptionType.connectionError:
        message = 'Could not connect to the server.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final body = err.response?.data;
        if (statusCode == 401) {
          message = 'Session expired. Please login again.';
        } else if (statusCode == 404) {
          message = 'Resource not found.';
        } else if (statusCode >= 500) {
          message = 'Server error. Please try again later.';
        } else if (body is Map && body.containsKey('message')) {
          message = body['message'] is List
              ? (body['message'] as List).join(', ')
              : body['message'].toString();
        } else {
          message = 'Request failed with status $statusCode';
        }
        break;
      default:
        message = 'Something went wrong. Please try again.';
    }

    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: message,
    ));
  }
}
