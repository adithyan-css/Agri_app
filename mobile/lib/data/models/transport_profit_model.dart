/// Model for the transport profit calculation response from
/// POST /intelligence/transport-profit
class TransportProfitModel {
  final String cropId;
  final String marketId;
  final double currentPricePerKg;
  final double grossRevenue;
  final double transportCost;
  final double netProfit;
  final bool isProfitable;
  final double marginPercentage;

  TransportProfitModel({
    required this.cropId,
    required this.marketId,
    required this.currentPricePerKg,
    required this.grossRevenue,
    required this.transportCost,
    required this.netProfit,
    required this.isProfitable,
    required this.marginPercentage,
  });

  factory TransportProfitModel.fromJson(Map<String, dynamic> json) {
    return TransportProfitModel(
      cropId: json['cropId'] ?? '',
      marketId: json['marketId'] ?? '',
      currentPricePerKg: (json['currentPricePerKg'] as num?)?.toDouble() ?? 0.0,
      grossRevenue: (json['grossRevenue'] as num?)?.toDouble() ?? 0.0,
      transportCost: (json['transportCost'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
      isProfitable: json['isProfitable'] ?? false,
      marginPercentage: (json['marginPercentage'] is String)
          ? double.tryParse(json['marginPercentage']) ?? 0.0
          : (json['marginPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropId': cropId,
      'marketId': marketId,
      'currentPricePerKg': currentPricePerKg,
      'grossRevenue': grossRevenue,
      'transportCost': transportCost,
      'netProfit': netProfit,
      'isProfitable': isProfitable,
      'marginPercentage': marginPercentage,
    };
  }

  /// Formatted profit with ₹ sign
  String get formattedProfit => '₹${netProfit.toStringAsFixed(2)}';

  /// Formatted margin
  String get formattedMargin => '${marginPercentage.toStringAsFixed(1)}%';
}
