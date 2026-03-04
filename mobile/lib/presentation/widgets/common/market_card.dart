import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../config/theme.dart';

class MarketCard extends StatelessWidget {
  final String name;
  final String location;
  final double distance;
  final double? price;
  final bool isOpen;
  final String openHours;
  final bool showBestPrice;
  final VoidCallback? onTap;

  const MarketCard({
    super.key,
    required this.name,
    required this.location,
    required this.distance,
    this.price,
    this.isOpen = true,
    this.openHours = '',
    this.showBestPrice = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.store, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showBestPrice) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('BEST PRICE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text('$location • ${distance.toStringAsFixed(1)} km',
                          style: AppTextStyles.caption),
                    ],
                  ),
                  if (openHours.isNotEmpty)
                    Text(openHours, style: AppTextStyles.caption),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isOpen ? AppColors.chipGreen : AppColors.chipRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOpen ? 'Open' : 'Closed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isOpen ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
                if (price != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '₹${price!.toStringAsFixed(2)}/kg',
                    style: AppTextStyles.priceSmall,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
