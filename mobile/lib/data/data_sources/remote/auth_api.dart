import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../../core/network/dio_client.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthApi(dio);
});

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<Map<String, dynamic>> login(String phoneNumber) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'phoneNumber': phoneNumber,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
