import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/prediction_model.dart';
import '../../models/recommendation_model.dart';
import '../../../core/network/dio_client.dart';

final predictionApiProvider = Provider<PredictionApi>((ref) {
  final dio = ref.watch(dioProvider);
  return PredictionApi(dio);
});

class PredictionApi {
  final Dio _dio;

  PredictionApi(this._dio);

  /// Get the full 7-day forecast for a crop at a specific market
  Future<ForecastResponse> getForecast(String cropId, String marketId) async {
    try {
      final response = await _dio.get('/predictions/$cropId/markets/$marketId/forecast');
      return ForecastResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get the AI Sell or Wait recommendation for a crop at a market.
  /// This is the Feature 1 endpoint: GET /predictions/:cropId?marketId=xxx
  /// Returns: recommendation, trend, currentPrice, predictedPrice,
  ///          expectedProfit, confidence, reason, predictions[]
  Future<RecommendationModel> getRecommendation(
      String cropId, String marketId) async {
    try {
      final response = await _dio.get(
        '/predictions/$cropId',
        queryParameters: {'marketId': marketId},
      );
      return RecommendationModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
