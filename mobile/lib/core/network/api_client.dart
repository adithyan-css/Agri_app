import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_client.dart';

/// Provides a configured [ApiClient] wrapping the Dio instance from [dioProvider].
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

/// A thin wrapper around [Dio] that provides typed convenience methods
/// for GET, POST, PUT, DELETE with standard error handling.
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      if (parser != null) return parser(response.data);
      return response.data as T;
    } on DioException {
      rethrow;
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      if (parser != null) return parser(response.data);
      return response.data as T;
    } on DioException {
      rethrow;
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      if (parser != null) return parser(response.data);
      return response.data as T;
    } on DioException {
      rethrow;
    }
  }

  Future<T> delete<T>(
    String path, {
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.delete(path);
      if (parser != null) return parser(response.data);
      return response.data as T;
    } on DioException {
      rethrow;
    }
  }
}
