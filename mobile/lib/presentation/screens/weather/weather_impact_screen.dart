import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/weather_model.dart';
import '../../providers/weather_provider.dart';

const _kPrimary = Color(0xFF10B77F);
const _kBgLight = Color(0xFFF6F8F7);
const _kTextPrimary = Color(0xFF0F172A);
const _kTextSecondary = Color(0xFF64748B);
const _kChartGreen = Color(0xFF34D399);

/// Default location when geo-location is unavailable (Coimbatore, TN).
const _defaultLat = 11.0168;
const _defaultLon = 76.9558;

class WeatherImpactScreen extends ConsumerWidget {
  final double? lat;
  final double? lon;
  final String? locationName;

  const WeatherImpactScreen({
    super.key,
    this.lat,
    this.lon,
    this.locationName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usedLat = lat ?? _defaultLat;
    final usedLon = lon ?? _defaultLon;
    final weatherAsync =
        ref.watch(weatherProvider((lat: usedLat, lon: usedLon)));

    return Scaffold(
      backgroundColor: _kBgLight,
      body: weatherAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.invalidate(weatherProvider((lat: usedLat, lon: usedLon))),
        ),
        data: (weather) => _WeatherContent(
          weather: weather,
          locationName: locationName ?? 'Your Location',
          onRefresh: () =>
              ref.invalidate(weatherProvider((lat: usedLat, lon: usedLon))),
        ),
      ),
    );
  }
}

// ── Error View ──────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _kTextPrimary),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Weather Impact',
            style: TextStyle(color: _kTextPrimary, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text('Failed to load weather',
                  style: TextStyle(
                      color: _kTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(message,
                  style:
                      const TextStyle(color: _kTextSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
                child:
                    const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Main content ────────────────────────────────────────────────────────────
class _WeatherContent extends StatelessWidget {
  final WeatherModel weather;
  final String locationName;
  final VoidCallback onRefresh;

  const _WeatherContent({
    required this.weather,
    required this.locationName,
    required this.onRefresh,
  });

  IconData get _weatherIcon {
    switch (weather.conditions.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
        return Icons.water_drop;
      case 'thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.cloud_queue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Hero header ──
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: _kPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: onRefresh,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0E9F6E), _kPrimary],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(locationName,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weather.tempFormatted,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 56,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const Spacer(),
                          Icon(_weatherIcon,
                              size: 56, color: Colors.white.withOpacity(0.8)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weather.conditionsLabel,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEE, MMM d, yyyy')
                            .format(weather.forecastDate),
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Quick stat cards ──
              Row(
                children: [
                  _StatCard(
                    icon: Icons.water_drop_outlined,
                    label: 'Humidity',
                    value: weather.humidityFormatted,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.grain,
                    label: 'Rainfall',
                    value: weather.rainfallFormatted,
                    color: Colors.indigo,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.thermostat_outlined,
                    label: 'Temp',
                    value: weather.tempFormatted,
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Crop impact analysis ──
              const Text(
                'Crop Impact Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _kTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ..._buildCropImpact(weather),

              const SizedBox(height: 24),

              // ── Weather advisory ──
              _AdvisoryCard(weather: weather),

              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCropImpact(WeatherModel w) {
    // Derive impact level from weather conditions
    final impacts = <_CropImpactData>[
      _CropImpactData(
        crop: 'Rice',
        impact: w.rainfallMm > 20
            ? 'Positive'
            : w.rainfallMm < 5
                ? 'Negative'
                : 'Moderate',
        detail: w.rainfallMm > 20
            ? 'Good rainfall supports paddy growth'
            : w.rainfallMm < 5
                ? 'Low rainfall – irrigation needed'
                : 'Adequate conditions for growth',
      ),
      _CropImpactData(
        crop: 'Tomato',
        impact: w.humidityPercent > 80
            ? 'Negative'
            : w.tempCelsius > 35
                ? 'Negative'
                : 'Positive',
        detail: w.humidityPercent > 80
            ? 'High humidity increases blight risk'
            : w.tempCelsius > 35
                ? 'Excessive heat may cause sunscald'
                : 'Favorable growing conditions',
      ),
      _CropImpactData(
        crop: 'Onion',
        impact: w.rainfallMm > 30
            ? 'Negative'
            : w.tempCelsius.clamp(20, 30) == w.tempCelsius
                ? 'Positive'
                : 'Moderate',
        detail: w.rainfallMm > 30
            ? 'Excess moisture may cause rot'
            : 'Temperature in acceptable range',
      ),
    ];

    return impacts
        .map((e) => _CropImpactCard(data: e))
        .toList();
  }
}

// ── Stat card ───────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _kTextPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: _kTextSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ── Crop impact ─────────────────────────────────────────────────────────────
class _CropImpactData {
  final String crop;
  final String impact; // Positive, Negative, Moderate
  final String detail;
  const _CropImpactData(
      {required this.crop, required this.impact, required this.detail});
}

class _CropImpactCard extends StatelessWidget {
  final _CropImpactData data;
  const _CropImpactCard({required this.data});

  Color get _badgeColor {
    switch (data.impact) {
      case 'Positive':
        return _kPrimary;
      case 'Negative':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  IconData get _icon {
    switch (data.impact) {
      case 'Positive':
        return Icons.trending_up;
      case 'Negative':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _badgeColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(data.crop,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: _kTextPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data.impact,
                        style: TextStyle(
                            color: _badgeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(data.detail,
                    style: const TextStyle(
                        color: _kTextSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Advisory card ───────────────────────────────────────────────────────────
class _AdvisoryCard extends StatelessWidget {
  final WeatherModel weather;
  const _AdvisoryCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    final advisories = <String>[];

    if (weather.rainfallMm > 20) {
      advisories.add('Heavy rain expected – consider delaying harvest.');
    }
    if (weather.humidityPercent > 80) {
      advisories.add('High humidity – watch for fungal diseases.');
    }
    if (weather.tempCelsius > 38) {
      advisories.add('Extreme heat – ensure adequate irrigation.');
    }
    if (weather.tempCelsius < 10) {
      advisories.add('Cold snap – protect sensitive crops.');
    }
    if (advisories.isEmpty) {
      advisories.add('Weather conditions are generally favorable for farming.');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF6AE2D).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_outlined,
                  size: 20, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Weather Advisory',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...advisories.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ',
                      style: TextStyle(
                          color: Colors.orange.shade700, fontSize: 14)),
                  Expanded(
                    child: Text(a,
                        style: TextStyle(
                            color: Colors.orange.shade800, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
