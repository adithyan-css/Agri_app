import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/market_provider.dart';

class NearbyMarketsScreen extends ConsumerWidget {
  const NearbyMarketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketsAsync = ref.watch(marketListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Markets')),
      body: marketsAsync.when(
        data: (markets) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: markets.length,
          itemBuilder: (context, index) {
            final market = markets[index];
            final bool isBest = index == 0;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: isBest ? 4 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isBest 
                  ? const BorderSide(color: Color(0xFF10b77f), width: 2) 
                  : BorderSide.none,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(market.nameEn, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${market.district}, ${market.state}'),
                        ],
                      ),
                      if (market.distanceKm != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${market.distanceKm!.toStringAsFixed(1)} km away',
                          style: TextStyle(fontSize: 12, color: Colors.green.shade600, fontWeight: FontWeight.w600),
                        ),
                      ],
                      if (market.openHours != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(market.openHours!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isBest)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10b77f),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('BEST', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      market.statusLabel,
                      style: TextStyle(
                        color: market.isOpen == true ? Colors.green : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  ref.read(selectedMarketProvider.notifier).state = market;
                  context.push('/market-detail/${market.id}');
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
