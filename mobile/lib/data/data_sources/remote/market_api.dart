import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/market_model.dart';
import '../../models/nearby_market_profit_model.dart';
import '../../../core/network/dio_client.dart';
import '../local/local_data_service.dart';

final marketApiProvider = Provider<MarketApi>((ref) {
  final dio = ref.watch(dioProvider);
  return MarketApi(dio);
});

class MarketApi {
  final Dio _dio;

  MarketApi(this._dio);

  Future<List<MarketModel>> getAllMarkets() async {
    try {
      final response = await _dio.get('/markets');
      final rawList = response.data as List;
      // Cache for offline use
      LocalDataService.cacheMarkets(rawList);
      return rawList.map((item) => MarketModel.fromJson(item)).toList();
    } catch (e) {
      // Fallback to cached / seed data when offline
      return LocalDataService.getCachedMarkets();
    }
  }

  /// Find nearby markets using GPS coordinates.
  /// Basic version without profit calculation.
  Future<List<MarketModel>> getNearbyMarkets(double lat, double lng, {double radius = 50}) async {
    try {
      final response = await _dio.get('/markets/nearby', queryParameters: {
        'lat': lat,
        'lng': lng,
        'radiusKm': radius,
      });
      return (response.data as List)
          .map((item) => MarketModel.fromJson(item))
          .toList();
    } catch (e) {
      // Fallback: return all cached markets (user can see them without distance)
      return LocalDataService.getCachedMarkets();
    }
  }

  /// Find nearby markets WITH profit optimization.
  Future<List<NearbyMarketProfitModel>> getNearbyMarketsWithProfit({
    required double lat,
    required double lng,
    required String cropId,
    double radius = 50,
  }) async {
    try {
      final response = await _dio.get('/markets/nearby', queryParameters: {
        'lat': lat,
        'lng': lng,
        'radiusKm': radius,
        'cropId': cropId,
      });
      return (response.data as List)
          .map((item) => NearbyMarketProfitModel.fromJson(item))
          .toList();
    } catch (e) {
      // Return empty when offline — profit calculation requires backend
      return [];
    }
  }
}
