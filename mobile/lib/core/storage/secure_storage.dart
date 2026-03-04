import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Secure-ish storage using SharedPreferences.
/// In production, consider using flutter_secure_storage.
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

class SecureStorage {
  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // JWT Token
  Future<void> saveToken(String token) async {
    (await _prefs).setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return (await _prefs).getString(_tokenKey);
  }

  Future<void> deleteToken() async {
    (await _prefs).remove(_tokenKey);
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    (await _prefs).setString(_refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return (await _prefs).getString(_refreshTokenKey);
  }

  // User ID
  Future<void> saveUserId(String userId) async {
    (await _prefs).setString(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    return (await _prefs).getString(_userIdKey);
  }

  // Clear all secure data
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
  }
}
