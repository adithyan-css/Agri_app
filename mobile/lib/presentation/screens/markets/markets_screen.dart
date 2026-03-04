import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
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
  Widget build(BuildContext context) {
    final marketsAsync = ref.watch(marketListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenGradientHeader(
            title: 'Markets / சந்தைகள்',
            subtitle: marketsAsync.when(
              data: (m) => '${m.length} Markets found',
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
              decoration: InputDecoration(
                hintText: 'Search for markets nearby...',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon:
                    const Icon(Icons.my_location, color: AppColors.primary),
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
                if (markets.isEmpty) {
                  return const Center(child: Text('No markets available'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: markets.length,
                  itemBuilder: (_, i) {
                    final market = markets[i];
                    return widgets.MarketCard(
                      name: market.nameEn,
                      location: market.district,
                      distance: market.distanceKm ?? 0.0,
                      price: 38.00,
                      isOpen: market.isActive,
                      openHours: '4:00 AM - 12:00 PM',
                      showBestPrice: i == 0,
                      onTap: () {
                        ref.read(selectedMarketProvider.notifier).state =
                            market;
                        context.go('/market-detail/${market.id}');
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
