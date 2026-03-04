import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/transport_repository.dart';
import '../../data/models/truck_model.dart';
import '../../data/models/booking_model.dart';

/// Provider that fetches available trucks
final availableTrucksProvider = FutureProvider<List<TruckModel>>((ref) async {
  final repo = ref.watch(transportRepositoryProvider);
  return repo.getAvailableTrucks();
});

/// Provider that fetches the current user's bookings
final myBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repo = ref.watch(transportRepositoryProvider);
  return repo.getMyBookings();
});

/// Provider to book a truck (call via ref.read)
final bookTruckProvider =
    FutureProvider.family<BookingModel, ({String truckId, String bookingDate})>(
  (ref, params) async {
    final repo = ref.read(transportRepositoryProvider);
    return repo.bookTruck(
      truckId: params.truckId,
      bookingDate: params.bookingDate,
    );
  },
);
