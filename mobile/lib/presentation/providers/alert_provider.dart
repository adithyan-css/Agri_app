import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/alert_repository.dart';
import '../../data/models/alert_model.dart';

/// Provider that fetches all active alerts for the current user
final alertListProvider = FutureProvider<List<AlertModel>>((ref) async {
  final repo = ref.watch(alertRepositoryProvider);
  return repo.getAlerts();
});

/// Input parameters for creating a new alert
typedef CreateAlertParams = ({
  String cropId,
  String marketId,
  double targetPrice,
  String condition,
});

/// Provider to create a new alert (call via ref.read)
final createAlertProvider =
    FutureProvider.family<AlertModel, CreateAlertParams>(
  (ref, params) async {
    final repo = ref.read(alertRepositoryProvider);
    final result = await repo.createAlert(
      cropId: params.cropId,
      marketId: params.marketId,
      targetPrice: params.targetPrice,
      condition: params.condition,
    );
    // Invalidate the alert list so it refreshes
    ref.invalidate(alertListProvider);
    return result;
  },
);

/// Provider to delete an alert (call via ref.read)
final deleteAlertProvider = FutureProvider.family<void, String>(
  (ref, alertId) async {
    final repo = ref.read(alertRepositoryProvider);
    await repo.deleteAlert(alertId);
    // Invalidate the alert list so it refreshes
    ref.invalidate(alertListProvider);
  },
);
