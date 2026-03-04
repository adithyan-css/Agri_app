import 'truck_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String truckId;
  final DateTime bookingDate;
  final String status; // pending, confirmed, completed, cancelled
  final DateTime createdAt;
  final TruckModel? truck;

  BookingModel({
    required this.id,
    required this.userId,
    required this.truckId,
    required this.bookingDate,
    required this.status,
    required this.createdAt,
    this.truck,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      userId: json['userId'] ?? '',
      truckId: json['truckId'] ?? '',
      bookingDate: DateTime.parse(json['bookingDate']),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      truck: json['truck'] != null ? TruckModel.fromJson(json['truck']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'truckId': truckId,
      'bookingDate': bookingDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Whether the booking is still active (not cancelled/completed)
  bool get isActive => status == 'pending' || status == 'confirmed';

  /// Human-readable status label
  String get statusLabel {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }
}
