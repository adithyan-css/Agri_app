class TruckModel {
  final String id;
  final String licensePlate;
  final String driverName;
  final String driverPhone;
  final int capacityKg;
  final double perKmRate;
  final bool isAvailable;

  TruckModel({
    required this.id,
    required this.licensePlate,
    required this.driverName,
    required this.driverPhone,
    required this.capacityKg,
    required this.perKmRate,
    required this.isAvailable,
  });

  factory TruckModel.fromJson(Map<String, dynamic> json) {
    return TruckModel(
      id: json['id'],
      licensePlate: json['licensePlate'] ?? '',
      driverName: json['driverName'] ?? '',
      driverPhone: json['driverPhone'] ?? '',
      capacityKg: (json['capacityKg'] as num?)?.toInt() ?? 0,
      perKmRate: (json['perKmRate'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'capacityKg': capacityKg,
      'perKmRate': perKmRate,
      'isAvailable': isAvailable,
    };
  }
}
