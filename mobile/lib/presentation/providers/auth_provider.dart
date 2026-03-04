import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../core/network/dio_client.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool otpSent;

  AuthState({this.user, this.isLoading = false, this.error, this.otpSent = false});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error, bool? otpSent}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      otpSent: otpSent ?? this.otpSent,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      try {
        final dio = ref.read(dioProvider);
        final response = await dio.get('/auth/profile');
        state = state.copyWith(user: UserModel.fromJson(response.data));
      } catch (_) {
        // Token expired or invalid
        await prefs.remove('jwt_token');
      }
    }
  }

  Future<bool> login(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/login', data: {'phoneNumber': phoneNumber});
      
      final token = response.data['token'];
      final userJson = response.data['user'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      
      state = state.copyWith(user: UserModel.fromJson(userJson), isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Login failed. Please try again.');
      return false;
    }
  }

  /// Send OTP to the given phone number.
  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/auth/send-otp', data: {'phoneNumber': phoneNumber});
      state = state.copyWith(isLoading: false, otpSent: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to send OTP. Please try again.');
      return false;
    }
  }

  /// Verify the OTP code. On success, stores the JWT and user in state.
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/verify-otp', data: {
        'phoneNumber': phoneNumber,
        'otp': otp,
      });

      final token = response.data['token'];
      final userJson = response.data['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);

      state = state.copyWith(
        user: UserModel.fromJson(userJson),
        isLoading: false,
        otpSent: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Invalid OTP. Please try again.');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
