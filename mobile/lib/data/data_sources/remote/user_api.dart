import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../../core/network/dio_client.dart';

/// Provider for the User API client
final userApiProvider = Provider<UserApi>((ref) {
  final dio = ref.watch(dioProvider);
  return UserApi(dio);
});

/// User API - handles user profile REST calls
/// Endpoints:
///   GET /users/:id → Get user profile by ID
class UserApi {
  final Dio _dio;

  UserApi(this._dio);

  /// Fetch a user profile by ID
  Future<UserModel> getUserById(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
