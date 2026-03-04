import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/crop_price_model.dart';
import '../../../data/models/market_model.dart';
import '../../providers/crop_provider.dart';
import '../../providers/market_provider.dart';
import '../../providers/transport_provider.dart';

const _kPrimary = Color(0xFF10B77F);
const _kBgLight = Color(0xFFF6F8F7);
const _kTextPrimary = Color(0xFF0F172A);
const _kTextSecondary = Color(0xFF64748B);
const _kWarningBg = Color(0xFFFFF8E7);
const _kWarningBorder = Color(0xFFF6AE2D);
const _kSuccessBg = Color(0xFFEBFFF6);

class BookTransportScreen extends ConsumerStatefulWidget {
  final String? truckId;
  const BookTransportScreen({super.key, this.truckId});

  @override
  ConsumerState<BookTransportScreen> createState() =>
      _BookTransportScreenState();
}

class _BookTransportScreenState extends ConsumerState<BookTransportScreen> {
  CropModel? _selectedCrop;
  MarketModel? _selectedMarket;
  DateTime? _bookingDate;
  final _qtyController = TextEditingController(text: '500');

  bool _isBooking = false;
  String? _bookingError;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: _kPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _bookingDate = picked);
  }

  Future<void> _confirmBooking() async {
    if (widget.truckId == null || _bookingDate == null) return;

    setState(() {
      _isBooking = true;
      _bookingError = null;
    });

    try {
      await ref.read(
        bookTruckProvider(
          (
            truckId: widget.truckId!,
            bookingDate: _bookingDate!.toIso8601String(),
          ),
        ).future,
      );

      if (!mounted) return;

      // Refresh bookings list
      ref.invalidate(myBookingsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking confirmed!'),
          backgroundColor: _kPrimary,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _bookingError = e.toString());
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cropsAsync = ref.watch(cropListProvider);
    final marketsAsync = ref.watch(marketListProvider);

    return Scaffold(
      backgroundColor: _kBgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Transport',
          style: TextStyle(
            color: _kTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Map placeholder ──
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Grid lines
                  CustomPaint(
                    size: const Size(double.infinity, 180),
                    painter: _MapGridPainter(),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _kPrimary.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: _kPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Route Preview',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Crop selector ──
            const _SectionLabel('Crop'),
            const SizedBox(height: 6),
            cropsAsync.when(
              loading: () =>
                  const LinearProgressIndicator(color: _kPrimary),
              error: (e, _) => Text('Failed to load crops',
                  style: TextStyle(color: Colors.red.shade400, fontSize: 13)),
              data: (crops) => _DropdownCard<CropModel>(
                value: _selectedCrop,
                hint: 'Select Crop',
                items: crops,
                labelBuilder: (c) => c.nameEn,
                onChanged: (c) => setState(() => _selectedCrop = c),
              ),
            ),
            const SizedBox(height: 16),

            // ── Market selector ──
            const _SectionLabel('Destination Market'),
            const SizedBox(height: 6),
            marketsAsync.when(
              loading: () =>
                  const LinearProgressIndicator(color: _kPrimary),
              error: (e, _) => Text('Failed to load markets',
                  style: TextStyle(color: Colors.red.shade400, fontSize: 13)),
              data: (markets) => _DropdownCard<MarketModel>(
                value: _selectedMarket,
                hint: 'Select Market',
                items: markets,
                labelBuilder: (m) => '${m.nameEn} – ${m.district}',
                onChanged: (m) => setState(() => _selectedMarket = m),
              ),
            ),
            const SizedBox(height: 16),

            // ── Quantity ──
            const _SectionLabel('Quantity (kg)'),
            const SizedBox(height: 6),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Enter quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kPrimary),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Date picker ──
            const _SectionLabel('Booking Date'),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _bookingDate != null
                            ? DateFormat('EEE, MMM d, yyyy')
                                .format(_bookingDate!)
                            : 'Select date',
                        style: TextStyle(
                          color: _bookingDate != null
                              ? _kTextPrimary
                              : _kTextSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_today_outlined,
                        size: 20, color: _kTextSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Cost estimate ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kWarningBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kWarningBorder.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: _kWarningBorder, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cost is calculated upon confirmation based on distance and truck rate.',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Error message ──
            if (_bookingError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _bookingError!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Confirm button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canBook && !_isBooking ? _confirmBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isBooking
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Confirm Booking',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  bool get _canBook =>
      widget.truckId != null &&
      _selectedCrop != null &&
      _selectedMarket != null &&
      _bookingDate != null &&
      _qtyController.text.isNotEmpty;
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: _kTextPrimary,
      ),
    );
  }
}

class _DropdownCard<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;

  const _DropdownCard({
    required this.value,
    required this.hint,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: _kTextSecondary)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: _kTextSecondary),
          items: items
              .map((item) =>
                  DropdownMenuItem(value: item, child: Text(labelBuilder(item))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
