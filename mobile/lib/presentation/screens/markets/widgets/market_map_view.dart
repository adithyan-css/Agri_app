import 'package:flutter/material.dart';

/// A placeholder market map view.
/// In production, integrate google_maps_flutter or flutter_map.
class MarketMapView extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String marketName;

  const MarketMapView({
    super.key,
    this.latitude,
    this.longitude,
    required this.marketName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Grid lines to simulate a map
          ...List.generate(5, (i) {
            return Positioned(
              left: 0,
              right: 0,
              top: (i + 1) * 40.0,
              child: Divider(color: Colors.grey.shade300, height: 1),
            );
          }),
          ...List.generate(7, (i) {
            return Positioned(
              top: 0,
              bottom: 0,
              left: (i + 1) * 50.0,
              child: VerticalDivider(color: Colors.grey.shade300, width: 1),
            );
          }),
          // Market pin
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 40),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                  ],
                ),
                child: Text(
                  marketName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              if (latitude != null && longitude != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
