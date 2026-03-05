import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/road_profit_model.dart';
import '../../../core/network/dio_client.dart';

final roadProfitApiProvider = Provider<RoadProfitApi>((ref) {
  final dio = ref.watch(dioProvider);
  return RoadProfitApi(dio);
});

/// API client for POST /transport-profit
/// Uses OpenRouteService real road distances on the backend.
class RoadProfitApi {
  final Dio _dio;

  RoadProfitApi(this._dio);

  /// Calculate profit for nearby markets using real road distance.
  /// Returns top 5 markets sorted by net profit.
  Future<List<RoadProfitModel>> calculateRoadProfit({
    required double farmerLat,
    required double farmerLng,
    required String cropId,
    required double quantity,
    double radiusKm = 100,
  }) async {
    final response = await _dio.post('/transport-profit', data: {
      'farmerLat': farmerLat,
      'farmerLng': farmerLng,
      'cropId': cropId,
      'quantity': quantity,
      'radiusKm': radiusKm,
    });
    return (response.data as List)
        .map((item) => RoadProfitModel.fromJson(item))
        .toList();
  }
}
