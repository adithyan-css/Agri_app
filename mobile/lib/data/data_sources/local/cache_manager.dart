import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

class CacheManager {
  static const Duration defaultTtl = Duration(minutes: 5);

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Store a JSON-serializable value with a TTL.
  Future<void> put(String key, dynamic value, {Duration? ttl}) async {
    final prefs = await _prefs;
    final cacheEntry = {
      'data': value,
      'expiry': DateTime.now()
          .add(ttl ?? defaultTtl)
          .millisecondsSinceEpoch,
    };
    await prefs.setString('cache_$key', jsonEncode(cacheEntry));
  }

  /// Retrieve a cached value. Returns null if expired or missing.
  Future<dynamic> get(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getString('cache_$key');
    if (raw == null) return null;

    try {
      final entry = jsonDecode(raw) as Map<String, dynamic>;
      final expiry = entry['expiry'] as int;
      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        await prefs.remove('cache_$key');
        return null;
      }
      return entry['data'];
    } catch (_) {
      await prefs.remove('cache_$key');
      return null;
    }
  }

  /// Check if a cached value exists and is not expired.
  Future<bool> has(String key) async {
    return (await get(key)) != null;
  }

  /// Remove a specific cache entry.
  Future<void> remove(String key) async {
    (await _prefs).remove('cache_$key');
  }

  /// Clear all cache entries.
  Future<void> clearAll() async {
    final prefs = await _prefs;
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
