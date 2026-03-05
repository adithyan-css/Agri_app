import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/alert_repository.dart';
import '../../providers/crop_provider.dart';
import '../../providers/market_provider.dart';
import '../../../data/models/crop_price_model.dart';
import '../../../data/models/market_model.dart';
import 'alerts_screen.dart';

class CreateAlertScreen extends ConsumerStatefulWidget {
  final String? initialCropId;
  final String? initialCropName;

  const CreateAlertScreen({
    super.key,
    this.initialCropId,
    this.initialCropName,
  });

  @override
  ConsumerState<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends ConsumerState<CreateAlertScreen> {
  final _priceController = TextEditingController();
  String _condition = 'above';
  CropModel? _selectedCrop;
  MarketModel? _selectedMarket;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cropsAsync = ref.watch(cropListProvider);
    final marketsAsync = ref.watch(marketListProvider);
    const primaryColor = Color(0xFF10b77f);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Price Alert')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get notified when a crop price reaches your target.',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Crop selector
            Text('Select Crop', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            cropsAsync.when(
              data: (crops) => DropdownButtonFormField<CropModel>(
                value: _selectedCrop ?? crops.where((c) => c.id == widget.initialCropId).firstOrNull,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Choose a crop',
                ),
                items: crops.map((crop) => DropdownMenuItem(value: crop, child: Text(crop.nameEn, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (crop) => setState(() => _selectedCrop = crop),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Failed to load crops'),
            ),
            const SizedBox(height: 20),

            // Market selector
            Text('Select Market', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            marketsAsync.when(
              data: (markets) => DropdownButtonFormField<MarketModel>(
                value: _selectedMarket,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Choose a market',
                ),
                items: markets.map((m) => DropdownMenuItem(value: m, child: Text(m.nameEn, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (market) => setState(() => _selectedMarket = market),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Failed to load markets'),
            ),
            const SizedBox(height: 20),

            // Condition
            Text('Alert Condition', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _conditionChip('above', 'Price goes above', Icons.arrow_upward, Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _conditionChip('below', 'Price goes below', Icons.arrow_downward, Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Target price
            Text('Target Price (₹/kg)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '₹ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'Enter target price',
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Create button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createAlert,
                icon: const Icon(Icons.notifications_active),
                label: Text(_isLoading ? 'Creating...' : 'Create Alert',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _conditionChip(String value, String label, IconData icon, Color color) {
    final selected = _condition == value;
    return InkWell(
      onTap: () => setState(() => _condition = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? color : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Flexible(child: Text(label, style: TextStyle(fontSize: 13, color: selected ? color : Colors.grey.shade600))),
          ],
        ),
      ),
    );
  }

  void _createAlert() async {
    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }
    if (_selectedCrop == null || _selectedMarket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a crop and market')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(alertRepositoryProvider);
      await repo.createAlert(
        cropId: _selectedCrop!.id,
        marketId: _selectedMarket!.id,
        targetPrice: price,
        condition: _condition,
      );
      ref.invalidate(alertsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert created successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final isOffline = e.toString().contains('Connection refused') ||
            e.toString().contains('connection error') ||
            e.toString().contains('SocketException');
        final msg = isOffline
            ? 'No internet connection. Please connect and try again.'
            : 'Failed to create alert. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
