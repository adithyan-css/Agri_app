import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/market_model.dart';
import '../../providers/market_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/common/green_gradient_header.dart';
import '../../widgets/common/market_card.dart' as widgets;
import '../../widgets/common/bottom_nav_bar.dart';

class MarketsScreen extends ConsumerStatefulWidget {
  const MarketsScreen({super.key});

  @override
  ConsumerState<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends ConsumerState<MarketsScreen> {
  String _activeFilter = 'Nearest First';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<String> _filters = [
    'Nearest First',
    'Best Price',
    'Under 10km',
    'Open Now',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Calculate distance between two lat/lng pairs (Haversine formula) in km.
  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth radius in km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  /// Apply search query and active filter to the raw markets list.
  List<MarketModel> _applyFilters(
    List<MarketModel> markets,
    double? userLat,
    double? userLng,
  ) {
    // 1. Compute client-side distance if we have user location and market has no distanceKm
    List<_MarketWithDistance> enriched = markets.map((m) {
      double? distance = m.distanceKm;
      if (distance == null && userLat != null && userLng != null && m.lat != null && m.lng != null) {
        distance = _haversineDistance(userLat, userLng, m.lat!, m.lng!);
      }
      return _MarketWithDistance(market: m, computedDistanceKm: distance);
    }).toList();

    // 2. Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      enriched = enriched.where((e) {
        final m = e.market;
        return m.nameEn.toLowerCase().contains(q) ||
            m.nameTa.toLowerCase().contains(q) ||
            m.district.toLowerCase().contains(q) ||
            m.state.toLowerCase().contains(q);
      }).toList();
    }

    // 3. Apply active filter chip
    switch (_activeFilter) {
      case 'Nearest First':
        enriched.sort((a, b) =>
            (a.computedDistanceKm ?? double.infinity)
                .compareTo(b.computedDistanceKm ?? double.infinity));
        break;
      case 'Best Price':
        // Sort by distance as proxy (closer → cheaper transport)
        enriched.sort((a, b) =>
            (a.computedDistanceKm ?? double.infinity)
                .compareTo(b.computedDistanceKm ?? double.infinity));
        break;
      case 'Under 10km':
        enriched = enriched
            .where((e) => e.computedDistanceKm != null && e.computedDistanceKm! <= 10.0)
            .toList();
        enriched.sort((a, b) =>
            (a.computedDistanceKm ?? 0).compareTo(b.computedDistanceKm ?? 0));
        break;
      case 'Open Now':
        enriched = enriched
            .where((e) => e.market.isOpen == true || e.market.isActive)
            .toList();
        break;
    }

    return enriched.map((e) => e.market).toList();
  }

  @override
  Widget build(BuildContext context) {
    final marketsAsync = ref.watch(marketListProvider);
    final location = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenGradientHeader(
            title: 'Markets / சந்தைகள்',
            subtitle: marketsAsync.when(
              data: (m) {
                final filtered = _applyFilters(m, location.latitude, location.longitude);
                return '${filtered.length} Markets found';
              },
              loading: () => 'Loading...',
              error: (_, __) => 'Error loading markets',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.map_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search for markets nearby...',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.my_location, color: AppColors.primary),
                        onPressed: () {
                          ref.read(locationProvider.notifier).getCurrentLocation();
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final isActive = _activeFilter == _filters[i];
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = _filters[i]),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isActive ? AppColors.primary : AppColors.divider,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _filters[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Market list
          Expanded(
            child: marketsAsync.when(
              data: (markets) {
                final filtered = _applyFilters(markets, location.latitude, location.longitude);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront_outlined,
                            size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No markets match "$_searchQuery"'
                              : _activeFilter == 'Under 10km'
                                  ? 'No markets within 10 km.\nTry a different filter.'
                                  : 'No markets available',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final market = filtered[i];
                    // Recompute distance for display
                    double displayDistance = market.distanceKm ?? 0.0;
                    if (displayDistance == 0.0 &&
                        location.hasLocation &&
                        market.lat != null &&
                        market.lng != null) {
                      displayDistance = _haversineDistance(
                          location.latitude!, location.longitude!, market.lat!, market.lng!);
                    }
                    return widgets.MarketCard(
                      name: market.nameEn,
                      location: market.district,
                      distance: displayDistance,
                      price: 0.0,
                      isOpen: market.isOpen ?? market.isActive,
                      openHours: market.openHours ?? 'Hours N/A',
                      showBestPrice: i == 0 && _activeFilter == 'Best Price',
                      onTap: () {
                        ref.read(selectedMarketProvider.notifier).state =
                            market;
                        context.push('/market-detail/${market.id}');
                      },
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Failed to load: $err'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(marketListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}

/// Helper class to pair a market with its computed distance.
class _MarketWithDistance {
  final MarketModel market;
  final double? computedDistanceKm;

  _MarketWithDistance({required this.market, this.computedDistanceKm});
}
