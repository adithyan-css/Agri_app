/// Model for weather data from GET /weather?lat=&lon=
class WeatherModel {
  final double tempCelsius;
  final double rainfallMm;
  final int humidityPercent;
  final String conditions;
  final DateTime forecastDate;

  WeatherModel({
    required this.tempCelsius,
    required this.rainfallMm,
    required this.humidityPercent,
    required this.conditions,
    required this.forecastDate,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      tempCelsius: (json['tempCelsius'] as num?)?.toDouble() ?? 0.0,
      rainfallMm: (json['rainfallMm'] as num?)?.toDouble() ?? 0.0,
      humidityPercent: (json['humidityPercent'] as num?)?.toInt() ?? 0,
      conditions: json['conditions'] ?? 'Unknown',
      forecastDate: json['forecastDate'] != null
          ? DateTime.parse(json['forecastDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tempCelsius': tempCelsius,
      'rainfallMm': rainfallMm,
      'humidityPercent': humidityPercent,
      'conditions': conditions,
      'forecastDate': forecastDate.toIso8601String(),
    };
  }

  /// Icon-friendly conditions label
  String get conditionsLabel {
    switch (conditions.toLowerCase()) {
      case 'clear':
        return 'Clear Sky';
      case 'clouds':
        return 'Cloudy';
      case 'rain':
        return 'Rainy';
      case 'drizzle':
        return 'Drizzle';
      case 'thunderstorm':
        return 'Thunderstorm';
      default:
        return conditions;
    }
  }

  /// Temperature formatted
  String get tempFormatted => '${tempCelsius.toStringAsFixed(0)}°C';

  /// Humidity formatted
  String get humidityFormatted => '$humidityPercent%';

  /// Rainfall formatted
  String get rainfallFormatted => '${rainfallMm.toStringAsFixed(1)} mm';
}
