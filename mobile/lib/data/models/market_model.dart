class MarketModel {
  final String id;
  final String nameEn;
  final String nameTa;
  final String district;
  final String state;
  final double? distanceKm;
  final bool isActive;

  MarketModel({
    required this.id,
    required this.nameEn,
    required this.nameTa,
    required this.district,
    required this.state,
    this.distanceKm,
    this.isActive = true,
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
    );
  }

  String getName(String langCode) {
    return langCode == 'ta' ? nameTa : nameEn;
  }
}
