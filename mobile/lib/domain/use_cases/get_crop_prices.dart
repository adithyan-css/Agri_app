import '../../data/models/crop_price_model.dart';
import '../../data/repositories/crop_repository.dart';

/// Use case: retrieve all crops and their latest prices.
class GetCropPrices {
  final CropRepository _repository;

  GetCropPrices(this._repository);

  Future<List<CropModel>> call() async {
    return _repository.getAllCrops();
  }

  Future<Map<String, dynamic>> getLatestPrice(String cropId, String marketId) async {
    return _repository.getLatestPrice(cropId, marketId);
  }

  Future<List<Map<String, dynamic>>> getHistory(String cropId, String marketId, {int days = 7}) async {
    return _repository.getHistory(cropId, marketId, days: days);
  }
}
