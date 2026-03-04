import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/alert_model.dart';
import '../../../core/network/dio_client.dart';

/// Provider for the Alert API client
final alertApiProvider = Provider<AlertApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AlertApi(dio);
});

/// Alert API - handles all price alert REST calls
/// Endpoints:
///   POST /alerts     → Create a new price alert
///   GET  /alerts     → Get all active alerts for the user
///   DELETE /alerts/:id → Deactivate/delete an alert
class AlertApi {
  final Dio _dio;

  AlertApi(this._dio);

  /// Fetch all active alerts for the current user
  Future<List<AlertModel>> getAlerts() async {
    try {
      final response = await _dio.get('/alerts');
      return (response.data as List)
          .map((item) => AlertModel.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new price alert
  /// [cropId] - The crop to monitor
  /// [marketId] - The market to monitor
  /// [targetPrice] - Price threshold in ₹/kg
  /// [condition] - 'above' or 'below'
  Future<AlertModel> createAlert({
    required String cropId,
    required String marketId,
    required double targetPrice,
    required String condition,
  }) async {
    try {
      final response = await _dio.post('/alerts', data: {
        'cropId': cropId,
        'marketId': marketId,
        'targetPrice': targetPrice,
        'condition': condition,
      });
      return AlertModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete (deactivate) an existing alert
  Future<void> deleteAlert(String alertId) async {
    try {
      await _dio.delete('/alerts/$alertId');
    } catch (e) {
      rethrow;
    }
  }
}
