import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/models/weather_model.dart';

/// Fetch weather for a given lat/lon pair
final weatherProvider =
    FutureProvider.family<WeatherModel, ({double lat, double lon})>(
  (ref, params) async {
    final repo = ref.watch(weatherRepositoryProvider);
    return repo.getWeather(lat: params.lat, lon: params.lon);
  },
);
