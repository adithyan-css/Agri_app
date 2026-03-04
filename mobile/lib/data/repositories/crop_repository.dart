import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_sources/remote/crop_api.dart';
import '../models/crop_price_model.dart';

final cropRepositoryProvider = Provider<CropRepository>((ref) {
  final cropApi = ref.watch(cropApiProvider);
  return CropRepository(cropApi);
});

class CropRepository {
  final CropApi _cropApi;

  CropRepository(this._cropApi);

  Future<List<CropModel>> getAllCrops() async {
    return _cropApi.getAllCrops();
  }

  Future<Map<String, dynamic>> getLatestPrice(String cropId, String marketId) async {
    return _cropApi.getLatestPrice(cropId, marketId);
  }

  Future<List<Map<String, dynamic>>> getHistory(String cropId, String marketId, {int days = 7}) async {
    return _cropApi.getHistory(cropId, marketId, days: days);
  }
}
