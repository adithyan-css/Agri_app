import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../config/theme.dart';
import '../../providers/prediction_provider.dart';
import '../../../data/models/prediction_model.dart';
import '../../widgets/common/green_gradient_header.dart';

class PredictionScreen extends ConsumerStatefulWidget {
  final String cropId;
  final String marketId;
  final String cropName;

  const PredictionScreen({
    super.key,
    required this.cropId,
    required this.marketId,
    required this.cropName,
  });

  @override
  ConsumerState<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends ConsumerState<PredictionScreen> {
  String _selectedPeriod = '7D';

  @override
  Widget build(BuildContext context) {
    final forecastAsync = ref.watch(predictionProvider(widget.cropId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: forecastAsync.when(
        data: (ForecastResponse data) {
          final List<PredictionModel> predictions = data.data;
          final List<FlSpot> spots = predictions.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.predictedPrice);
          }).toList();

          final confidencePercent = (data.confidence * 100).toStringAsFixed(0);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: GreenGradientHeader(
                  title: '${widget.cropName} Predictions',
                  subtitle: 'AI விலை முன்னறிவிப்புகள்',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$confidencePercent% CONFIDENCE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ensemble AI summary card
                      _buildEnsembleCard(data),
                      const SizedBox(height: 16),

                      // Chart
                      _buildChartCard(spots),
                      const SizedBox(height: 16),

                      // Day-by-Day Forecast
                      _buildForecastTable(predictions),
                      const SizedBox(height: 16),

                      // AI Model Performance
                      _buildModelPerformance(data),
                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.push(
                                '/alerts/create?cropId=${widget.cropId}&cropName=${widget.cropName}',
                              ),
                              icon: const Icon(Icons.notifications_active),
                              label: const Text('Set Price Alert'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.share),
                              label: const Text('Share Forecast'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Engine Unavailable: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(predictionProvider(widget.cropId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnsembleCard(ForecastResponse data) {
    final isSell = data.recommendation == 'SELL';
    final avgPrice = data.data.isNotEmpty
        ? data.data.map((p) => p.predictedPrice).reduce((a, b) => a + b) / data.data.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ENSEMBLE AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.psychology, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 12),
          Text('${widget.cropName} Price Prediction', style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text(
            '₹${avgPrice.toStringAsFixed(0)} / Quintal',
            style: AppTextStyles.priceText,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ConfidenceChip(
                label: 'Confidence: ${(data.confidence * 100).toStringAsFixed(1)}%',
              ),
              const SizedBox(width: 8),
              _ConfidenceChip(
                label: data.recommendation,
                color: isSell ? AppColors.success : AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Source: ${data.source}',
            style: AppTextStyles.bodySecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<FlSpot> spots) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Forecast & Confidence Band', style: AppTextStyles.heading3),
                Row(
                  children: ['7D', '30D'].map((p) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = p),
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _selectedPeriod == p
                              ? AppColors.primary
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _selectedPeriod == p
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: spots.length >= 2
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                        ],
                        titlesData: const FlTitlesData(
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  )
                : const Center(child: Text('Insufficient data for chart')),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _LegendDot(color: AppColors.primary, label: 'Historical'),
                const SizedBox(width: 16),
                _LegendDot(color: AppColors.accent, label: 'Predicted'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastTable(List<PredictionModel> predictions) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text('Day-by-Day Forecast', style: AppTextStyles.heading3),
              ],
            ),
          ),
          // Header
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Price',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Conf. %',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...predictions.map((p) => _ForecastRow(prediction: p)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildModelPerformance(ForecastResponse data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('AI Analysis', style: AppTextStyles.heading3),
          ),
          _AnalysisRow(
            icon: Icons.trending_up,
            iconColor: Colors.purple,
            title: 'Trend Direction',
            subtitle: 'The overall trend is expected to be ${data.trend}.',
          ),
          _AnalysisRow(
            icon: Icons.info_outline,
            iconColor: Colors.blue,
            title: 'Model Confidence',
            subtitle: 'Prediction confidence is ${(data.confidence * 100).toStringAsFixed(1)}%',
          ),
          _AnalysisRow(
            icon: Icons.psychology,
            iconColor: AppColors.primary,
            title: 'Recommendation',
            subtitle: data.recommendation,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ConfidenceChip extends StatelessWidget {
  final String label;
  final Color? color;
  const _ConfidenceChip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color ?? AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 20, height: 3, color: color),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _ForecastRow extends StatelessWidget {
  final PredictionModel prediction;
  const _ForecastRow({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final dateStr = prediction.targetDate.toString().substring(0, 10);
    final confPercent = (prediction.confidenceScore * 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.background)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(dateStr, style: AppTextStyles.body)),
          Expanded(
            child: Text(
              '₹${prediction.predictedPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: prediction.confidenceScore,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$confPercent%', style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _AnalysisRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.heading3),
                Text(subtitle, style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
