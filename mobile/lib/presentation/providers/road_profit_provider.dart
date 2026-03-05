import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/road_profit_repository.dart';
import '../../data/models/road_profit_model.dart';

typedef RoadProfitParams = ({
  double farmerLat,
  double farmerLng,
  String cropId,
  double quantity,
  double radiusKm,
});

/// Provider to calculate road-distance-based transport profit.
/// Returns top 5 most profitable markets.
final roadProfitProvider =
    FutureProvider.family<List<RoadProfitModel>, RoadProfitParams>(
  (ref, params) async {
    final repo = ref.read(roadProfitRepositoryProvider);
    return repo.calculateRoadProfit(
      farmerLat: params.farmerLat,
      farmerLng: params.farmerLng,
      cropId: params.cropId,
      quantity: params.quantity,
      radiusKm: params.radiusKm,
    );
  },
);
