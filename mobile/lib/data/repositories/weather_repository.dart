import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_sources/remote/weather_api.dart';
import '../models/weather_model.dart';

/// Repository provider for weather operations
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final api = ref.watch(weatherApiProvider);
  return WeatherRepository(api);
});

/// Weather Repository
class WeatherRepository {
  final WeatherApi _api;

  WeatherRepository(this._api);

  /// Fetch current weather for a location
  Future<WeatherModel> getWeather({
    required double lat,
    required double lon,
  }) async {
    return _api.getWeather(lat: lat, lon: lon);
  }
}
