import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/truck_model.dart';
import '../../providers/transport_provider.dart';

const _kPrimary = Color(0xFF10B77F);
const _kBgLight = Color(0xFFF6F8F7);
const _kTextPrimary = Color(0xFF0F172A);
const _kTextSecondary = Color(0xFF64748B);

class AvailableTransportScreen extends ConsumerWidget {
  const AvailableTransportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trucksAsync = ref.watch(availableTrucksProvider);

    return Scaffold(
      backgroundColor: _kBgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Available Transport',
          style: TextStyle(
            color: _kTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, color: _kTextPrimary),
            tooltip: 'My Bookings',
            onPressed: () => context.push('/bookings'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: _kTextPrimary),
            onPressed: () => ref.invalidate(availableTrucksProvider),
          ),
        ],
      ),
      body: trucksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                const Text('Failed to load trucks',
                    style: TextStyle(color: _kTextPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(e.toString(), style: const TextStyle(color: _kTextSecondary, fontSize: 13)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(availableTrucksProvider),
                  style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        data: (trucks) {
          if (trucks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_shipping_outlined, size: 64, color: _kTextSecondary),
                  SizedBox(height: 12),
                  Text('No trucks available', style: TextStyle(color: _kTextSecondary, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trucks.length,
            itemBuilder: (context, i) => _TruckCard(truck: trucks[i]),
          );
        },
      ),
    );
  }
}

class _TruckCard extends StatelessWidget {
  final TruckModel truck;
  const _TruckCard({required this.truck});

  String get _capacityLabel {
    if (truck.capacityKg >= 1000) {
      return '${(truck.capacityKg / 1000).toStringAsFixed(1)} Tons';
    }
    return '${truck.capacityKg} kg';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Truck image placeholder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 160,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_shipping, size: 56, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      _capacityLabel,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${truck.licensePlate} ($_capacityLabel)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _kTextPrimary,
                        ),
                      ),
                    ),
                    if (truck.isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _kPrimary.withOpacity(0.4)),
                        ),
                        child: const Text(
                          'AVAILABLE',
                          style: TextStyle(
                            color: _kPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),

                // Price + driver
                Text(
                  '₹${truck.perKmRate.toStringAsFixed(0)}/km • ${truck.driverName}',
                  style: const TextStyle(
                    color: _kPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Driver phone
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 14, color: _kTextSecondary),
                    const SizedBox(width: 4),
                    Text(
                      truck.driverPhone,
                      style: const TextStyle(color: _kTextSecondary, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/transport/book?truckId=${truck.id}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const IconButton(
                        icon: Icon(Icons.phone_outlined, color: _kTextPrimary, size: 20),
                        onPressed: null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
