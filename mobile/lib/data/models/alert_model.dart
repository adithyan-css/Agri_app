class AlertModel {
  final String id;
  final String cropId;
  final String cropName;
  final String marketId;
  final String marketName;
  final double targetPrice;
  final String condition; // 'above' or 'below'
  final bool isActive;
  final bool isTriggered;
  final DateTime createdAt;
  final DateTime? triggeredAt;

  AlertModel({
    required this.id,
    required this.cropId,
    required this.cropName,
    required this.marketId,
    required this.marketName,
    required this.targetPrice,
    required this.condition,
    this.isActive = true,
    this.isTriggered = false,
    required this.createdAt,
    this.triggeredAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] ?? '',
      cropId: json['cropId'] ?? '',
      cropName: json['cropName'] ?? 'Unknown Crop',
      marketId: json['marketId'] ?? '',
      marketName: json['marketName'] ?? 'Unknown Market',
      targetPrice: (json['targetPrice'] is String)
          ? double.parse(json['targetPrice'])
          : (json['targetPrice'] as num).toDouble(),
      condition: json['condition'] ?? 'above',
      isActive: json['isActive'] ?? true,
      isTriggered: json['isTriggered'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      triggeredAt: json['triggeredAt'] != null
          ? DateTime.parse(json['triggeredAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropId': cropId,
      'marketId': marketId,
      'targetPrice': targetPrice,
      'condition': condition,
      'isActive': isActive,
    };
  }

  AlertModel copyWith({
    bool? isActive,
    bool? isTriggered,
  }) {
    return AlertModel(
      id: id,
      cropId: cropId,
      cropName: cropName,
      marketId: marketId,
      marketName: marketName,
      targetPrice: targetPrice,
      condition: condition,
      isActive: isActive ?? this.isActive,
      isTriggered: isTriggered ?? this.isTriggered,
      createdAt: createdAt,
      triggeredAt: triggeredAt,
    );
  }
}
