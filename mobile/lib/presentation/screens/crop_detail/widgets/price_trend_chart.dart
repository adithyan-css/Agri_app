import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PriceTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> historyData;
  final double height;

  const PriceTrendChart({
    super.key,
    required this.historyData,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    if (historyData.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No price history available')),
      );
    }

    final spots = historyData.asMap().entries.map((e) {
      final price = (e.value['price'] is num)
          ? (e.value['price'] as num).toDouble()
          : double.tryParse(e.value['price'].toString()) ?? 0.0;
      return FlSpot(e.key.toDouble(), price);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price Trend', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: const Color(0xFF10b77f),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF10b77f).withOpacity(0.1),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < historyData.length) {
                        final date = historyData[idx]['date']?.toString() ?? '';
                        // Show abbreviated date
                        final parts = date.split('-');
                        if (parts.length >= 2) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('${parts.last}', style: const TextStyle(fontSize: 10)),
                          );
                        }
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text('₹${value.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey));
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}
