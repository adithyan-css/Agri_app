class CropModel {
  final String id;
  final String nameEn;
  final String nameTa;
  final String? category;
  final String? imageUrl;
  final int? baseShelfLifeDays;

  CropModel({
    required this.id,
    required this.nameEn,
    required this.nameTa,
    this.category,
    this.imageUrl,
    this.baseShelfLifeDays,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'],
      nameEn: json['nameEn'],
      nameTa: json['nameTa'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      baseShelfLifeDays: json['baseShelfLifeDays'],
    );
  }

  String getName(String langCode) {
    return langCode == 'ta' ? nameTa : nameEn;
  }
}
