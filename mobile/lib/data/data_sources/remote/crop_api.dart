import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/crop_price_model.dart';
import '../../../core/network/dio_client.dart';
import '../local/local_data_service.dart';

final cropApiProvider = Provider<CropApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CropApi(dio);
});

class CropApi {
  final Dio _dio;

  CropApi(this._dio);

  Future<List<CropModel>> getAllCrops() async {
    try {
      final response = await _dio.get('/crops');
      final rawList = response.data as List;
      // Cache for offline use
      LocalDataService.cacheCrops(rawList);
      return rawList.map((item) => CropModel.fromJson(item)).toList();
    } catch (e) {
      // Fallback to cached / seed data when offline
      return LocalDataService.getCachedCrops();
    }
  }

  Future<Map<String, dynamic>> getLatestPrice(String cropId, String marketId) async {
    try {
      final response = await _dio.get('/crops/$cropId/markets/$marketId/latest-price');
      final data = Map<String, dynamic>.from(response.data);
      LocalDataService.cacheLatestPrice(cropId, marketId, data);
      return data;
    } catch (e) {
      // Fallback to cached / seed price
      final cached = await LocalDataService.getCachedLatestPrice(cropId, marketId);
      if (cached != null) return cached;
      return {'price': 0.0, 'market': 'Offline'};
    }
  }

  Future<List<Map<String, dynamic>>> getHistory(String cropId, String marketId, {int days = 7}) async {
    try {
      final response = await _dio.get('/crops/$cropId/markets/$marketId/history', queryParameters: {
        'days': days,
      });
      final data = List<Map<String, dynamic>>.from(response.data);
      LocalDataService.cachePriceHistory(cropId, marketId, days, data);
      return data;
    } catch (e) {
      // Fallback to cached / generated history
      final cached = await LocalDataService.getCachedPriceHistory(cropId, marketId, days);
      return cached ?? [];
    }
  }
}
