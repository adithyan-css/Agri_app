import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/firebase_auth_service.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

/// Convert a Firebase [User] to the app's [UserModel].
UserModel _firebaseUserToModel(fb.User firebaseUser) {
  return UserModel(
    id: firebaseUser.uid,
    phoneNumber: firebaseUser.phoneNumber ?? '',
    name: firebaseUser.displayName,
    role: 'farmer',
    preferredLanguage: null,
    fcmToken: null,
    lat: null,
    lng: null,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  late final FirebaseAuthService _authService;

  AuthNotifier(this.ref) : super(AuthState()) {
    _authService = ref.read(firebaseAuthServiceProvider);
    _listenAuthChanges();
  }

  /// Listen to Firebase auth state and update app state automatically.
  void _listenAuthChanges() {
    _authService.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        state = state.copyWith(
          user: _firebaseUserToModel(firebaseUser),
          isLoading: false,
        );
        // Sync user to backend DB (fire-and-forget)
        _syncUserToBackend();
      } else {
        state = AuthState();
      }
    });
  }

  /// Sync the currently signed-in Firebase user to the backend database.
  /// This ensures the user record exists for features like alerts.
  Future<void> _syncUserToBackend() async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/auth/sync');
    } catch (e) {
      debugPrint('Auth sync to backend failed (non-critical): $e');
    }
  }

  /// Sign in with email and password.
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signInWithEmail(email, password);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _friendlyError(e));
      return false;
    }
  }

  /// Register with email, password, and optional display name.
  Future<bool> register(String email, String password, {String? name}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.registerWithEmail(email, password);
      if (name != null && name.isNotEmpty) {
        await _authService.updateDisplayName(name);
      }
      return true;
    } on fb.FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _friendlyError(e));
      return false;
    }
  }

  /// Sign in with Google.
  Future<bool> googleLogin() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signInWithGoogle();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _friendlyError(e));
      return false;
    }
  }

  /// Sign out.
  Future<void> logout() async {
    await _authService.signOut();
    state = AuthState();
  }

  /// Convert Firebase exceptions to user-friendly messages.
  String _friendlyError(dynamic e) {
    if (e is fb.FirebaseAuthException) return e.message ?? e.code;
    final msg = e.toString();
    if (msg.contains('user-not-found')) return 'No account found with this email.';
    if (msg.contains('wrong-password')) return 'Incorrect password.';
    if (msg.contains('email-already-in-use')) return 'This email is already registered.';
    if (msg.contains('invalid-email')) return 'Invalid email address.';
    if (msg.contains('weak-password')) return 'Password is too weak (min 6 characters).';
    if (msg.contains('network-request-failed')) return 'Network error. Check your connection.';
    debugPrint('Auth error: $msg');
    return 'Authentication failed. Please try again.';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

