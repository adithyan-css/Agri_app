import 'package:flutter/material.dart';

class TransportProfitCalculatorWidget extends StatefulWidget {
  final double? initialDistance;
  final double? defaultPricePerKg;

  const TransportProfitCalculatorWidget({
    super.key,
    this.initialDistance,
    this.defaultPricePerKg,
  });

  @override
  State<TransportProfitCalculatorWidget> createState() => _TransportProfitCalculatorWidgetState();
}

class _TransportProfitCalculatorWidgetState extends State<TransportProfitCalculatorWidget> {
  late TextEditingController _volumeController;
  late TextEditingController _distanceController;
  late TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    _volumeController = TextEditingController(text: '100');
    _distanceController = TextEditingController(text: widget.initialDistance?.toString() ?? '50');
    _rateController = TextEditingController(text: '2');
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _distanceController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _volumeController,
          decoration: const InputDecoration(
            labelText: 'Volume (kg)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.scale),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _distanceController,
          decoration: const InputDecoration(
            labelText: 'Distance to Market (km)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.add_road),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _rateController,
          decoration: const InputDecoration(
            labelText: 'Transport Rate (₹/km)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.currency_rupee),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        _buildResult(),
      ],
    );
  }

  Widget _buildResult() {
    final double vol = double.tryParse(_volumeController.text) ?? 0;
    final double dist = double.tryParse(_distanceController.text) ?? 0;
    final double rate = double.tryParse(_rateController.text) ?? 0;
    final double pricePerKg = widget.defaultPricePerKg ?? 45.0;

    final double gross = vol * pricePerKg;
    final double cost = dist * rate;
    final double net = gross - cost;
    final bool profitable = net > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: profitable ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: profitable ? Colors.green.shade200 : Colors.red.shade200),
      ),
      child: Column(
        children: [
          _resultRow('Gross Revenue', '₹${gross.toStringAsFixed(2)}'),
          _resultRow('Transport Cost', '- ₹${cost.toStringAsFixed(2)}'),
          const Divider(),
          _resultRow(
            'Net Profit',
            '₹${net.toStringAsFixed(2)}',
            isBold: true,
            color: profitable ? Colors.green.shade800 : Colors.red.shade800,
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}
