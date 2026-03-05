import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../providers/crop_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/common/green_gradient_header.dart';
import '../../widgets/common/price_card.dart' as widgets;
import '../../widgets/common/section_header.dart';
import '../../widgets/common/bottom_nav_bar.dart';

class PricesScreen extends ConsumerStatefulWidget {
  const PricesScreen({super.key});

  @override
  ConsumerState<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends ConsumerState<PricesScreen> {
  String _selectedCrop = '';

  @override
  Widget build(BuildContext context) {
    final pricesAsync = ref.watch(allCropPricesProvider);
    final selectedMarket = ref.watch(selectedMarketProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenGradientHeader(
            title: "Today's Prices",
            subtitle: selectedMarket != null
                ? selectedMarket.nameEn
                : 'Select a market',
            trailing: IconButton(
              icon: const Icon(Icons.swap_horiz, color: Colors.white),
              onPressed: () => context.push('/select-market?changing=true'),
            ),
          ),

          // Market selection bar
          if (selectedMarket == null)
            GestureDetector(
              onTap: () => context.push('/select-market?changing=true'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.accent.withOpacity(0.12),
                child: Row(
                  children: [
                    Icon(Icons.store, color: AppColors.accent, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'No market selected — tap to choose your mandi',
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
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.chipGreen,
              child: Row(
                children: [
                  const Icon(Icons.store, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${selectedMarket.nameEn} • ${selectedMarket.district}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/select-market?changing=true'),
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: pricesAsync.when(
              data: (prices) {
                if (_selectedCrop.isEmpty && prices.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _selectedCrop.isEmpty) {
                      setState(() => _selectedCrop = prices.first['nameEn']?.toString() ?? '');
                    }
                  });
                }

                // Find selected crop's price data
                final selectedData = prices.where(
                  (p) => p['nameEn']?.toString() == _selectedCrop,
                ).toList();
                final selectedPrice = selectedData.isNotEmpty
                    ? (selectedData.first['price'] as num?)?.toDouble() ?? 0.0
                    : 0.0;
                final selectedSource = selectedData.isNotEmpty
                    ? selectedData.first['source']?.toString() ?? ''
                    : '';
                final selectedTamil = selectedData.isNotEmpty
                    ? selectedData.first['nameTa']?.toString() ?? ''
                    : '';

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allCropPricesProvider);
                  },
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      // Crop filter chips
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: prices.map((p) {
                              final name = p['nameEn']?.toString() ?? '';
                              final isSelected = _selectedCrop == name;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedCrop = name),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 13,
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

                      // Price overview card for selected crop
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
                              if (selectedTamil.isNotEmpty)
                                Text(
                                  selectedTamil,
                                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                selectedPrice > 0
                                    ? '₹${selectedPrice.toStringAsFixed(2)}/kg'
                                    : 'No price data',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (selectedSource == 'nearby_market')
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Price from nearby market',
                                    style: TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // All crop prices
                      const SectionHeader(title: 'All Crop Prices'),
                      ...prices.map((p) {
                        final name = p['nameEn']?.toString() ?? '';
                        final tamil = p['nameTa']?.toString();
                        final price = (p['price'] as num?)?.toDouble() ?? 0.0;
                        final cropId = p['cropId']?.toString() ?? '';
                        final source = p['source']?.toString() ?? '';
                        return widgets.PriceCard(
                          cropName: name,
                          cropNameTamil: tamil,
                          price: price,
                          change: 0.0,
                          updatedAt: source == 'nearby_market' ? 'Nearby market' : null,
                          onTap: () {
                            setState(() => _selectedCrop = name);
                            context.push('/crop-detail/$cropId?name=${Uri.encodeComponent(name)}');
                          },
                        );
                      }),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load prices',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(allCropPricesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
