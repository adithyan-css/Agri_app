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
