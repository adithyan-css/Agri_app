import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../config/theme.dart';
import '../../providers/market_provider.dart';

class MarketDetailScreen extends ConsumerWidget {
  final String marketId;

  const MarketDetailScreen({super.key, required this.marketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMarket = ref.watch(selectedMarketProvider);
    final marketName = selectedMarket?.nameEn ?? 'Market';
    final district = selectedMarket?.district ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Icons.store, size: 48, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      marketName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(district,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
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
                  // Info card
                  _InfoCard(children: [
                    _InfoRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: '${selectedMarket?.district ?? district}',
                    ),
                    _InfoRow(
                      icon: Icons.access_time,
                      label: 'Operating Hours',
                      value: selectedMarket?.openHours ?? 'Not available',
                    ),
                    _InfoRow(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: selectedMarket?.phone ?? 'Not available',
                    ),
                    _InfoRow(
                      icon: Icons.circle,
                      label: 'Status',
                      value: selectedMarket?.statusLabel ?? (selectedMarket?.isActive == true
                          ? 'Open'
                          : 'Closed'),
                      valueColor: (selectedMarket?.isOpen ?? selectedMarket?.isActive) == true
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Current price
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Current Market Price',
                                style: AppTextStyles.heading3),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Select a crop to view price',
                            style: AppTextStyles.heading2),
                        const SizedBox(height: 8),
                        const Text('Prices update automatically from API',
                            style: AppTextStyles.bodySecondary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // AI Recommendation — placeholder until wired to prediction API
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.accent.withOpacity(0.3)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.psychology, color: AppColors.accent),
                            SizedBox(width: 8),
                            Text(
                              'AI RECOMMENDATION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Select a crop for advice',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        Text(
                          'Navigate to crop detail to see AI-powered sell/wait recommendation.',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.call),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.map),
                          label: const Text('Get Directions'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/profit-calculator'),
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate Profit',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text('$label: ', style: AppTextStyles.bodySecondary),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
