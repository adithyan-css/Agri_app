import 'package:flutter/material.dart';

class MarketComparisonTable extends StatelessWidget {
  final List<Map<String, dynamic>> marketPrices;

  const MarketComparisonTable({
    super.key,
    required this.marketPrices,
  });

  @override
  Widget build(BuildContext context) {
    if (marketPrices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No market data available for comparison.')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Comparison',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
              },
              children: [
                _headerRow(),
                ...marketPrices.asMap().entries.map((e) =>
                    _dataRow(
                      e.value['market'] ?? 'Unknown',
                      e.value['price']?.toString() ?? '-',
                      e.value['trend'] ?? 'STABLE',
                      isEven: e.key.isEven,
                      isBest: e.key == 0,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TableRow _headerRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade100),
      children: const [
        Padding(
          padding: EdgeInsets.all(12),
          child: Text('Market', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Padding(
          padding: EdgeInsets.all(12),
          child: Text('Price (₹/kg)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Padding(
          padding: EdgeInsets.all(12),
          child: Text('Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }

  TableRow _dataRow(String market, String price, String trend,
      {bool isEven = false, bool isBest = false}) {
    final trendColor = trend == 'UP'
        ? Colors.green
        : trend == 'DOWN'
            ? Colors.red
            : Colors.blue;

    return TableRow(
      decoration: BoxDecoration(
        color: isBest
            ? Colors.green.withOpacity(0.05)
            : (isEven ? Colors.grey.shade50 : Colors.white),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(market, style: const TextStyle(fontSize: 13)),
              if (isBest) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Best', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('₹$price', style: TextStyle(fontSize: 13, fontWeight: isBest ? FontWeight.bold : FontWeight.normal)),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(trend, style: TextStyle(fontSize: 13, color: trendColor, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
