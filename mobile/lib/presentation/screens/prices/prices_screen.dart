import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../config/theme.dart';
import '../../providers/crop_provider.dart';
import '../../providers/market_provider.dart';
import '../../providers/prediction_provider.dart';
import '../../widgets/common/green_gradient_header.dart';
import '../../widgets/common/price_card.dart' as widgets;
import '../../widgets/common/ai_recommendation_banner.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/bottom_nav_bar.dart';

class PricesScreen extends ConsumerStatefulWidget {
  const PricesScreen({super.key});

  @override
  ConsumerState<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends ConsumerState<PricesScreen> {
  String _selectedCrop = '';

  String _getTamilName(String crop) {
    switch (crop.toLowerCase()) {
      case 'tomato':
        return 'தக்காளி';
      case 'onion':
        return 'வெங்காயம்';
      case 'potato':
        return 'உருளைக்கிழங்கு';
      case 'rice':
        return 'அரிசி';
      case 'wheat':
        return 'கோதுமை';
      default:
        return crop;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cropsAsync = ref.watch(cropListProvider);
    final selectedMarket = ref.watch(selectedMarketProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GreenGradientHeader(
            title: "Today's Prices",
            subtitle: 'Live from API',
          ),

          // Crop tabs — driven by actual crop list
          cropsAsync.when(
            data: (crops) {
              if (_selectedCrop.isEmpty && crops.isNotEmpty) {
                // Auto-select the first crop
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _selectedCrop.isEmpty) {
                    setState(() => _selectedCrop = crops.first.nameEn);
                  }
                });
              }
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: crops.map((crop) {
                      final isSelected = _selectedCrop == crop.nameEn;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCrop = crop.nameEn),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              crop.nameEn,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              children: [
                // Price overview card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCrop.isNotEmpty ? _selectedCrop : 'Select a crop',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          _selectedCrop.isNotEmpty ? _getTamilName(_selectedCrop) : '',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap a crop above',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // AI Recommendation — placeholder until crop selected
                const AiRecommendationBanner(
                  recommendation: 'SELECT A CROP',
                  detail: 'Choose a crop above to see AI-powered sell/wait recommendations.',
                ),

                SectionHeader(
                  title: 'Price Trend',
                  actionLabel: 'View Full Prices',
                  onAction: () => context.push('/predictions'),
                ),

                // Trend chart — will show real data when crop detail is viewed
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Tap a crop to view detailed price trends and 7-day forecast',
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                // All crop prices
                const SectionHeader(title: 'All Crop Prices'),
                cropsAsync.when(
                  data: (crops) => Column(
                    children: crops.map((crop) {
                      return widgets.PriceCard(
                        cropName: crop.nameEn,
                        cropNameTamil: crop.nameTa,
                        price: 0.0,
                        change: 0.0,
                        onTap: () => setState(() => _selectedCrop = crop.nameEn),
                      );
                    }).toList(),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: Text(
                      'Could not load prices. Pull to refresh.',
                      style: TextStyle(color: Colors.grey.shade500),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

class _PriceStat extends StatelessWidget {
  final String label;
  final String value;
  const _PriceStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final String label;
  final double value;
  final bool highlight;
  const _BarChart({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 80 * value,
          decoration: BoxDecoration(
            color: highlight
                ? AppColors.primary
                : AppColors.primaryLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
