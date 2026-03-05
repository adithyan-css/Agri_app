class PredictionModel {
  final String id;
  final String cropId;
  final String marketId;
  final DateTime targetDate;
  final double predictedPrice;
  final double confidenceScore;
  final double lowerBound;
  final double upperBound;
  final String modelUsed;

  PredictionModel({
    required this.id,
    required this.cropId,
    required this.marketId,
    required this.targetDate,
    required this.predictedPrice,
    required this.confidenceScore,
    required this.lowerBound,
    required this.upperBound,
    required this.modelUsed,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      id: json['id'] ?? '',
      cropId: json['cropId'] ?? '',
      marketId: json['marketId'] ?? '',
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : DateTime.now(),
      predictedPrice: (json['predictedPrice'] is String) 
          ? double.parse(json['predictedPrice']) 
          : (json['predictedPrice'] as num).toDouble(),
      confidenceScore: (json['confidenceScore'] is String) 
          ? double.parse(json['confidenceScore']) 
          : (json['confidenceScore'] as num).toDouble(),
      lowerBound: (json['lowerBound'] is String) 
          ? double.parse(json['lowerBound']) 
          : (json['lowerBound'] as num).toDouble(),
      upperBound: (json['upperBound'] is String) 
          ? double.parse(json['upperBound']) 
          : (json['upperBound'] as num).toDouble(),
      modelUsed: json['modelUsed'] ?? 'chronos',
    );
  }
}

class ForecastResponse {
  final String source;
  final String trend;
  final String recommendation;
  final double confidence;
  final List<PredictionModel> data;

  ForecastResponse({
    required this.source,
    required this.trend,
    required this.recommendation,
    required this.confidence,
    required this.data,
  });

  factory ForecastResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List?) ?? [];
    final predictions = dataList
        .map((item) => PredictionModel.fromJson(item))
        .toList();

    // Compute confidence from predictions if not provided at top level
    double confidence = 0.0;
    if (json['confidence'] != null) {
      confidence = (json['confidence'] as num).toDouble();
    } else if (predictions.isNotEmpty) {
      confidence = predictions
              .map((p) => p.confidenceScore)
              .reduce((a, b) => a + b) /
          predictions.length;
    }

    return ForecastResponse(
      source: json['source'] ?? 'unknown',
      trend: json['trend'] ?? 'STABLE',
      recommendation: json['recommendation'] ?? 'WAIT',
      confidence: confidence,
      data: predictions,
    );
  }
}
