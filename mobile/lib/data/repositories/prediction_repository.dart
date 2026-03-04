import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_sources/remote/prediction_api.dart';
import '../models/prediction_model.dart';
import '../models/recommendation_model.dart';

final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  final predictionApi = ref.watch(predictionApiProvider);
  return PredictionRepository(predictionApi);
});

class PredictionRepository {
  final PredictionApi _predictionApi;

  PredictionRepository(this._predictionApi);

  /// Get the full 7-day forecast with chart data
  Future<ForecastResponse> getForecast(String cropId, String marketId) async {
    return _predictionApi.getForecast(cropId, marketId);
  }

  /// Get the AI Sell or Wait recommendation card data
  Future<RecommendationModel> getRecommendation(String cropId, String marketId) async {
    return _predictionApi.getRecommendation(cropId, marketId);
  }
}
