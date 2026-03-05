/// Model for the road-distance-based transport profit response
/// from POST /transport-profit
class RoadProfitModel {
  final String marketId;
  final String marketName;
  final String marketNameTa;
  final String district;
  final String state;
  final double roadDistanceKm;
  final int travelTimeMinutes;
  final double pricePerKg;
  final double grossRevenue;
  final double transportCost;
  final double netProfit;
  final double profitPerKg;
  final bool isProfitable;
  final bool isBestMarket;

  RoadProfitModel({
    required this.marketId,
    required this.marketName,
    required this.marketNameTa,
    required this.district,
    required this.state,
    required this.roadDistanceKm,
    required this.travelTimeMinutes,
    required this.pricePerKg,
    required this.grossRevenue,
    required this.transportCost,
    required this.netProfit,
    required this.profitPerKg,
    required this.isProfitable,
    required this.isBestMarket,
  });

  factory RoadProfitModel.fromJson(Map<String, dynamic> json) {
    return RoadProfitModel(
      marketId: json['marketId'] ?? '',
      marketName: json['marketName'] ?? 'Unknown',
      marketNameTa: json['marketNameTa'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      roadDistanceKm: (json['roadDistanceKm'] as num?)?.toDouble() ?? 0.0,
      travelTimeMinutes: (json['travelTimeMinutes'] as num?)?.toInt() ?? 0,
      pricePerKg: (json['pricePerKg'] as num?)?.toDouble() ?? 0.0,
      grossRevenue: (json['grossRevenue'] as num?)?.toDouble() ?? 0.0,
      transportCost: (json['transportCost'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
      profitPerKg: (json['profitPerKg'] as num?)?.toDouble() ?? 0.0,
      isProfitable: json['isProfitable'] ?? false,
      isBestMarket: json['isBestMarket'] ?? false,
    );
  }

  String get formattedProfit => '₹${netProfit.toStringAsFixed(0)}';
  String get formattedProfitPerKg => '₹${profitPerKg.toStringAsFixed(2)}/kg';
  String get formattedTravelTime {
    if (travelTimeMinutes < 60) return '${travelTimeMinutes}min';
    final h = travelTimeMinutes ~/ 60;
    final m = travelTimeMinutes % 60;
    return '${h}h ${m}m';
  }
}
