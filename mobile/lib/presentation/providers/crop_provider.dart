import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/crop_price_model.dart';
import '../../data/repositories/crop_repository.dart';
import 'market_provider.dart';

final cropListProvider = FutureProvider<List<CropModel>>((ref) async {
  final cropRepo = ref.watch(cropRepositoryProvider);
  return cropRepo.getAllCrops();
});

final latestPriceProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, cropId) async {
  final cropRepo = ref.watch(cropRepositoryProvider);
  final selectedMarket = ref.watch(selectedMarketProvider);
  
  if (selectedMarket == null) return {'price': 0.0, 'market': 'Select Market'};
  
  try {
    return await cropRepo.getLatestPrice(cropId, selectedMarket.id);
  } catch (e) {
    return {'price': 0.0, 'market': selectedMarket.nameEn};
  }
});

/// Provider for price history data. The parameter is a record of (cropId, marketId, days).
final priceHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>, ({String cropId, String marketId, int days})>((ref, params) async {
  final cropRepo = ref.watch(cropRepositoryProvider);
  return cropRepo.getHistory(params.cropId, params.marketId, days: params.days);
});

/// Search/filter provider for crops
final cropSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredCropListProvider = FutureProvider<List<CropModel>>((ref) async {
  final crops = await ref.watch(cropListProvider.future);
  final query = ref.watch(cropSearchQueryProvider).toLowerCase();
  if (query.isEmpty) return crops;
  return crops.where((c) => c.nameEn.toLowerCase().contains(query) || c.nameTa.contains(query)).toList();
});
