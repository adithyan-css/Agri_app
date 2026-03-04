import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../config/theme.dart';

class PriceCard extends StatelessWidget {
  final String cropName;
  final String? cropNameTamil;
  final double price;
  final double change;
  final String unit;
  final String? updatedAt;
  final VoidCallback? onTap;

  const PriceCard({
    super.key,
    required this.cropName,
    this.cropNameTamil,
    required this.price,
    required this.change,
    this.unit = 'kg',
    this.updatedAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.chipGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.eco, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cropName,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  if (cropNameTamil != null)
                    Text(cropNameTamil!,
                        style: AppTextStyles.caption),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${price.toStringAsFixed(2)}/$unit',
                  style: AppTextStyles.priceSmall,
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPositive ? AppColors.chipGreen : AppColors.chipRed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          isPositive ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
