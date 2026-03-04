import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/colors.dart';
import '../../providers/prediction_provider.dart';
import '../../../data/models/recommendation_model.dart';

const _kPrimary = Color(0xFF10B77F);
const _kBgLight = Color(0xFFF6F8F7);
const _kCardBg = Color(0xFFFFFFFF);
const _kTextPrimary = Color(0xFF0F172A);
const _kTextSecondary = Color(0xFF64748B);

/// AI Recommendation Screen
///
/// Shows the sell-or-wait recommendation from the prediction engine.
/// Requires [cropId], [marketId], and [cropName] to fetch real data.
class AiRecommendationScreen extends ConsumerWidget {
  final String cropId;
  final String marketId;
  final String cropName;

  const AiRecommendationScreen({
    super.key,
    required this.cropId,
    required this.marketId,
    this.cropName = 'Crop',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recAsync = ref.watch(
      sellOrWaitProvider((cropId: cropId, marketId: marketId)),
    );

    return Scaffold(
      backgroundColor: _kBgLight,
      appBar: AppBar(
        backgroundColor: _kBgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AI Analysis — $cropName',
          style: const TextStyle(
            color: _kTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: recAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(
                  'Failed to load recommendation',
                  style: TextStyle(color: _kTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(e.toString(), style: const TextStyle(color: _kTextSecondary, fontSize: 13)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(
                    sellOrWaitProvider((cropId: cropId, marketId: marketId)),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        data: (rec) {
          if (rec == null) {
            return const Center(
              child: Text('No recommendation available. Select a market first.'),
            );
          }
          return _RecommendationBody(rec: rec);
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Body with real data
// ──────────────────────────────────────────────────────
class _RecommendationBody extends StatelessWidget {
  final RecommendationModel rec;
  const _RecommendationBody({required this.rec});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecommendationCard(rec: rec),
          const SizedBox(height: 16),
          _OptimalActionCard(rec: rec),
          const SizedBox(height: 24),
          if (rec.predictions.isNotEmpty) ...[
            _PriceTrendSection(rec: rec),
            const SizedBox(height: 24),
          ],
          _MarketFactorsSection(rec: rec),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// AI Recommendation Card — green gradient
// ──────────────────────────────────────────────────────
class _RecommendationCard extends StatelessWidget {
  final RecommendationModel rec;
  const _RecommendationCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimary, Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'AI RECOMMENDATION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rec.confidencePercent,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Recommended Action',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                rec.action,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: Colors.white24),
              const SizedBox(height: 16),

              // Prices
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Market Price',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: '₹${rec.currentPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: '/kg',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Predicted Peak',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: '₹${rec.predictedPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFFA7F3D0),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: '/kg',
                              style: TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Optimal Action Card
// ──────────────────────────────────────────────────────
class _OptimalActionCard extends StatelessWidget {
  final RecommendationModel rec;
  const _OptimalActionCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kPrimary.withOpacity(0.08),
        border: Border.all(color: _kPrimary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              rec.isSell ? Icons.sell : Icons.schedule,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.isSell ? 'SELL NOW' : 'WAIT FOR BETTER PRICE',
                  style: const TextStyle(
                    color: _kTextSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  rec.reason,
                  style: const TextStyle(color: _kPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            rec.trend == 'UP'
                ? Icons.trending_up
                : rec.trend == 'DOWN'
                    ? Icons.trending_down
                    : Icons.trending_flat,
            color: _kPrimary,
            size: 24,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Predicted Price Trend (chart)
// ──────────────────────────────────────────────────────
class _PriceTrendSection extends StatelessWidget {
  final RecommendationModel rec;
  const _PriceTrendSection({required this.rec});

  @override
  Widget build(BuildContext context) {
    final predictions = rec.predictions;
    final prices = predictions.map((p) => p.price).toList();
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final change = prices.isNotEmpty && prices.first > 0
        ? ((prices.last - prices.first) / prices.first * 100)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Predicted Price Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kTextPrimary),
            ),
            Text(
              'Next ${predictions.length} Days',
              style: const TextStyle(color: _kPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '₹${maxPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: _kTextPrimary),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: change >= 0 ? _kPrimary : Colors.redAccent,
                    size: 14,
                  ),
                  Text(
                    '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: change >= 0 ? _kPrimary : Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= predictions.length) return const SizedBox();
                            // Show abbreviated date
                            final label = predictions[idx].date.length >= 10
                                ? predictions[idx].date.substring(5) // MM-DD
                                : predictions[idx].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                label,
                                style: const TextStyle(color: _kTextSecondary, fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: prices.asMap().entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value))
                            .toList(),
                        isCurved: true,
                        curveSmoothness: 0.4,
                        color: _kPrimary,
                        barWidth: 2.5,
                        dotData: FlDotData(
                          show: true,
                          checkToShowDot: (spot, barData) => spot.x == (prices.length - 1).toDouble(),
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 5,
                            color: _kPrimary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [_kPrimary.withOpacity(0.25), _kPrimary.withOpacity(0.0)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    minY: minPrice - (maxPrice - minPrice) * 0.2,
                    maxY: maxPrice + (maxPrice - minPrice) * 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────
// Market Factors
// ──────────────────────────────────────────────────────
class _MarketFactorsSection extends StatelessWidget {
  final RecommendationModel rec;
  const _MarketFactorsSection({required this.rec});

  @override
  Widget build(BuildContext context) {
    String supplyLabel;
    Color supplyColor;
    if (rec.trend == 'UP') {
      supplyLabel = 'DECREASING';
      supplyColor = const Color(0xFFF59E0B);
    } else if (rec.trend == 'DOWN') {
      supplyLabel = 'INCREASING';
      supplyColor = Colors.redAccent;
    } else {
      supplyLabel = 'STABLE';
      supplyColor = _kPrimary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Market Factors',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kTextPrimary),
        ),
        const SizedBox(height: 12),
        _FactorTile(
          icon: Icons.show_chart,
          label: 'Price Trend',
          value: rec.trend,
          valueColor: rec.trend == 'UP' ? _kPrimary : (rec.trend == 'DOWN' ? Colors.redAccent : const Color(0xFFF59E0B)),
        ),
        const SizedBox(height: 10),
        _FactorTile(
          icon: Icons.inventory_2_outlined,
          label: 'Market Supply',
          value: supplyLabel,
          valueColor: supplyColor,
        ),
        const SizedBox(height: 10),
        _FactorTile(
          icon: Icons.monetization_on_outlined,
          label: 'Potential Gain',
          value: '₹${rec.potentialGain.toStringAsFixed(2)}/kg',
          valueColor: rec.potentialGain > 0 ? _kPrimary : Colors.redAccent,
        ),
      ],
    );
  }
}

class _FactorTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _FactorTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _kPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(color: _kTextPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
