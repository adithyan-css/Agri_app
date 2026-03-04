import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transport_profit_model.dart';
import '../../../core/network/dio_client.dart';

/// Provider for the Recommendation API client
final recommendationApiProvider = Provider<RecommendationApi>((ref) {
  final dio = ref.watch(dioProvider);
  return RecommendationApi(dio);
});

/// Recommendation / Intelligence API
/// Endpoints:
///   POST /intelligence/transport-profit → Calculate net profit with transport costs
class RecommendationApi {
  final Dio _dio;

  RecommendationApi(this._dio);

  /// Calculate exact net profit factoring in market distance and transport costs
  /// [cropId] - The crop being sold
  /// [targetMarketId] - Destination market UUID
  /// [distanceKm] - Distance to market in kilometres
  /// [volumeKg] - Total volume in kg
  /// [perKmRate] - Transport rate per km in ₹
  Future<TransportProfitModel> calculateTransportProfit({
    required String cropId,
    required String targetMarketId,
    required double distanceKm,
    required double volumeKg,
    required double perKmRate,
  }) async {
    try {
      final response = await _dio.post('/intelligence/transport-profit', data: {
        'cropId': cropId,
        'targetMarketId': targetMarketId,
        'distanceKm': distanceKm,
        'volumeKg': volumeKg,
        'perKmRate': perKmRate,
      });
      return TransportProfitModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
