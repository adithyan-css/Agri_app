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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
            const SizedBox(height: 12),

            // AI Recommendation — live data from sellOrWaitProvider
            _buildAiRecommendation(cropsAsync),

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
                        onTap: () {},
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

          // Stats row — market count comes from API, others show as dynamic
          Row(
            children: [
              const _StatChip(label: "Today's Avg", value: '--', sublabel: 'Select crop'),
              const SizedBox(width: 8),
              const _StatChip(label: 'Markets', value: '--', sublabel: 'Nearby'),
              const SizedBox(width: 8),
              const _StatChip(label: 'AI Models', value: '4', sublabel: 'Ensemble'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search crops, markets, prices...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: const Icon(Icons.mic, color: AppColors.primary),
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
        final marketId = market?.id ?? 'default';
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

  Widget _buildPricesRow(AsyncValue<dynamic> cropsAsync) {
    return cropsAsync.when(
      data: (crops) {
        if (crops.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No crop data available')),
          );
        }
        // Show up to 3 crops in compact row
        final displayCrops = crops.take(3).toList();
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
        child: Text('Error: $err'),
      )),
    );
  }

  Widget _buildMarketsList(AsyncValue<dynamic> marketsAsync, Locale lang) {
    return marketsAsync.when(
      data: (markets) {
        if (markets.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No markets found')),
          );
        }
        return Column(
          children: markets.take(3).map<Widget>((market) {
            return widgets.MarketCard(
              name: market.nameEn,
              location: market.district,
              distance: market.distanceKm ?? 0.0,
              price: 0.0,
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
        child: Text('Error: $err'),
      )),
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
