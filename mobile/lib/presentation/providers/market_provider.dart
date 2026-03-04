import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/market_model.dart';
import '../../data/models/nearby_market_profit_model.dart';
import '../../data/repositories/market_repository.dart';

final marketListProvider = FutureProvider<List<MarketModel>>((ref) async {
  final marketRepo = ref.watch(marketRepositoryProvider);
  return marketRepo.getAllMarkets();
});

final selectedMarketProvider = StateProvider<MarketModel?>((ref) => null);

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
