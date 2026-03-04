import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/crop_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../../core/utils/formatters.dart';

class CropDetailScreen extends ConsumerWidget {
  final String cropId;

  const CropDetailScreen({super.key, required this.cropId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropList = ref.watch(cropListProvider);
    final latestPrice = ref.watch(latestPriceProvider(cropId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: cropList.when(
          data: (crops) {
            final crop = crops.firstWhere(
              (c) => c.id.toString() == cropId,
              orElse: () => crops.first,
            );
            return Text(crop.nameEn);
          },
          loading: () => const Text('Crop Details'),
          error: (_, __) => const Text('Crop Details'),
        ),
      ),
      body: cropList.when(
        data: (crops) {
          final crop = crops.firstWhere(
            (c) => c.id.toString() == cropId,
            orElse: () => crops.first,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop header card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            crop.nameEn.substring(0, 1).toUpperCase(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crop.nameEn,
                                style: theme.textTheme.titleLarge,
                              ),
                              if (crop.nameTa.isNotEmpty)
                                Text(
                                  crop.nameTa,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(crop.category ?? 'General'),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Latest Price
                latestPrice.when(
                  data: (priceData) {
                    final priceValue = (priceData['price'] as num?)?.toDouble() ?? 0.0;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.currency_rupee),
                        title: const Text('Latest Price'),
                        subtitle: Text(Formatters.price(priceValue)),
                        trailing: ElevatedButton.icon(
                          onPressed: () {
                            final markets = ref.read(marketListProvider);
                            markets.whenData((m) {
                              if (m.isNotEmpty) {
                                context.push(
                                  '/predictions/$cropId/${m.first.id}?name=${crop.nameEn}',
                                );
                              }
                            });
                          },
                          icon: const Icon(Icons.trending_up, size: 18),
                          label: const Text('Predict'),
                        ),
                      ),
                    );
                  },
                  loading: () => const Card(
                    child: ListTile(
                      leading: Icon(Icons.currency_rupee),
                      title: Text('Latest Price'),
                      subtitle: LinearProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.currency_rupee),
                      title: const Text('Latest Price'),
                      subtitle: Text('Error: $e'),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Price trend section
                Text(
                  'Price Trend (30 days)',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Container(
                    height: 250,
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.show_chart, size: 48, color: theme.colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(
                            'View predictions for detailed charts',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          FilledButton.tonal(
                            onPressed: () {
                              final markets = ref.read(marketListProvider);
                              markets.whenData((m) {
                                if (m.isNotEmpty) {
                                  context.push(
                                    '/predictions/$cropId/${m.first.id}?name=${crop.nameEn}',
                                  );
                                }
                              });
                            },
                            child: const Text('View Predictions'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Market comparison section
                Text(
                  'Available Markets',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ref.watch(marketListProvider).when(
                  data: (markets) => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: markets.length,
                    itemBuilder: (context, index) {
                      final market = markets[index];
                      return Card(
                        child: ListTile(
                          title: Text(market.nameEn),
                          subtitle: Text('${market.district}, ${market.state}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push(
                              '/predictions/$cropId/${market.id}?name=${crop.nameEn}',
                            );
                          },
                        ),
                      );
                    },
                  ),
                  loading: () => const LoadingIndicator(),
                  error: (e, _) => AppErrorWidget(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(marketListProvider),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(cropListProvider),
        ),
      ),
    );
  }
}
