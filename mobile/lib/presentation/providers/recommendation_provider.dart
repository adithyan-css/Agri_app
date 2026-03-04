import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/recommendation_repository.dart';
import '../../data/models/transport_profit_model.dart';

/// Input parameters for the transport profit calculation
typedef TransportProfitParams = ({
  String cropId,
  String targetMarketId,
  double distanceKm,
  double volumeKg,
  double perKmRate,
});

/// Provider to calculate transport profit (call via ref.read/watch)
final transportProfitProvider =
    FutureProvider.family<TransportProfitModel, TransportProfitParams>(
  (ref, params) async {
    final repo = ref.read(recommendationRepositoryProvider);
    return repo.calculateTransportProfit(
      cropId: params.cropId,
      targetMarketId: params.targetMarketId,
      distanceKm: params.distanceKm,
      volumeKg: params.volumeKg,
      perKmRate: params.perKmRate,
    );
  },
);
