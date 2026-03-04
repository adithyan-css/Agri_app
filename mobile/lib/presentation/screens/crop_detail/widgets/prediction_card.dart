import 'package:flutter/material.dart';
import '../../../../data/models/prediction_model.dart';

class PredictionCard extends StatelessWidget {
  final ForecastResponse forecast;

  const PredictionCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final isSell = forecast.recommendation == 'SELL';
    final bgColor = isSell ? Colors.green.shade50 : Colors.orange.shade50;
    final borderColor = isSell ? Colors.green.shade200 : Colors.orange.shade200;
    final textColor = isSell ? Colors.green.shade800 : Colors.orange.shade800;

    final nextDay = forecast.data.isNotEmpty ? forecast.data.first : null;

    return Card(
      color: bgColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isSell ? Icons.sell : Icons.timer,
                      color: isSell ? Colors.green : Colors.orange,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      forecast.recommendation,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isSell ? Colors.green : Colors.orange).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(forecast.confidence * 100).toStringAsFixed(0)}% confident',
                    style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(Icons.trending_up, 'Trend: ${forecast.trend}', textColor),
                const SizedBox(width: 12),
                _infoChip(Icons.model_training, forecast.source, textColor),
              ],
            ),
            if (nextDay != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Next day prediction:', style: TextStyle(color: textColor)),
                  Text(
                    '₹${nextDay.predictedPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
