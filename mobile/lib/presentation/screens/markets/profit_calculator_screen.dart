import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../config/theme.dart';
import '../../../data/models/road_profit_model.dart';
import '../../providers/location_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/road_profit_provider.dart';

class TransportProfitScreen extends ConsumerStatefulWidget {
  const TransportProfitScreen({super.key});

  @override
  ConsumerState<TransportProfitScreen> createState() =>
      _TransportProfitScreenState();
}

class _TransportProfitScreenState extends ConsumerState<TransportProfitScreen> {
  double _quantity = 250;
  String? _selectedCropId;
  bool _loading = false;
  List<RoadProfitModel> _results = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    final loc = ref.read(locationProvider);
    if (!loc.hasLocation) {
      ref.read(locationProvider.notifier).getCurrentLocation();
    }
  }

  Future<void> _calculate() async {
    final loc = ref.read(locationProvider);
    if (!loc.hasLocation) {
      setState(() => _error = 'Location not available. Enable GPS and try again.');
      return;
    }
    if (_selectedCropId == null) {
      setState(() => _error = 'Please select a crop first.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });

    try {
      final params = (
        farmerLat: loc.latitude!,
        farmerLng: loc.longitude!,
        cropId: _selectedCropId!,
        quantity: _quantity,
        radiusKm: 100.0,
      );
      final results = await ref.read(roadProfitProvider(params).future);
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to calculate: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locState = ref.watch(locationProvider);
    final cropsAsync = ref.watch(cropListProvider);

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
                    'Road Distance Profit Calculator',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Uses real road distances to find the most profitable markets near you.',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // GPS status
            _buildLocationBanner(locState),
            const SizedBox(height: 16),

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
                  Text('Select Crop & Quantity', style: AppTextStyles.heading2),
                  const SizedBox(height: 16),

                  // Crop dropdown
                  cropsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Failed to load crops: $e'),
                    data: (crops) {
                      if (_selectedCropId == null && crops.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && _selectedCropId == null) {
                            setState(() => _selectedCropId = crops.first.id);
                          }
                        });
                      }
                      return DropdownButtonFormField<String>(
                        value: _selectedCropId,
                        decoration: const InputDecoration(
                          labelText: 'Crop',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.grass),
                        ),
                        items: crops
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.nameEn),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedCropId = v),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Quantity slider
                  _buildSliderRow(
                    label: 'Quantity (kg)',
                    value: _quantity,
                    min: 50,
                    max: 2000,
                    divisions: 39,
                    displayValue: '${_quantity.toInt()} kg',
                    onChanged: (v) => setState(() => _quantity = v),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _calculate,
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.route),
                      label: Text(
                        _loading ? 'Calculating...' : 'Find Best Markets',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],

            // Results
            if (_results.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Top Markets by Profit', style: AppTextStyles.heading2),
              const SizedBox(height: 12),
              ..._results.map((r) => _RoadProfitCard(market: r, quantity: _quantity)),
            ],

            if (_results.isEmpty && !_loading && _error == null) ...[
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Select a crop, enter quantity, and tap "Find Best Markets" to calculate.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBanner(LocationState loc) {
    if (loc.isLoading) {
      return const Row(
        children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8),
          Text('Detecting your location...', style: TextStyle(fontSize: 13)),
        ],
      );
    }
    if (loc.hasLocation) {
      return Row(
        children: [
          const Icon(Icons.gps_fixed, color: Colors.green, size: 16),
          const SizedBox(width: 6),
          Text(
            'GPS: ${loc.latitude!.toStringAsFixed(4)}, ${loc.longitude!.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 13, color: Colors.green),
          ),
        ],
      );
    }
    return Row(
      children: [
        const Icon(Icons.gps_off, color: Colors.orange, size: 16),
        const SizedBox(width: 6),
        const Text('Location unavailable', style: TextStyle(fontSize: 13, color: Colors.orange)),
        const Spacer(),
        TextButton(
          onPressed: () => ref.read(locationProvider.notifier).getCurrentLocation(),
          child: const Text('Retry'),
        ),
      ],
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

class _RoadProfitCard extends StatelessWidget {
  final RoadProfitModel market;
  final double quantity;
  const _RoadProfitCard({required this.market, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: market.isBestMarket ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: market.isBestMarket
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    market.marketName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (market.isBestMarket)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('BEST',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${market.district}, ${market.state}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            // Stats row
            Row(
              children: [
                _StatChip(Icons.route, '${market.roadDistanceKm} km'),
                const SizedBox(width: 8),
                _StatChip(Icons.access_time, market.formattedTravelTime),
                const SizedBox(width: 8),
                _StatChip(Icons.currency_rupee, '${market.pricePerKg.toStringAsFixed(1)}/kg'),
              ],
            ),
            const Divider(height: 20),
            // Profit row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ProfitStat('Revenue', '${market.grossRevenue.toStringAsFixed(0)}'),
                _ProfitStat('Transport', '${market.transportCost.toStringAsFixed(0)}'),
                _ProfitStat(
                  'Net Profit',
                  market.formattedProfit,
                  color: market.isProfitable ? Colors.green.shade700 : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ProfitStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _ProfitStat(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
