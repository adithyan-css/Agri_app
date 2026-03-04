import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_sources/remote/market_api.dart';
import '../models/market_model.dart';
import '../models/nearby_market_profit_model.dart';

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final marketApi = ref.watch(marketApiProvider);
  return MarketRepository(marketApi);
});

class MarketRepository {
  final MarketApi _marketApi;

  MarketRepository(this._marketApi);

  Future<List<MarketModel>> getAllMarkets() async {
    return _marketApi.getAllMarkets();
  }

  Future<List<MarketModel>> getNearbyMarkets(double lat, double lng, {double radius = 50}) async {
    return _marketApi.getNearbyMarkets(lat, lng, radius: radius);
  }

  /// Get nearby markets with profit calculation for a specific crop.
  /// Returns markets sorted by profitability (best first).
  Future<List<NearbyMarketProfitModel>> getNearbyMarketsWithProfit({
    required double lat,
    required double lng,
    required String cropId,
    double radius = 50,
  }) async {
    return _marketApi.getNearbyMarketsWithProfit(
      lat: lat,
      lng: lng,
      cropId: cropId,
      radius: radius,
    );
  }
}
