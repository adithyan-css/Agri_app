import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/booking_model.dart';
import '../../providers/transport_provider.dart';

const _kPrimary = Color(0xFF10B77F);
const _kBgLight = Color(0xFFF6F8F7);
const _kTextPrimary = Color(0xFF0F172A);
const _kTextSecondary = Color(0xFF64748B);

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _kBgLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _kTextPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'My Bookings',
            style: TextStyle(
                color: _kTextPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: _kTextPrimary),
              onPressed: () => ref.invalidate(myBookingsProvider),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: _kPrimary,
            labelColor: _kPrimary,
            unselectedLabelColor: _kTextSecondary,
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: bookingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  const Text('Failed to load bookings',
                      style: TextStyle(
                          color: _kTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(e.toString(),
                      style: const TextStyle(
                          color: _kTextSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(myBookingsProvider),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: _kPrimary),
                    child: const Text('Retry',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          data: (bookings) {
            final active =
                bookings.where((b) => b.isActive).toList();
            final past =
                bookings.where((b) => !b.isActive).toList();

            return TabBarView(
              children: [
                _BookingList(bookings: active, emptyMsg: 'No active bookings'),
                _BookingList(bookings: past, emptyMsg: 'No past bookings'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final String emptyMsg;
  const _BookingList({required this.bookings, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(emptyMsg,
                style: const TextStyle(color: _kTextSecondary, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, i) => _BookingCard(booking: bookings[i]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  Color get _statusColor {
    switch (booking.status) {
      case 'confirmed':
        return _kPrimary;
      case 'completed':
        return Colors.blueGrey;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d, yyyy').format(booking.bookingDate);
    final truck = booking.truck;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: date + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dateStr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _kTextPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    booking.statusLabel,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Truck info
            if (truck != null) ...[
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined,
                      size: 16, color: _kTextSecondary),
                  const SizedBox(width: 6),
                  Text(
                    '${truck.licensePlate} – ${truck.capacityKg >= 1000 ? "${(truck.capacityKg / 1000).toStringAsFixed(1)} Tons" : "${truck.capacityKg} kg"}',
                    style: const TextStyle(
                      color: _kTextPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: _kTextSecondary),
                  const SizedBox(width: 6),
                  Text(
                    truck.driverName,
                    style:
                        const TextStyle(color: _kTextSecondary, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.phone_outlined,
                      size: 14, color: _kTextSecondary),
                  const SizedBox(width: 4),
                  Text(
                    truck.driverPhone,
                    style:
                        const TextStyle(color: _kTextSecondary, fontSize: 13),
                  ),
                ],
              ),
            ] else ...[
              const Row(
                children: [
                  Icon(Icons.local_shipping_outlined,
                      size: 16, color: _kTextSecondary),
                  SizedBox(width: 6),
                  Text('Truck details pending',
                      style: TextStyle(color: _kTextSecondary, fontSize: 13)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
