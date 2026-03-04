import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/nearby_market_profit_model.dart';
import '../../providers/market_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/crop_provider.dart';

const _kPrimary = Color(0xFF10b77f);

/// Filter options for nearby markets
enum _FilterMode { nearest, bestProfit, wholesale }

class NearbyMarketsScreen extends ConsumerStatefulWidget {
  const NearbyMarketsScreen({super.key});

  @override
  ConsumerState<NearbyMarketsScreen> createState() => _NearbyMarketsScreenState();
}

class _NearbyMarketsScreenState extends ConsumerState<NearbyMarketsScreen> {
  _FilterMode _filter = _FilterMode.nearest;

  @override
  void initState() {
    super.initState();
    // Ensure location is fetched
    final loc = ref.read(locationProvider);
    if (!loc.hasLocation) {
      ref.read(locationProvider.notifier).getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locState = ref.watch(locationProvider);
    final cropsAsync = ref.watch(cropListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Markets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => ref.read(locationProvider.notifier).getCurrentLocation(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildChip('Nearest', _FilterMode.nearest),
                const SizedBox(width: 8),
                _buildChip('Best Profit', _FilterMode.bestProfit),
                const SizedBox(width: 8),
                _buildChip('Wholesale', _FilterMode.wholesale),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(locState, cropsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, _FilterMode mode) {
    final selected = _filter == mode;
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: _kPrimary.withOpacity(0.15),
      checkmarkColor: _kPrimary,
      labelStyle: TextStyle(
        color: selected ? _kPrimary : Colors.grey.shade700,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _filter = mode),
    );
  }

  Widget _buildBody(LocationState locState, AsyncValue<dynamic> cropsAsync) {
    if (locState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (locState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(locState.error!, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(locationProvider.notifier).getCurrentLocation(),
                child: const Text('Enable Location'),
              ),
            ],
          ),
        ),
      );
    }
    if (!locState.hasLocation) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_searching, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Tap to detect your location'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => ref.read(locationProvider.notifier).getCurrentLocation(),
              icon: const Icon(Icons.my_location),
              label: const Text('Get Location'),
            ),
          ],
        ),
      );
    }

    return cropsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load crops: $e')),
      data: (crops) {
        // Use first crop for profit calculation — user can change later
        final cropId = crops.isNotEmpty ? crops.first.id : '';
        if (cropId.isEmpty) {
          return const Center(child: Text('No crops available'));
        }

        final marketsAsync = ref.watch(
          nearbyMarketsWithProfitProvider((
            lat: locState.latitude!,
            lng: locState.longitude!,
            cropId: cropId,
            radius: 100.0,
          )),
        );

        return marketsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text('Failed to load markets: $e'),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => ref.invalidate(nearbyMarketsWithProfitProvider), child: const Text('Retry')),
                ],
              ),
            ),
          ),
          data: (markets) {
            // Apply filter
            final sorted = List<NearbyMarketProfitModel>.from(markets);
            switch (_filter) {
              case _FilterMode.nearest:
                sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
                break;
              case _FilterMode.bestProfit:
                sorted.sort((a, b) => (b.profitAfterTransport ?? 0).compareTo(a.profitAfterTransport ?? 0));
                break;
              case _FilterMode.wholesale:
                // Show only larger markets (active ones sorted by distance)
                sorted.retainWhere((m) => m.isActive);
                sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
                break;
            }

            if (sorted.isEmpty) {
              return const Center(child: Text('No markets found nearby'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final market = sorted[index];
                return _MarketProfitCard(
                  market: market,
                  isBest: market.isBestMarket,
                  onTap: () => context.push('/market-detail/${market.marketId}'),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _MarketProfitCard extends StatelessWidget {
  final NearbyMarketProfitModel market;
  final bool isBest;
  final VoidCallback onTap;

  const _MarketProfitCard({
    required this.market,
    required this.isBest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isBest ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isBest
            ? const BorderSide(color: _kPrimary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      market.marketName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  if (isBest)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _kPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('BEST',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${market.district}, ${market.state}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              // Stats row
              Row(
                children: [
                  _StatPill(
                    icon: Icons.directions_car,
                    label: '${market.distanceKm.toStringAsFixed(1)} km',
                  ),
                  const SizedBox(width: 8),
                  if (market.hasPriceData)
                    _StatPill(
                      icon: Icons.currency_rupee,
                      label: '₹${market.pricePerKg!.toStringAsFixed(0)}/kg',
                    ),
                  if (market.profitAfterTransport != null) ...[
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: market.isProfitable ? Icons.trending_up : Icons.trending_down,
                      label: '₹${market.profitAfterTransport!.toStringAsFixed(0)} profit/kg',
                      color: market.isProfitable ? Colors.green : Colors.red,
                    ),
                  ],
                ],
              ),
              if (market.transportCostPerKg != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Transport: ₹${market.transportCostPerKg!.toStringAsFixed(1)}/kg',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _StatPill({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.grey.shade600;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
