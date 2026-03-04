import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/crop_price_model.dart';
import '../../models/market_model.dart';

/// Local data service that provides:
/// 1. Embedded seed data for crops, markets, and prices (works with zero network)
/// 2. SharedPreferences cache for data fetched from the API (survives app restarts)
class LocalDataService {
  static const _cropsCacheKey = 'cached_crops';
  static const _marketsCacheKey = 'cached_markets';
  static const _pricesCacheKeyPrefix = 'cached_price_';
  static const _historyCacheKeyPrefix = 'cached_history_';

  // ── Cache write ──────────────────────────────────────────────

  static Future<void> cacheCrops(List<dynamic> rawJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cropsCacheKey, jsonEncode(rawJson));
  }

  static Future<void> cacheMarkets(List<dynamic> rawJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_marketsCacheKey, jsonEncode(rawJson));
  }

  static Future<void> cacheLatestPrice(
      String cropId, String marketId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '${_pricesCacheKeyPrefix}${cropId}_$marketId', jsonEncode(data));
  }

  static Future<void> cachePriceHistory(
      String cropId, String marketId, int days, List<dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '${_historyCacheKeyPrefix}${cropId}_${marketId}_$days',
        jsonEncode(data));
  }

  // ── Cache read ───────────────────────────────────────────────

  static Future<List<CropModel>> getCachedCrops() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cropsCacheKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      return list.map((e) => CropModel.fromJson(e)).toList();
    }
    return _seedCrops;
  }

  static Future<List<MarketModel>> getCachedMarkets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_marketsCacheKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      return list.map((e) => MarketModel.fromJson(e)).toList();
    }
    return _seedMarkets;
  }

  static Future<Map<String, dynamic>?> getCachedLatestPrice(
      String cropId, String marketId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${_pricesCacheKeyPrefix}${cropId}_$marketId');
    if (raw != null) return jsonDecode(raw);
    // Try to find a seed price
    return _findSeedPrice(cropId, marketId);
  }

  static Future<List<Map<String, dynamic>>?> getCachedPriceHistory(
      String cropId, String marketId, int days) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(
        '${_historyCacheKeyPrefix}${cropId}_${marketId}_$days');
    if (raw != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(raw));
    }
    return _generateSeedHistory(cropId, days);
  }

  // ── Embedded seed data (works without any network) ───────────

  static final List<CropModel> _seedCrops = [
    CropModel(
        id: 'seed-tomato',
        nameEn: 'Tomato',
        nameTa: 'தக்காளி (Thakkali)',
        category: 'Vegetable'),
    CropModel(
        id: 'seed-onion',
        nameEn: 'Onion',
        nameTa: 'வெங்காயம் (Vengayam)',
        category: 'Vegetable'),
    CropModel(
        id: 'seed-potato',
        nameEn: 'Potato',
        nameTa: 'உருளைக்கிழங்கு (Urulaikizhangu)',
        category: 'Vegetable'),
    CropModel(
        id: 'seed-rice',
        nameEn: 'Rice',
        nameTa: 'அரிசி (Arisi)',
        category: 'Grain'),
    CropModel(
        id: 'seed-wheat',
        nameEn: 'Wheat',
        nameTa: 'கோதுமை (Kothumai)',
        category: 'Grain'),
  ];

  static final List<MarketModel> _seedMarkets = [
    MarketModel(
      id: 'seed-coimbatore',
      nameEn: 'Coimbatore Market',
      nameTa: 'கோயம்புத்தூர் சந்தை',
      district: 'Coimbatore',
      state: 'Tamil Nadu',
      lat: 11.0168,
      lng: 76.9558,
      openHours: '6:00 AM - 6:00 PM',
      isOpen: true,
    ),
    MarketModel(
      id: 'seed-salem',
      nameEn: 'Salem Market',
      nameTa: 'சேலம் சந்தை',
      district: 'Salem',
      state: 'Tamil Nadu',
      lat: 11.6643,
      lng: 78.1460,
      openHours: '6:00 AM - 6:00 PM',
      isOpen: true,
    ),
    MarketModel(
      id: 'seed-madurai',
      nameEn: 'Madurai Market',
      nameTa: 'மதுரை சந்தை',
      district: 'Madurai',
      state: 'Tamil Nadu',
      lat: 9.9252,
      lng: 78.1198,
      openHours: '5:00 AM - 7:00 PM',
      isOpen: true,
    ),
    MarketModel(
      id: 'seed-erode',
      nameEn: 'Erode Market',
      nameTa: 'ஈரோடு சந்தை',
      district: 'Erode',
      state: 'Tamil Nadu',
      lat: 11.3410,
      lng: 77.7172,
      openHours: '6:00 AM - 5:00 PM',
      isOpen: true,
    ),
    MarketModel(
      id: 'seed-chennai',
      nameEn: 'Koyambedu Market',
      nameTa: 'கோயம்பேடு சந்தை',
      district: 'Chennai',
      state: 'Tamil Nadu',
      lat: 13.0694,
      lng: 80.1948,
      openHours: '4:00 AM - 8:00 PM',
      isOpen: true,
    ),
    MarketModel(
      id: 'seed-nashik',
      nameEn: 'Lasalgaon Market',
      nameTa: 'லசல்கான் சந்தை',
      district: 'Nashik',
      state: 'Maharashtra',
      lat: 20.1432,
      lng: 74.2399,
      openHours: '6:00 AM - 6:00 PM',
      isOpen: true,
    ),
    MarketModel(
      id: 'seed-azadpur',
      nameEn: 'Azadpur Mandi',
      nameTa: 'ஆசாத்பூர் மண்டி',
      district: 'Delhi',
      state: 'Delhi',
      lat: 28.7196,
      lng: 77.1780,
      openHours: '3:00 AM - 9:00 PM',
      isOpen: true,
    ),
    MarketModel(
      id: 'seed-bangalore',
      nameEn: 'Yeshwanthpur Market',
      nameTa: 'யெஷ்வந்தபுர் சந்தை',
      district: 'Bangalore',
      state: 'Karnataka',
      lat: 13.0220,
      lng: 77.5436,
      openHours: '5:00 AM - 7:00 PM',
      isOpen: true,
    ),
    MarketModel(
      id: 'seed-jaipur',
      nameEn: 'Muhana Mandi',
      nameTa: 'முஹானா மண்டி',
      district: 'Jaipur',
      state: 'Rajasthan',
      lat: 26.7628,
      lng: 75.8648,
      openHours: '6:00 AM - 6:00 PM',
      isOpen: true,
    ),
    MarketModel(
      id: 'seed-lucknow',
      nameEn: 'Lucknow Mandi',
      nameTa: 'லக்னோ மண்டி',
      district: 'Lucknow',
      state: 'Uttar Pradesh',
      lat: 26.8467,
      lng: 80.9462,
      openHours: '5:00 AM - 7:00 PM',
      isOpen: true,
    ),
  ];

  /// Seed prices: realistic Indian commodity prices in ₹/kg
  static final Map<String, double> _seedPrices = {
    'seed-tomato': 35.0,
    'seed-onion': 28.0,
    'seed-potato': 22.0,
    'seed-rice': 42.0,
    'seed-wheat': 26.0,
  };

  static Map<String, dynamic>? _findSeedPrice(
      String cropId, String marketId) {
    final price = _seedPrices[cropId];
    if (price == null) return null;
    return {
      'price': price,
      'market': 'Local data',
      'date': DateTime.now().toIso8601String(),
    };
  }

  /// Generate fake historical data for charts when offline
  static List<Map<String, dynamic>> _generateSeedHistory(
      String cropId, int days) {
    final basePrice = _seedPrices[cropId] ?? 30.0;
    final now = DateTime.now();
    final history = <Map<String, dynamic>>[];
    for (int i = days; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // Add small random-like variation using day-of-year
      final variation = ((date.day * 7 + date.month * 3) % 20 - 10) / 10.0;
      history.add({
        'date': date.toIso8601String().split('T').first,
        'price': (basePrice + basePrice * variation * 0.15)
            .clamp(basePrice * 0.7, basePrice * 1.4),
      });
    }
    return history;
  }
}
