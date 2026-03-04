import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../providers/crop_provider.dart';
import '../../providers/market_provider.dart';
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
  Widget build(BuildContext context) {
    final cropsAsync = ref.watch(cropListProvider);
    final marketsAsync = ref.watch(marketListProvider);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, lang),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 12),

            // AI Recommendation
            const AiRecommendationBanner(
              recommendation: 'WAIT 3 DAYS',
              detail:
                  'Prices expected to surge by 15% due to incoming rain and high local demand.',
            ),

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

  Widget _buildHeader(BuildContext context, Locale lang) {
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
                  const Text(
                    'Welcome, Farmer',
                    style: TextStyle(
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
                      const Text('Coimbatore, TN',
                          style: TextStyle(
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

          // Stats row
          Row(
            children: [
              _StatChip(label: "Today's Avg", value: '₹38.5/kg', sublabel: '↑ 2.1%'),
              const SizedBox(width: 8),
              _StatChip(label: 'Markets Open', value: '8/12', sublabel: 'Nearby'),
              const SizedBox(width: 8),
              _StatChip(label: 'AI Confidence', value: '94%', sublabel: '5 Models'),
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
                  onTap: () => context.go('/crop-detail/${crop.id}'),
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
                        const Text('₹38/kg',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                        const Text('+5%',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.success,
                                fontWeight: FontWeight.bold)),
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
              price: 38.00,
              isOpen: market.isActive,
              openHours: '4:00 AM - 12:00 PM',
              showBestPrice: markets.indexOf(market) == 0,
              onTap: () => context.go('/market-detail/${market.id}'),
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
