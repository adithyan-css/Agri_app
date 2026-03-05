import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/market_model.dart';
import '../../data/models/nearby_market_profit_model.dart';
import '../../data/repositories/market_repository.dart';

final marketListProvider = FutureProvider<List<MarketModel>>((ref) async {
  final marketRepo = ref.watch(marketRepositoryProvider);
  return marketRepo.getAllMarkets();
});

/// Persisted selected market — loads from SharedPreferences on init.
/// Use `ref.read(selectedMarketProvider.notifier).selectMarket(market)` to set.
final selectedMarketProvider =
    StateNotifierProvider<SelectedMarketNotifier, MarketModel?>((ref) {
  return SelectedMarketNotifier(ref);
});

class SelectedMarketNotifier extends StateNotifier<MarketModel?> {
  static const _prefKey = 'selected_market';
  final Ref _ref;

  SelectedMarketNotifier(this._ref) : super(null) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw != null) {
      try {
        state = MarketModel.fromJson(jsonDecode(raw));
      } catch (_) {
        // Corrupted cache — ignore
      }
    }
  }

  Future<void> selectMarket(MarketModel market) async {
    state = market;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode({
      'id': market.id,
      'nameEn': market.nameEn,
      'nameTa': market.nameTa,
      'district': market.district,
      'state': market.state,
      'lat': market.lat,
      'lng': market.lng,
      'phone': market.phone,
      'openHours': market.openHours,
      'isActive': market.isActive,
      'avgPrice': market.avgPrice,
    }));
    // Also sync to backend (fire-and-forget)
    _syncToBackend(market.id);
  }

  Future<void> clearSelection() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  void _syncToBackend(String marketId) {
    try {
      final marketRepo = _ref.read(marketRepositoryProvider);
      marketRepo.setPreferredMarket(marketId);
    } catch (_) {
      // Silently fail — local selection is the source of truth
    }
  }
}

/// Whether the user has selected a market.
final hasSelectedMarketProvider = Provider<bool>((ref) {
  return ref.watch(selectedMarketProvider) != null;
});

final nearbyMarketsProvider = FutureProvider.family<List<MarketModel>, Map<String, double>>((ref, coords) async {
  final marketRepo = ref.watch(marketRepositoryProvider);
  return marketRepo.getNearbyMarkets(coords['lat']!, coords['lng']!);
});

/// Nearby markets with profit calculation for a specific crop.
/// Parameter: {lat, lng, cropId, radius}
final nearbyMarketsWithProfitProvider = FutureProvider.family<List<NearbyMarketProfitModel>, ({double lat, double lng, String cropId, double radius})>((ref, params) async {
  final marketRepo = ref.watch(marketRepositoryProvider);
  return marketRepo.getNearbyMarketsWithProfit(
    lat: params.lat,
    lng: params.lng,
    cropId: params.cropId,
    radius: params.radius,
  );
});
