import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../config/theme.dart';
import '../../providers/crop_provider.dart';
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
  String _selectedCrop = 'Tomato';

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

  String _getPrice(String crop) {
    switch (crop.toLowerCase()) {
      case 'tomato':
        return '₹38.00/kg';
      case 'onion':
        return '₹30.00/kg';
      case 'potato':
        return '₹24.00/kg';
      case 'rice':
        return '₹42.00/kg';
      case 'wheat':
        return '₹28.00/kg';
      default:
        return '₹0.00/kg';
    }
  }

  double _getPriceValue(String crop) {
    switch (crop.toLowerCase()) {
      case 'tomato':
        return 38.0;
      case 'onion':
        return 30.0;
      case 'potato':
        return 24.0;
      case 'rice':
        return 42.0;
      case 'wheat':
        return 28.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cropsAsync = ref.watch(cropListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GreenGradientHeader(
            title: "Today's Prices",
            subtitle: 'Updated: 2h ago',
          ),

          // Crop tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['Tomato', 'Onion', 'Potato', 'Rice', 'Wheat'].map((crop) {
                  final isSelected = _selectedCrop == crop;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCrop = crop),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          crop,
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
                          _selectedCrop,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          _getTamilName(_selectedCrop),
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getPrice(_selectedCrop),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            _PriceStat(label: 'Daily Min/Max', value: '₹30 — ₹38'),
                            SizedBox(width: 20),
                            _PriceStat(label: 'Yesterday', value: '₹32.00'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // AI Recommendation
                const AiRecommendationBanner(
                  recommendation: 'WAIT 3 DAYS',
                  detail: 'Tomato price expected to rise 15% based on seasonal trends & market supply.',
                ),

                SectionHeader(
                  title: 'Price Trend',
                  actionLabel: 'View Full Prices',
                  onAction: () => context.push('/predictions'),
                ),

                // Trend chart placeholder
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 160,
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
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Price Forecast', style: AppTextStyles.heading3),
                              Text(
                                '7-day forecast with 85% accuracy',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _BarChart(label: 'Oct 20', value: 0.6),
                                _BarChart(label: 'Oct 22', value: 0.7),
                                _BarChart(label: 'Today', value: 0.85, highlight: true),
                                _BarChart(label: 'Oct 26', value: 0.75),
                                _BarChart(label: 'Oct 28', value: 0.9),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                        price: _getPriceValue(crop.nameEn),
                        change: 5.2,
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
                    child: Center(child: Text('Error: $err')),
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
