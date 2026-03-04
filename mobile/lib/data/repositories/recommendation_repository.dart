import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_sources/remote/recommendation_api.dart';
import '../models/transport_profit_model.dart';

/// Repository provider for recommendation/intelligence operations
final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  final api = ref.watch(recommendationApiProvider);
  return RecommendationRepository(api);
});

/// Recommendation Repository
/// Provides a clean interface to the intelligence API for the presentation layer.
class RecommendationRepository {
  final RecommendationApi _api;

  RecommendationRepository(this._api);

  /// Calculate net profit factoring in transport costs
  Future<TransportProfitModel> calculateTransportProfit({
    required String cropId,
    required String targetMarketId,
    required double distanceKm,
    required double volumeKg,
    required double perKmRate,
  }) async {
    return _api.calculateTransportProfit(
      cropId: cropId,
      targetMarketId: targetMarketId,
      distanceKm: distanceKm,
      volumeKg: volumeKg,
      perKmRate: perKmRate,
    );
  }
}
