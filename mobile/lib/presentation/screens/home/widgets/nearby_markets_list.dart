import 'package:flutter/material.dart';
import '../../../../data/models/market_model.dart';

class NearbyMarketsList extends StatelessWidget {
  final List<MarketModel> markets;
  final void Function(MarketModel market)? onMarketTap;

  const NearbyMarketsList({
    super.key,
    required this.markets,
    this.onMarketTap,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No nearby markets found.', style: TextStyle(color: Colors.grey)),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: markets.length,
        itemBuilder: (context, index) {
          final market = markets[index];
          return Container(
            width: 160,
            margin: EdgeInsets.only(right: 12, left: index == 0 ? 0 : 0),
            child: InkWell(
              onTap: () => onMarketTap?.call(market),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store, color: Colors.green.shade400, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      market.nameEn,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      market.district,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    if (market.distanceKm != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${market.distanceKm!.toStringAsFixed(1)} km',
                        style: TextStyle(fontSize: 11, color: Colors.green.shade600, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
