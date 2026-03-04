import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage();
});

class LocalStorage {
  static const String _tokenKey = 'jwt_token';
  static const String _languageKey = 'preferred_language';
  static const String _selectedMarketKey = 'selected_market_id';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _onboardingKey = 'onboarding_completed';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Token
  Future<String?> getToken() async => (await _prefs).getString(_tokenKey);
  Future<void> setToken(String token) async =>
      (await _prefs).setString(_tokenKey, token);
  Future<void> removeToken() async => (await _prefs).remove(_tokenKey);
  Future<bool> hasToken() async => (await _prefs).getString(_tokenKey) != null;

  // Language
  Future<String> getLanguage() async =>
      (await _prefs).getString(_languageKey) ?? 'en';
  Future<void> setLanguage(String lang) async =>
      (await _prefs).setString(_languageKey, lang);

  // Selected market
  Future<String?> getSelectedMarketId() async =>
      (await _prefs).getString(_selectedMarketKey);
  Future<void> setSelectedMarketId(String id) async =>
      (await _prefs).setString(_selectedMarketKey, id);

  // Notifications
  Future<bool> getNotificationsEnabled() async =>
      (await _prefs).getBool(_notificationsKey) ?? true;
  Future<void> setNotificationsEnabled(bool enabled) async =>
      (await _prefs).setBool(_notificationsKey, enabled);

  // Onboarding
  Future<bool> isOnboardingCompleted() async =>
      (await _prefs).getBool(_onboardingKey) ?? false;
  Future<void> setOnboardingCompleted() async =>
      (await _prefs).setBool(_onboardingKey, true);

  // Clear all
  Future<void> clearAll() async => (await _prefs).clear();
}
