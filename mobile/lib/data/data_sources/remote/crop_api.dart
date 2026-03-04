import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/crop_price_model.dart';
import '../../../core/network/dio_client.dart';

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
      return (response.data as List)
          .map((item) => CropModel.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getLatestPrice(String cropId, String marketId) async {
    try {
      final response = await _dio.get('/crops/$cropId/markets/$marketId/latest-price');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getHistory(String cropId, String marketId, {int days = 7}) async {
    try {
      final response = await _dio.get('/crops/$cropId/markets/$marketId/history', queryParameters: {
        'days': days,
      });
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
