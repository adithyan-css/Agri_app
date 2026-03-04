import 'package:flutter/material.dart';

class RecommendationBanner extends StatelessWidget {
  final String recommendation; // 'SELL' or 'WAIT'
  final String message;
  final double? confidence;

  const RecommendationBanner({
    super.key,
    required this.recommendation,
    required this.message,
    this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final isSell = recommendation == 'SELL';
    final bgColor = isSell ? Colors.green.shade50 : Colors.orange.shade50;
    final borderColor = isSell ? Colors.green.shade200 : Colors.orange.shade200;
    final textColor = isSell ? Colors.green.shade800 : Colors.orange.shade800;
    final icon = isSell ? Icons.sell : Icons.timer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isSell ? Colors.green : Colors.orange).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isSell ? Colors.green : Colors.orange, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      recommendation,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (confidence != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isSell ? Colors.green : Colors.orange).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(confidence! * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(fontSize: 13, color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
