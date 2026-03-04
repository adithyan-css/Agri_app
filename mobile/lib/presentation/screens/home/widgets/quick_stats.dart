import 'package:flutter/material.dart';

class QuickStats extends StatelessWidget {
  final int totalCrops;
  final int totalMarkets;
  final String topCrop;
  final double topPrice;

  const QuickStats({
    super.key,
    required this.totalCrops,
    required this.totalMarkets,
    required this.topCrop,
    required this.topPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, Icons.grass, '$totalCrops', 'Crops', Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, Icons.store, '$totalMarkets', 'Markets', Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, Icons.trending_up, '₹${topPrice.toStringAsFixed(0)}', topCrop, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
