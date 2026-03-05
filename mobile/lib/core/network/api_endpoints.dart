class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';

  // Crops
  static const String crops = '/crops';
  static String cropById(String id) => '/crops/$id';
  static String latestPrice(String cropId, String marketId) =>
      '/crops/$cropId/markets/$marketId/latest-price';
  static String priceHistory(String cropId, String marketId) =>
      '/crops/$cropId/markets/$marketId/history';

  // Markets
  static const String markets = '/markets';
  static const String nearbyMarkets = '/markets/nearby';
  static String marketById(String id) => '/markets/$id';

  // Predictions
  static String forecast(String cropId, String marketId) =>
      '/predictions/$cropId/markets/$marketId/forecast';

  // Alerts
  static const String alerts = '/alerts';
  static String alertById(String id) => '/alerts/$id';

  // Intelligence
  static const String transportProfit = '/intelligence/transport-profit';

  // Road routing (ORS-powered)
  static const String roadTransportProfit = '/transport-profit';
}
