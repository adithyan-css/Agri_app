import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/market_model.dart';
import '../../data/repositories/market_repository.dart';

final marketListProvider = FutureProvider<List<MarketModel>>((ref) async {
  final marketRepo = ref.watch(marketRepositoryProvider);
  return marketRepo.getAllMarkets();
});

final selectedMarketProvider = StateProvider<MarketModel?>((ref) => null);

final nearbyMarketsProvider = FutureProvider.family<List<MarketModel>, Map<String, double>>((ref, coords) async {
  final marketRepo = ref.watch(marketRepositoryProvider);
  return marketRepo.getNearbyMarkets(coords['lat']!, coords['lng']!);
});
