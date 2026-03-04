import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/market_model.dart';
import '../../models/nearby_market_profit_model.dart';
import '../../../core/network/dio_client.dart';

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
      return (response.data as List)
          .map((item) => MarketModel.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Find nearby markets using GPS coordinates.
  /// Basic version without profit calculation.
  Future<List<MarketModel>> getNearbyMarkets(double lat, double lng, {double radius = 50}) async {
    try {
      final response = await _dio.get('/markets/nearby', queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius': radius,
      });
      return (response.data as List)
          .map((item) => MarketModel.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Find nearby markets WITH profit optimization.
  /// Passes cropId so the backend calculates transport cost and profit.
  /// Markets are returned sorted by profit (best first).
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
      rethrow;
    }
  }
}
