import 'package:flutter/material.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../core/constants/colors.dart';

/// AI Sell or Wait Recommendation Card
/// ─────────────────────────────────────
/// A visual decision card that tells farmers whether to SELL now
/// or WAIT for better prices, based on AI predictions.
///
/// Displays:
///   - Large SELL/WAIT action badge
///   - Current price vs predicted price comparison
///   - Trend indicator (UP/DOWN/STABLE)
///   - Expected profit if waiting
///   - AI confidence level
///   - Human-readable reason
///
/// Usage:
///   RecommendationCard(recommendation: recommendationModel)
class RecommendationCard extends StatelessWidget {
  final RecommendationModel recommendation;
  final VoidCallback? onViewDetails;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Choose colors based on the recommendation action
    final isSell = recommendation.isSell;
    final primaryColor = isSell ? AppColors.success : AppColors.accent;
    final bgColor = isSell ? AppColors.sellBg : AppColors.waitBg;
    final textColor = isSell ? AppColors.sellText : AppColors.waitText;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top Section: AI Badge + Action ──
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // "AI RECOMMENDATION" label
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.psychology, color: primaryColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'AI RECOMMENDATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Large action badge (SELL or WAIT)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSell ? Icons.sell : Icons.hourglass_top,
                      color: primaryColor,
                      size: 36,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      recommendation.action,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Reason text
                Text(
                  recommendation.reason,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──
          Divider(
            height: 1,
            color: primaryColor.withOpacity(0.2),
          ),

          // ── Bottom Section: Stats Row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Current Price
                _StatColumn(
                  label: 'Current',
                  value: '₹${recommendation.currentPrice.toStringAsFixed(1)}',
                  sublabel: '/kg',
                  color: textColor,
                ),
                _VerticalDivider(color: primaryColor),

                // Predicted Price
                _StatColumn(
                  label: 'Predicted',
                  value: '₹${recommendation.predictedPrice.toStringAsFixed(1)}',
                  sublabel: '/kg',
                  color: textColor,
                ),
                _VerticalDivider(color: primaryColor),

                // Trend
                _StatColumn(
                  label: 'Trend',
                  value: recommendation.trend,
                  icon: _getTrendIcon(recommendation.trend),
                  color: textColor,
                ),
                _VerticalDivider(color: primaryColor),

                // Confidence
                _StatColumn(
                  label: 'Confidence',
                  value: recommendation.confidencePercent,
                  color: textColor,
                ),
              ],
            ),
          ),

          // ── Expected Profit Banner (only shown for WAIT) ──
          if (recommendation.isWait && recommendation.potentialGain > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_up, color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Potential gain: +₹${recommendation.potentialGain.toStringAsFixed(2)}/kg',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),

          // View details button
          if (onViewDetails != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 8),
              child: TextButton(
                onPressed: onViewDetails,
                child: Text(
                  'View Full Forecast →',
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'UP':
        return Icons.trending_up;
      case 'DOWN':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }
}

/// A single stat column used in the bottom stats row
class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final String? sublabel;
  final IconData? icon;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    this.sublabel,
    this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.6)),
          ),
          const SizedBox(height: 4),
          if (icon != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: color)),
              ],
            )
          else
            Text(value,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          if (sublabel != null)
            Text(sublabel!,
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.5))),
        ],
      ),
    );
  }
}

/// A thin vertical divider between stat columns
class _VerticalDivider extends StatelessWidget {
  final Color color;
  const _VerticalDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: color.withOpacity(0.15),
    );
  }
}
