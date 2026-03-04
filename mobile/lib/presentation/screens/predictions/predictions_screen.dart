import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../config/theme.dart';
import '../../providers/crop_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/common/green_gradient_header.dart';
import '../../widgets/common/bottom_nav_bar.dart';

class PredictionsScreen extends ConsumerWidget {
  const PredictionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropsAsync = ref.watch(cropListProvider);
    final selectedMarket = ref.watch(selectedMarketProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenGradientHeader(
            title: 'AI Predictions',
            subtitle: 'AI விலை முன்னறிவிப்புகள்',
            trailing: GestureDetector(
              onTap: () => context.push('/markets'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.store, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      selectedMarket?.nameEn ?? 'Select Market',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                // Market selection warning
                if (selectedMarket == null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Please select a market first for accurate predictions.',
                            style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/markets'),
                          child: const Text('Select', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: cropsAsync.when(
              data: (crops) {
                if (crops.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_graph, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No crops available for prediction'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: crops.length,
                  itemBuilder: (context, index) {
                    final crop = crops[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                      child: InkWell(
                        onTap: () {
                          final marketId = selectedMarket?.id ?? 'default';
                          context.push(
                            '/predictions/${crop.id}/$marketId?name=${crop.nameEn}',
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getCropColor(crop.nameEn).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.eco,
                                  color: _getCropColor(crop.nameEn),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      crop.nameEn,
                                      style: AppTextStyles.heading3,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      crop.nameTa,
                                      style: AppTextStyles.bodySecondary,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.chipGreen,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        crop.category ?? 'Vegetable',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.auto_graph,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '7-day forecast',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $err'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(cropListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Color _getCropColor(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'tomato':
        return Colors.red;
      case 'onion':
        return Colors.purple;
      case 'potato':
        return Colors.brown;
      case 'rice':
        return Colors.amber;
      case 'wheat':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }
}
