import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/crop_provider.dart';
import '../../providers/market_provider.dart';
import '../../providers/prediction_provider.dart';
import 'widgets/price_trend_chart.dart';
import 'widgets/prediction_card.dart';
import 'widgets/market_comparison_table.dart';

class CropDetailScreen extends ConsumerWidget {
  final String cropId;
  final String cropName;

  const CropDetailScreen({
    super.key,
    required this.cropId,
    required this.cropName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMarket = ref.watch(selectedMarketProvider);
    final forecastAsync = ref.watch(predictionProvider(cropId));

    return Scaffold(
      appBar: AppBar(
        title: Text(cropName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Set Price Alert',
            onPressed: () => context.push('/alerts/create?cropId=$cropId&cropName=$cropName'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current price card
            _buildCurrentPriceCard(context, ref),
            const SizedBox(height: 24),

            // AI Prediction card
            forecastAsync.when(
              data: (forecast) => forecast != null
                  ? PredictionCard(forecast: forecast)
                  : const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Prediction data not available'),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Prediction unavailable: $err'),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Price trend chart
            _buildPriceTrendSection(context, ref),
            const SizedBox(height: 24),

            // Market comparison table
            _buildMarketComparison(context),
            const SizedBox(height: 24),

            // Navigate to full prediction screen
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  final marketId = selectedMarket?.id ?? 'default';
                  context.push('/predictions/$cropId/$marketId?name=$cropName');
                },
                icon: const Icon(Icons.auto_graph),
                label: const Text('View Full 7-Day Forecast', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10b77f),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPriceCard(BuildContext context, WidgetRef ref) {
    final priceAsync = ref.watch(latestPriceProvider(cropId));
    final selectedMarket = ref.watch(selectedMarketProvider);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: priceAsync.when(
          data: (data) {
            final price = data['price'] ?? 0.0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cropName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          selectedMarket?.nameEn ?? 'Select a market',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹$price',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10b77f),
                              ),
                        ),
                        const Text('per kg', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Price unavailable'),
        ),
      ),
    );
  }

  Widget _buildPriceTrendSection(BuildContext context, WidgetRef ref) {
    final selectedMarket = ref.watch(selectedMarketProvider);
    final marketId = selectedMarket?.id ?? 'default';
    final historyAsync = ref.watch(priceHistoryProvider((cropId: cropId, marketId: marketId, days: 30)));

    return historyAsync.when(
      data: (historyData) {
        if (historyData.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No price history available'),
            ),
          );
        }
        return PriceTrendChart(historyData: historyData);
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Price trend unavailable: $err'),
        ),
      ),
    );
  }

  Widget _buildMarketComparison(BuildContext context) {
    // TODO: Wire to real API — fetch prices across all markets for this crop
    final marketPrices = <Map<String, String>>[];

    if (marketPrices.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Market comparison data loading...'),
        ),
      );
    }

    return MarketComparisonTable(marketPrices: marketPrices);
  }
}
