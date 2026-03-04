import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/prediction_model.dart';
import '../../data/repositories/prediction_repository.dart';
import 'market_provider.dart';

final predictionProvider = FutureProvider.family<ForecastResponse, String>((ref, cropId) async {
  final predictionRepo = ref.watch(predictionRepositoryProvider);
  final selectedMarket = ref.watch(selectedMarketProvider);
  
  if (selectedMarket == null) {
      throw Exception('Please select a market first');
  }
  
  return predictionRepo.getForecast(cropId, selectedMarket.id);
});
