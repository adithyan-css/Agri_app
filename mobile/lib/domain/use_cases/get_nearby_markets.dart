import '../../data/models/market_model.dart';
import '../../data/repositories/market_repository.dart';

/// Use case: retrieve nearby markets based on GPS coordinates.
class GetNearbyMarkets {
  final MarketRepository _repository;

  GetNearbyMarkets(this._repository);

  Future<List<MarketModel>> call(double lat, double lng, {double radius = 50}) async {
    return _repository.getNearbyMarkets(lat, lng, radius: radius);
  }

  Future<List<MarketModel>> getAll() async {
    return _repository.getAllMarkets();
  }
}
