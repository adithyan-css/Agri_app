import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/truck_model.dart';
import '../../models/booking_model.dart';
import '../../../core/network/dio_client.dart';

/// Provider for the Transport API client
final transportApiProvider = Provider<TransportApi>((ref) {
  final dio = ref.watch(dioProvider);
  return TransportApi(dio);
});

/// Transport API - handles truck availability and booking REST calls
/// Endpoints:
///   GET  /transport/available    → List all available trucks
///   POST /transport/book         → Book a truck
///   GET  /transport/my-bookings  → Get current user's bookings
class TransportApi {
  final Dio _dio;

  TransportApi(this._dio);

  /// List all available trucks for booking
  Future<List<TruckModel>> getAvailableTrucks() async {
    try {
      final response = await _dio.get('/transport/available');
      return (response.data as List)
          .map((item) => TruckModel.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Book a truck
  /// [truckId] - UUID of the truck to book
  /// [bookingDate] - Date string in ISO format (e.g., '2024-03-10')
  Future<BookingModel> bookTruck({
    required String truckId,
    required String bookingDate,
  }) async {
    try {
      final response = await _dio.post('/transport/book', data: {
        'truckId': truckId,
        'bookingDate': bookingDate,
      });
      return BookingModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user's booking history
  Future<List<BookingModel>> getMyBookings() async {
    try {
      final response = await _dio.get('/transport/my-bookings');
      return (response.data as List)
          .map((item) => BookingModel.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
