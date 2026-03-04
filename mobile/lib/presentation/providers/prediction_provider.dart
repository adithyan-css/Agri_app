import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/prediction_model.dart';
import '../../data/models/recommendation_model.dart';
import '../../data/repositories/prediction_repository.dart';
import 'market_provider.dart';

/// 7-day forecast provider using selectedMarketProvider. Returns null when no market selected.
final predictionProvider = FutureProvider.family<ForecastResponse?, String>((ref, cropId) async {
  final predictionRepo = ref.watch(predictionRepositoryProvider);
  final selectedMarket = ref.watch(selectedMarketProvider);
  
  if (selectedMarket == null) {
    return null;
  }
  
  return predictionRepo.getForecast(cropId, selectedMarket.id);
});

/// Direct forecast provider that takes both cropId and marketId explicitly.
/// Use this when the route provides the marketId parameter.
final directForecastProvider = FutureProvider.family<ForecastResponse, ({String cropId, String marketId})>((ref, params) async {
  final predictionRepo = ref.watch(predictionRepositoryProvider);
  return predictionRepo.getForecast(params.cropId, params.marketId);
});

/// AI Sell or Wait recommendation provider
final sellOrWaitProvider = FutureProvider.family<RecommendationModel?, ({String cropId, String marketId})>((ref, params) async {
  final predictionRepo = ref.watch(predictionRepositoryProvider);
  try {
    return await predictionRepo.getRecommendation(params.cropId, params.marketId);
  } catch (e) {
    return null;
  }
});
