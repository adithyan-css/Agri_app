import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data_sources/remote/auth_api.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApi = ref.watch(authApiProvider);
  return AuthRepository(authApi);
});

class AuthRepository {
  final AuthApi _authApi;

  AuthRepository(this._authApi);

  Future<UserModel> login(String phoneNumber) async {
    final response = await _authApi.login(phoneNumber);
    final token = response['token'];
    final userJson = response['user'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);

    return UserModel.fromJson(userJson);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      return await _authApi.getProfile();
    } catch (e) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token') != null;
  }
}
