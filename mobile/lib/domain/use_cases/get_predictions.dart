import '../../data/models/prediction_model.dart';
import '../../data/repositories/prediction_repository.dart';

/// Use case: fetch price predictions / forecasts for a crop-market pair.
class GetPredictions {
  final PredictionRepository _repository;

  GetPredictions(this._repository);

  /// [cropId] and [marketId] identify the pair.
  Future<ForecastResponse> call(
    String cropId,
    String marketId,
  ) async {
    return _repository.getForecast(cropId, marketId);
  }
}
