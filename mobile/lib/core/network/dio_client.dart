import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:3000/api/v1', 
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Attach Firebase ID token to every request
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken();
        if (idToken != null) {
          options.headers['Authorization'] = 'Bearer $idToken';
        }
      }
      return handler.next(options);
    },
    onError: (DioException e, handler) {
      if (e.response?.statusCode == 401) {
        // Handle token expiration/unauthorized globally here if needed
      }
      return handler.next(e);
    },
  ));

  return dio;
});
