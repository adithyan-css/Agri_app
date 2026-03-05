import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/market_provider.dart';
import '../../providers/prediction_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/ai_recommendation_banner.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/market_card.dart' as widgets;
import '../../providers/weather_provider.dart';
import '../alerts/alerts_screen.dart' show alertsProvider;
import '../../../data/models/alert_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Kick off GPS location fetch on first load
    Future.microtask(() {
      ref.read(locationProvider.notifier).getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cropsAsync = ref.watch(cropListProvider);
    final marketsAsync = ref.watch(marketListProvider);
    final lang = ref.watch(languageProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, lang, user),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 4),

            // Selected market bar
            _buildSelectedMarketBar(),
            const SizedBox(height: 8),

            // AI Recommendation — live data from sellOrWaitProvider
            _buildAiRecommendation(cropsAsync),

            // Active Price Alerts preview
            _buildAlertsPreview(context, ref),

            // Today's Crop Prices
            SectionHeader(
              title: "Today's Crop Prices",
              actionLabel: 'See all',
              onAction: () => context.go('/prices'),
            ),
            _buildPricesRow(cropsAsync),

            const SizedBox(height: 8),
            // Nearby Markets
            SectionHeader(
              title: 'Nearby Markets',
              actionLabel: 'See all',
              onAction: () => context.go('/markets'),
            ),
            _buildMarketsList(marketsAsync, lang),
            const SizedBox(height: 16),

            // Quick Access — Weather, Transport, Bookings
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Quick Access',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  )),
            ),
            const SizedBox(height: 8),
            _buildQuickAccessRow(context, ref),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildHeader(BuildContext context, Locale lang, dynamic user) {
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
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user?.displayName ?? 'Farmer'}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(user?.preferredLanguage == 'ta' ? 'தமிழ்நாடு' : 'Tamil Nadu',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          ref.read(locationProvider.notifier).getCurrentLocation();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Refreshing location...')),
                          );
                        },
                        child: const Text('[Change]',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  // Language toggle
                  GestureDetector(
                    onTap: () {
                      final current = ref.read(languageProvider);
                      ref.read(languageProvider.notifier).setLanguage(
                          current.languageCode == 'en' ? 'ta' : 'en');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        lang.languageCode == 'en' ? 'EN | Tamil' : 'English | தமிழ்',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    onPressed: () => context.go('/alerts'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats row — dynamic from providers
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final marketsAsync = ref.watch(marketListProvider);
    final cropsAsync = ref.watch(cropListProvider);
    final marketCount = marketsAsync.valueOrNull?.length ?? 0;
    final cropCount = cropsAsync.valueOrNull?.length ?? 0;
    return Row(
      children: [
        _StatChip(label: 'Crops', value: '$cropCount', sublabel: 'Available'),
        const SizedBox(width: 8),
        _StatChip(label: 'Markets', value: '$marketCount', sublabel: 'Tamil Nadu'),
        const SizedBox(width: 8),
        const _StatChip(label: 'AI Models', value: '4', sublabel: 'Ensemble'),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search crops, markets, prices...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
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

  Widget _buildSelectedMarketBar() {
    final selectedMarket = ref.watch(selectedMarketProvider);
    if (selectedMarket == null) {
      return GestureDetector(
        onTap: () => context.push('/select-market?changing=true'),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.store, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Select your market (mandi) for prices',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.textSecondary),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () => context.push('/select-market?changing=true'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.chipGreen,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.store, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedMarket.nameEn,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    selectedMarket.district,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Change',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.swap_horiz, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildAiRecommendation(AsyncValue<dynamic> cropsAsync) {
    return cropsAsync.when(
      data: (crops) {
        if (crops.isEmpty) {
          return const AiRecommendationBanner(
            recommendation: 'NO DATA',
            detail: 'No crops available yet.',
          );
        }
        final firstCrop = crops.first;
        final market = ref.watch(selectedMarketProvider);
        final marketsAsync = ref.watch(marketListProvider);
        final firstMarket = marketsAsync.valueOrNull?.isNotEmpty == true
            ? marketsAsync.valueOrNull!.first
            : null;
        final marketId = market?.id ?? firstMarket?.id ?? 'default';
        final recAsync = ref.watch(
          sellOrWaitProvider((cropId: firstCrop.id, marketId: marketId)),
        );
        return recAsync.when(
          data: (rec) {
            if (rec == null) {
              return const AiRecommendationBanner(
                recommendation: 'SELL or WAIT',
                detail: 'Select a crop to see AI-powered buy/sell recommendations.',
              );
            }
            final actionColor = rec.action == 'SELL'
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFFFF8E1);
            return AiRecommendationBanner(
              recommendation: rec.action,
              detail: rec.reason,
              color: actionColor,
            );
          },
          loading: () => const AiRecommendationBanner(
            recommendation: 'Analyzing...',
            detail: 'AI is analyzing prices for you.',
          ),
          error: (_, __) => const AiRecommendationBanner(
            recommendation: 'SELL or WAIT',
            detail: 'Select a crop to see AI-powered buy/sell recommendations.',
          ),
        );
      },
      loading: () => const AiRecommendationBanner(
        recommendation: 'Loading...',
        detail: 'Fetching crop data...',
      ),
      error: (_, __) => const AiRecommendationBanner(
        recommendation: 'SELL or WAIT',
        detail: 'Could not load crop data.',
      ),
    );
  }

  Widget _buildAlertsPreview(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);
    return alertsAsync.when(
      data: (alerts) {
        final active = alerts.where((a) => a.isActive).toList();
        if (active.isEmpty) return const SizedBox.shrink();
        final display = active.take(2).toList();
        return Column(
          children: [
            SectionHeader(
              title: 'Price Alerts',
              actionLabel: 'See all',
              onAction: () => context.go('/alerts'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: display.map((alert) {
                  final icon = alert.isTriggered
                      ? Icons.notifications_active
                      : Icons.notifications_outlined;
                  final iconColor = alert.isTriggered
                      ? Colors.orange
                      : AppColors.primary;
                  final subtitle = alert.condition == 'above'
                      ? 'Above ₹${alert.targetPrice.toStringAsFixed(0)}'
                      : 'Below ₹${alert.targetPrice.toStringAsFixed(0)}';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: alert.isTriggered
                          ? const Color(0xFFFFF3E0)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: iconColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alert.cropName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${alert.marketName} · $subtitle',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (alert.isTriggered)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Triggered',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPricesRow(AsyncValue<dynamic> cropsAsync) {
    return cropsAsync.when(
      data: (crops) {
        var filtered = crops as List;
        if (_searchQuery.isNotEmpty) {
          filtered = filtered.where((c) =>
            c.nameEn.toLowerCase().contains(_searchQuery) ||
            c.nameTa.contains(_searchQuery)).toList();
        }
        if (filtered.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No crop data available')),
          );
        }
        // Show up to 3 crops in compact row
        final displayCrops = filtered.take(3).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: displayCrops.map<Widget>((crop) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/crop-detail/${crop.id}?name=${Uri.encodeComponent(crop.nameEn)}'),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.eco,
                            color: AppColors.primary, size: 22),
                        const SizedBox(height: 6),
                        Text(crop.nameEn,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        const Text('View price',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Center(
          child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      )),
      error: (err, _) => Center(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          err.toString().contains('Connection refused') ? 'Offline – showing cached data' : 'Could not load crops',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      )),
    );
  }

  Widget _buildQuickAccessRow(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(locationProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _QuickAccessCard(
            icon: Icons.cloud_outlined,
            label: 'Weather',
            color: const Color(0xFF3B82F6),
            onTap: () {
              final lat = loc.latitude ?? 11.0168;
              final lon = loc.longitude ?? 76.9558;
              final name = Uri.encodeComponent('My Location');
              context.push('/weather?lat=$lat&lon=$lon&name=$name');
            },
          ),
          const SizedBox(width: 10),
          _QuickAccessCard(
            icon: Icons.local_shipping_outlined,
            label: 'Transport',
            color: const Color(0xFFF59E0B),
            onTap: () => context.push('/transport'),
          ),
          const SizedBox(width: 10),
          _QuickAccessCard(
            icon: Icons.receipt_long_outlined,
            label: 'Bookings',
            color: const Color(0xFF8B5CF6),
            onTap: () => context.push('/bookings'),
          ),
          const SizedBox(width: 10),
          _QuickAccessCard(
            icon: Icons.auto_graph,
            label: 'AI Analysis',
            color: const Color(0xFFEF4444),
            onTap: () => context.push('/predictions'),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketsList(AsyncValue<dynamic> marketsAsync, Locale lang) {
    return marketsAsync.when(
      data: (markets) {
        var filtered = markets as List;
        if (_searchQuery.isNotEmpty) {
          filtered = filtered.where((m) =>
            m.nameEn.toLowerCase().contains(_searchQuery) ||
            m.district.toLowerCase().contains(_searchQuery)).toList();
        }
        if (filtered.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No markets found')),
          );
        }
        return Column(
          children: filtered.take(3).map<Widget>((market) {
            return widgets.MarketCard(
              name: market.nameEn,
              location: market.district,
              distance: (market.distanceKm != null && market.distanceKm! > 0)
                  ? market.distanceKm
                  : null,
              price: market.avgPrice > 0 ? market.avgPrice : null,
              isOpen: market.isOpen ?? market.isActive,
              openHours: market.openHours ?? 'Hours N/A',
              showBestPrice: markets.indexOf(market) == 0,
              onTap: () => context.push('/market-detail/${market.id}'),
            );
          }).toList(),
        );
      },
      loading: () => const Center(
          child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      )),
      error: (err, _) => Center(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          err.toString().contains('Connection refused') ? 'Offline – showing cached data' : 'Could not load markets',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      )),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;

  const _StatChip(
      {required this.label, required this.value, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: Colors.white70)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text(sublabel,
                style:
                    const TextStyle(fontSize: 10, color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}
