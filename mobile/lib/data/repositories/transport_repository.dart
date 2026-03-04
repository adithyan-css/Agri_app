import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_sources/remote/transport_api.dart';
import '../models/truck_model.dart';
import '../models/booking_model.dart';

/// Repository provider for transport operations
final transportRepositoryProvider = Provider<TransportRepository>((ref) {
  final transportApi = ref.watch(transportApiProvider);
  return TransportRepository(transportApi);
});

/// Transport Repository
/// Provides a clean interface to the transport API for the presentation layer.
class TransportRepository {
  final TransportApi _transportApi;

  TransportRepository(this._transportApi);

  /// Get all available trucks
  Future<List<TruckModel>> getAvailableTrucks() async {
    return _transportApi.getAvailableTrucks();
  }

  /// Book a truck for transport
  Future<BookingModel> bookTruck({
    required String truckId,
    required String bookingDate,
  }) async {
    return _transportApi.bookTruck(
      truckId: truckId,
      bookingDate: bookingDate,
    );
  }

  /// Get current user's booking history
  Future<List<BookingModel>> getMyBookings() async {
    return _transportApi.getMyBookings();
  }
}
