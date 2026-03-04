/// Model for the AI Sell or Wait Recommendation Engine response.
///
/// The backend compares current price vs predicted prices and returns:
///   - action: 'SELL' or 'WAIT'
///   - trend: 'UP', 'DOWN', or 'STABLE'
///   - currentPrice & predictedPrice in ₹/kg
///   - expectedProfit (potential gain per kg if waiting)
///   - confidence (0.0 to 1.0 range)
///   - reason: human-readable explanation
class RecommendationModel {
  final String action; // 'SELL' or 'WAIT'
  final String reason;
  final double confidence;
  final String trend; // 'UP', 'DOWN', 'STABLE'
  final double currentPrice;
  final double predictedPrice;
  final double potentialGain;
  final List<PredictionPoint> predictions;

  RecommendationModel({
    required this.action,
    required this.reason,
    required this.confidence,
    required this.trend,
    required this.currentPrice,
    required this.predictedPrice,
    required this.potentialGain,
    this.predictions = const [],
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    // Parse the predictions array if present
    List<PredictionPoint> predictionPoints = [];
    if (json['predictions'] != null) {
      predictionPoints = (json['predictions'] as List)
          .map((p) => PredictionPoint.fromJson(p))
          .toList();
    }

    return RecommendationModel(
      action: json['action'] ?? json['recommendation'] ?? 'WAIT',
      reason: json['reason'] ?? _defaultReason(json['recommendation'] ?? 'WAIT'),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      trend: json['trend'] ?? 'STABLE',
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      predictedPrice: (json['predictedPrice'] as num?)?.toDouble() ?? 0.0,
      potentialGain: (json['expectedProfit'] as num?)?.toDouble() ??
          (json['potentialGain'] as num?)?.toDouble() ?? 0.0,
      predictions: predictionPoints,
    );
  }

  static String _defaultReason(String action) {
    if (action == 'SELL') {
      return 'Current market conditions are optimal for selling. Prices are expected to stabilize or dip.';
    }
    return 'Prices are trending upward. Waiting might yield a better profit margin.';
  }

  /// Convenience getters for the UI
  bool get isSell => action == 'SELL';
  bool get isWait => action == 'WAIT';

  /// Confidence as a percentage string (e.g., "85.2%")
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';
}

/// A single data point in the prediction forecast
class PredictionPoint {
  final String date;
  final double price;
  final double lowerBound;
  final double upperBound;

  PredictionPoint({
    required this.date,
    required this.price,
    required this.lowerBound,
    required this.upperBound,
  });

  factory PredictionPoint.fromJson(Map<String, dynamic> json) {
    return PredictionPoint(
      date: json['date']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      lowerBound: (json['lowerBound'] as num?)?.toDouble() ?? 0.0,
      upperBound: (json['upperBound'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
