import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/language_provider.dart';
import '../../providers/market_provider.dart';
import '../../../data/data_sources/local/local_data_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    if (mounted) {
      setState(() => _notificationsEnabled = enabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final langCode = lang.languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Language section
          _SectionHeader(title: 'Language'),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: langCode,
            onChanged: (v) {
              if (v != null) {
                ref.read(languageProvider.notifier).setLanguage(v);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('தமிழ் (Tamil)'),
            value: 'ta',
            groupValue: langCode,
            onChanged: (v) {
              if (v != null) {
                ref.read(languageProvider.notifier).setLanguage(v);
              }
            },
          ),

          const Divider(),

          // Market Selection
          _SectionHeader(title: 'Market'),
          Consumer(builder: (context, ref, _) {
            final selectedMarket = ref.watch(selectedMarketProvider);
            return ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Selected Market'),
              subtitle: Text(
                selectedMarket != null
                    ? '${selectedMarket.nameEn} • ${selectedMarket.district}'
                    : 'No market selected',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/select-market?changing=true'),
            );
          }),

          const Divider(),

          // Notifications
          _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            title: const Text('Price Alerts'),
            subtitle: const Text('Get notified when prices reach your target'),
            value: _notificationsEnabled,
            onChanged: (v) async {
              setState(() => _notificationsEnabled = v);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('notifications_enabled', v);
            },
          ),

          const Divider(),

          // Data & Storage
          _SectionHeader(title: 'Data & Storage'),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Cache'),
            subtitle: const Text('Remove locally cached data'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Cache?'),
                  content: const Text(
                    'This will remove cached prices and predictions. '
                    'Your account and alerts will not be affected.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && mounted) {
                // Actually clear cached data
                await LocalDataService.clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared')),
                );
              }
            },
          ),

          const Divider(),

          // About
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('AgriPrice AI'),
            subtitle: const Text('Version 1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.tour_outlined),
            title: const Text('View App Tour'),
            subtitle: const Text('See the onboarding walkthrough again'),
            onTap: () => context.push('/onboarding'),
          ),

          const Divider(),

          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) context.go('/login');
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
