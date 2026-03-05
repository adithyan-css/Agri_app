class MarketModel {
  final String id;
  final String nameEn;
  final String nameTa;
  final String district;
  final String state;
  final double? distanceKm;
  final bool isActive;
  final double? lat;
  final double? lng;
  final String? phone;
  final String? openHours;
  final bool? isOpen;
  final double avgPrice;

  MarketModel({
    required this.id,
    required this.nameEn,
    required this.nameTa,
    required this.district,
    required this.state,
    this.distanceKm,
    this.isActive = true,
    this.lat,
    this.lng,
    this.phone,
    this.openHours,
    this.isOpen,
    this.avgPrice = 0,
  });

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      id: json['id'],
      nameEn: json['nameEn'],
      nameTa: json['nameTa'],
      district: json['district'],
      state: json['state'],
      distanceKm: json['distanceKm']?.toDouble(),
      isActive: json['isActive'] ?? true,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      phone: json['phone'],
      openHours: json['openHours'],
      isOpen: json['isOpen'],
      avgPrice: (json['avgPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  String getName(String langCode) {
    return langCode == 'ta' ? nameTa : nameEn;
  }

  /// Status label for UI
  String get statusLabel {
    if (isOpen == true) return 'Open';
    if (isOpen == false) return 'Closed';
    return 'Unknown';
  }
}
