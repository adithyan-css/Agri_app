import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_sources/remote/alert_api.dart';
import '../models/alert_model.dart';

/// Repository provider for price alerts
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  final alertApi = ref.watch(alertApiProvider);
  return AlertRepository(alertApi);
});

/// Alert Repository
/// Provides a clean interface to the alert API for the presentation layer.
class AlertRepository {
  final AlertApi _alertApi;

  AlertRepository(this._alertApi);

  /// Get all active alerts for the current user
  Future<List<AlertModel>> getAlerts() async {
    return _alertApi.getAlerts();
  }

  /// Create a new price alert
  Future<AlertModel> createAlert({
    required String cropId,
    required String marketId,
    required double targetPrice,
    required String condition,
  }) async {
    return _alertApi.createAlert(
      cropId: cropId,
      marketId: marketId,
      targetPrice: targetPrice,
      condition: condition,
    );
  }

  /// Toggle an alert's active status
  Future<void> toggleAlert(String alertId, bool isActive) async {
    return _alertApi.toggleAlert(alertId, isActive);
  }

  /// Delete (deactivate) an existing alert
  Future<void> deleteAlert(String alertId) async {
    return _alertApi.deleteAlert(alertId);
  }
}
