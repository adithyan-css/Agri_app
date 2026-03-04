import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/language_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    final langNotifier = ref.read(languageProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language section
          _sectionHeader(context, 'Language / மொழி'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                  groupValue: locale.languageCode,
                  activeColor: const Color(0xFF10b77f),
                  onChanged: (val) => langNotifier.setLanguage(val!),
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: const Text('தமிழ் (Tamil)'),
                  value: 'ta',
                  groupValue: locale.languageCode,
                  activeColor: const Color(0xFF10b77f),
                  onChanged: (val) => langNotifier.setLanguage(val!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications section
          _sectionHeader(context, 'Notifications'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Price Alerts'),
                  subtitle: const Text('Get notified when prices hit your target'),
                  value: true,
                  activeColor: const Color(0xFF10b77f),
                  onChanged: (_) {},
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Daily Summary'),
                  subtitle: const Text('Daily market price summary at 8 AM'),
                  value: false,
                  activeColor: const Color(0xFF10b77f),
                  onChanged: (_) {},
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Prediction Updates'),
                  subtitle: const Text('Notify when AI predictions change'),
                  value: true,
                  activeColor: const Color(0xFF10b77f),
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About section
          _sectionHeader(context, 'About'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App Version'),
                  trailing: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
