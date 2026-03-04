import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/weather_model.dart';
import '../../../core/network/dio_client.dart';

/// Provider for the Weather API client
final weatherApiProvider = Provider<WeatherApi>((ref) {
  final dio = ref.watch(dioProvider);
  return WeatherApi(dio);
});

/// Weather API - fetches current weather for a location
/// Endpoints:
///   GET /weather?lat=&lon= → Current weather data
class WeatherApi {
  final Dio _dio;

  WeatherApi(this._dio);

  /// Fetch weather for a given latitude/longitude
  Future<WeatherModel> getWeather({
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await _dio.get('/weather', queryParameters: {
        'lat': lat,
        'lon': lon,
      });
      return WeatherModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
