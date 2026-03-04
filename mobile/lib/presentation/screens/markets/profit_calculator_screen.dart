import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../config/theme.dart';

class TransportProfitScreen extends ConsumerStatefulWidget {
  const TransportProfitScreen({super.key});

  @override
  ConsumerState<TransportProfitScreen> createState() =>
      _TransportProfitScreenState();
}

class _TransportProfitScreenState extends ConsumerState<TransportProfitScreen> {
  double _quantity = 250;
  double _transportCost = 150;
  double _currentPrice = 35.50;
  double _predictedPrice = 42.00;
  bool _calculated = false;

  double get _revenue => _quantity * _predictedPrice;
  double get _profit =>
      _revenue - _transportCost - (_quantity * _currentPrice);
  double get _profitPerKg => _quantity > 0 ? _profit / _quantity : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transport Profit Calculator'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AI Suggestion banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology, color: AppColors.accent, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'AI RECOMMENDATION',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Calculate Your Profit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Enter your crop details below to estimate transport cost and net profit.',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Calculator form
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calculate Your Profit', style: AppTextStyles.heading2),
                  const SizedBox(height: 20),

                  // Quantity slider
                  _buildSliderRow(
                    label: 'Quantity (kg)',
                    value: _quantity,
                    min: 50,
                    max: 1000,
                    divisions: 19,
                    displayValue: '${_quantity.toInt()} kg',
                    onChanged: (v) => setState(() {
                      _quantity = v;
                      _calculated = false;
                    }),
                  ),
                  const Divider(height: 24),

                  // Current Price
                  _buildSliderRow(
                    label: 'Current Price (₹/kg)',
                    value: _currentPrice,
                    min: 10,
                    max: 80,
                    divisions: 70,
                    displayValue: '₹${_currentPrice.toStringAsFixed(1)}',
                    onChanged: (v) => setState(() {
                      _currentPrice = v;
                      _calculated = false;
                    }),
                  ),
                  const Divider(height: 24),

                  // Transport Cost
                  _buildSliderRow(
                    label: 'Transport Cost (₹)',
                    value: _transportCost,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    displayValue: '₹${_transportCost.toInt()}',
                    onChanged: (v) => setState(() {
                      _transportCost = v;
                      _calculated = false;
                    }),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _calculated = true),
                      icon: const Icon(Icons.calculate),
                      label: const Text(
                        'Calculate Profit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Result
            if (_calculated) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Estimated Profit',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${_profit.toStringAsFixed(0)} ${_profit >= 0 ? '✅' : '❌'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ResultStat(
                          label: 'Profit/kg',
                          value: '₹${_profitPerKg.toStringAsFixed(2)}',
                        ),
                        _ResultStat(
                          label: 'Total Revenue',
                          value: '₹${_revenue.toStringAsFixed(0)}',
                        ),
                        _ResultStat(
                          label: 'Transport',
                          value: '₹${_transportCost.toInt()}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Best Nearby Markets',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Use Nearby Markets screen to compare profit across markets.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.heading3),
            Text(
              displayValue,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  const _ResultStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _MarketOption extends StatelessWidget {
  final String name;
  final String distance;
  final String price;
  final bool isTop;
  const _MarketOption({
    required this.name,
    required this.distance,
    required this.price,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.store, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  distance,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
