import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../data/models/prediction_model.dart';
import 'package:intl/intl.dart';

class PredictionChart extends StatelessWidget {
  final List<PredictionModel> predictions;
  final double height;

  const PredictionChart({
    super.key,
    required this.predictions,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No prediction data available')),
      );
    }

    final spots = predictions.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.predictedPrice);
    }).toList();

    final upperBound = predictions.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.upperBound);
    }).toList();

    final lowerBound = predictions.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.lowerBound);
    }).toList();

    final dayLabels = predictions.map((p) => DateFormat('E').format(p.targetDate)).toList();

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            // Upper bound (dashed)
            LineChartBarData(
              spots: upperBound,
              isCurved: true,
              color: Colors.green.withOpacity(0.3),
              barWidth: 1,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5],
            ),
            // Lower bound (dashed)
            LineChartBarData(
              spots: lowerBound,
              isCurved: true,
              color: Colors.green.withOpacity(0.3),
              barWidth: 1,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5],
            ),
            // Main prediction line
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF10b77f),
              barWidth: 4,
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
                  if (idx >= 0 && idx < dayLabels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(dayLabels[idx], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    );
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
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final idx = spot.spotIndex;
                  if (spot.barIndex == 2 && idx < predictions.length) {
                    final p = predictions[idx];
                    return LineTooltipItem(
                      '₹${p.predictedPrice.toStringAsFixed(2)}\n${DateFormat('MMM d').format(p.targetDate)}',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
