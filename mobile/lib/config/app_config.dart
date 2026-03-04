class AppConfig {
  static const String appName = 'AgriPrice AI';
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api/v1';
  static const String mlServiceUrl = 'http://10.0.2.2:8000';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const List<String> supportedCrops = [
    'Tomato',
    'Onion',
    'Potato',
    'Rice',
    'Wheat',
  ];

  static const List<String> supportedMarkets = [
    'Coimbatore',
    'Salem',
    'Madurai',
    'Erode',
  ];

  static const List<String> supportedLanguages = ['en', 'ta'];

  static const String defaultLanguage = 'en';
  static const double defaultSearchRadius = 50.0; // km
}
