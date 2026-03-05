import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_sources/remote/road_profit_api.dart';
import '../models/road_profit_model.dart';

final roadProfitRepositoryProvider = Provider<RoadProfitRepository>((ref) {
  final api = ref.watch(roadProfitApiProvider);
  return RoadProfitRepository(api);
});

class RoadProfitRepository {
  final RoadProfitApi _api;

  RoadProfitRepository(this._api);

  Future<List<RoadProfitModel>> calculateRoadProfit({
    required double farmerLat,
    required double farmerLng,
    required String cropId,
    required double quantity,
    double radiusKm = 100,
  }) {
    return _api.calculateRoadProfit(
      farmerLat: farmerLat,
      farmerLng: farmerLng,
      cropId: cropId,
      quantity: quantity,
      radiusKm: radiusKm,
    );
  }
}
