import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            final bool isBest = index == 0; // Simple heuristic for demo
            
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
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${market.district}, ${market.state}'),
                    ],
                  ),
                ),
                trailing: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹45/kg', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('STABLE', style: TextStyle(color: Colors.blue, fontSize: 12)),
                  ],
                ),
                onTap: () {
                  ref.read(selectedMarketProvider.notifier).state = market;
                  Navigator.pop(context);
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
