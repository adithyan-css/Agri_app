import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/market_model.dart';
import '../../providers/market_provider.dart';
import '../../providers/location_provider.dart';

class MarketSelectorScreen extends ConsumerStatefulWidget {
  /// If true, shows a back button instead of skip; used when changing market from settings.
  final bool isChanging;

  const MarketSelectorScreen({super.key, this.isChanging = false});

  @override
  ConsumerState<MarketSelectorScreen> createState() =>
      _MarketSelectorScreenState();
}

class _MarketSelectorScreenState extends ConsumerState<MarketSelectorScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();
  MarketModel? _pendingSelection;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  List<_MarketWithDistance> _buildSortedList(
    List<MarketModel> markets,
    double? userLat,
    double? userLng,
  ) {
    List<_MarketWithDistance> enriched = markets.map((m) {
      double? distance = m.distanceKm;
      if (distance == null &&
          userLat != null &&
          userLng != null &&
          m.lat != null &&
          m.lng != null) {
        distance = _haversineDistance(userLat, userLng, m.lat!, m.lng!);
      }
      return _MarketWithDistance(market: m, distanceKm: distance);
    }).toList();

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      enriched = enriched.where((e) {
        final m = e.market;
        return m.nameEn.toLowerCase().contains(q) ||
            m.nameTa.toLowerCase().contains(q) ||
            m.district.toLowerCase().contains(q);
      }).toList();
    }

    // Sort by distance (nearest first)
    enriched.sort((a, b) => (a.distanceKm ?? double.infinity)
        .compareTo(b.distanceKm ?? double.infinity));
    return enriched;
  }

  void _confirmSelection() {
    if (_pendingSelection == null) return;
    ref.read(selectedMarketProvider.notifier).selectMarket(_pendingSelection!);
    if (widget.isChanging) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketsAsync = ref.watch(marketListProvider);
    final locationState = ref.watch(locationProvider);
    final currentSelection = ref.watch(selectedMarketProvider);
    _pendingSelection ??= currentSelection;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          _buildSearchBar(),
          _buildLocationBar(locationState),
          Expanded(child: _buildMarketList(marketsAsync, locationState)),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.isChanging)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (widget.isChanging) const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Select Your Market',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!widget.isChanging)
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.isChanging
                ? 'Choose a different market to view prices'
                : 'Choose the mandi nearest to you for accurate prices',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search markets by name or district...',
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
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildLocationBar(LocationState locationState) {
    if (locationState.isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: AppColors.primary.withOpacity(0.08),
        child: const Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Getting your location...',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    if (locationState.hasLocation) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: AppColors.chipGreen,
        child: Row(
          children: [
            const Icon(Icons.my_location, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            const Text(
              'Location active • Sorted by distance',
              style: TextStyle(fontSize: 12, color: AppColors.primary),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () =>
                  ref.read(locationProvider.notifier).getCurrentLocation(),
              child:
                  const Icon(Icons.refresh, size: 16, color: AppColors.primary),
            ),
          ],
        ),
      );
    }
    if (locationState.error != null) {
      return GestureDetector(
        onTap: () => ref.read(locationProvider.notifier).getCurrentLocation(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.orange.shade50,
          child: Row(
            children: [
              Icon(Icons.location_off,
                  size: 14, color: Colors.orange.shade700),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Location unavailable • Tap to retry',
                  style:
                      TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMarketList(
    AsyncValue<List<MarketModel>> marketsAsync,
    LocationState locationState,
  ) {
    return marketsAsync.when(
      data: (markets) {
        final sorted = _buildSortedList(
          markets,
          locationState.latitude,
          locationState.longitude,
        );
        if (sorted.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront_outlined,
                    size: 48,
                    color: AppColors.textSecondary.withOpacity(0.5)),
                const SizedBox(height: 12),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No markets match "$_searchQuery"'
                      : 'No markets available',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final item = sorted[index];
            final isSelected = _pendingSelection?.id == item.market.id;
            return _MarketSelectionCard(
              market: item.market,
              distanceKm: item.distanceKm,
              isSelected: isSelected,
              onTap: () => setState(() => _pendingSelection = item.market),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            const Text('Failed to load markets'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => ref.invalidate(marketListProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    final hasSelection = _pendingSelection != null;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_pendingSelection != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.store, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _pendingSelection!.nameEn,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _pendingSelection!.district,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: hasSelection ? _confirmSelection : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.divider,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                hasSelection ? 'Confirm Selection' : 'Select a market',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketSelectionCard extends StatelessWidget {
  final MarketModel market;
  final double? distanceKm;
  final bool isSelected;
  final VoidCallback onTap;

  const _MarketSelectionCard({
    required this.market,
    this.distanceKm,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chipGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 8,
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
              ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.chipGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.store,
                color: isSelected ? AppColors.primary : AppColors.primaryLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    market.nameEn,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    market.nameTa,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 12,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Text(
                        market.district,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (market.openHours != null &&
                          market.openHours!.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.access_time,
                            size: 12,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Text(
                          market.openHours!,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Distance + selection indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (distanceKm != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.chipGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${distanceKm!.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketWithDistance {
  final MarketModel market;
  final double? distanceKm;
  _MarketWithDistance({required this.market, this.distanceKm});
}
