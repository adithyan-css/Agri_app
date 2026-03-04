import 'package:flutter/material.dart';
import '../../../../data/models/market_model.dart';

class MarketCard extends StatelessWidget {
  final MarketModel market;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? price;
  final String? trend;

  const MarketCard({
    super.key,
    required this.market,
    this.isSelected = false,
    this.onTap,
    this.price,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF10b77f);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.store, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.nameEn,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${market.district}, ${market.state}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    if (market.distanceKm != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${market.distanceKm!.toStringAsFixed(1)} km away',
                        style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
              if (price != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (trend != null) ...[
                      const SizedBox(height: 4),
                      Text(trend!, style: TextStyle(fontSize: 12, color: Colors.blue.shade600)),
                    ],
                  ],
                ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.check_circle, color: primaryColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
