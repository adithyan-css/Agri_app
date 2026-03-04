/// Model representing a nearby market with profit calculation.
/// Used by the Nearby Market Profit Optimizer feature.
///
/// Fields:
///   - marketName: English name of the market
///   - distanceKm: Distance from user's GPS location
///   - pricePerKg: Current crop price at this market
///   - transportCostPerKg: Estimated transport cost per kg
///   - profitAfterTransport: Net profit after transport deduction
///   - isBestMarket: True if this is the most profitable option
class NearbyMarketProfitModel {
  final String marketId;
  final String marketName;
  final String marketNameTa;
  final String district;
  final String state;
  final double distanceKm;
  final double? pricePerKg;
  final double? transportCostPerKg;
  final double? profitAfterTransport;
  final bool isActive;
  final bool isBestMarket;

  NearbyMarketProfitModel({
    required this.marketId,
    required this.marketName,
    required this.marketNameTa,
    required this.district,
    required this.state,
    required this.distanceKm,
    this.pricePerKg,
    this.transportCostPerKg,
    this.profitAfterTransport,
    this.isActive = true,
    this.isBestMarket = false,
  });

  /// Parse from the backend JSON response
  factory NearbyMarketProfitModel.fromJson(Map<String, dynamic> json) {
    return NearbyMarketProfitModel(
      marketId: json['marketId'] ?? '',
      marketName: json['marketName'] ?? 'Unknown',
      marketNameTa: json['marketNameTa'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      pricePerKg: (json['pricePerKg'] as num?)?.toDouble(),
      transportCostPerKg: (json['transportCostPerKg'] as num?)?.toDouble(),
      profitAfterTransport: (json['profitAfterTransport'] as num?)?.toDouble(),
      isActive: json['isActive'] ?? true,
      isBestMarket: json['isBestMarket'] ?? false,
    );
  }

  /// Get the localized market name
  String getName(String langCode) {
    return langCode == 'ta' ? marketNameTa : marketName;
  }

  /// Check if this market has price data
  bool get hasPriceData => pricePerKg != null && pricePerKg! > 0;

  /// Check if selling at this market is profitable after transport
  bool get isProfitable =>
      profitAfterTransport != null && profitAfterTransport! > 0;
}
