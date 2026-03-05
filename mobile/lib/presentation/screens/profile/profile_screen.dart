import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;

  void _logout() {
    ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final locale = ref.watch(languageProvider);
    final langNotifier = ref.read(languageProvider.notifier);

    final displayName = user?.displayName ?? 'Farmer';
    final phone = user?.phoneNumber ?? '';
    final roleLabel = user?.roleLabel ?? 'Farmer';
    final selectedLanguage = locale.languageCode == 'ta' ? 'Tamil (தமிழ்)' : 'English';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '$displayName ($roleLabel)',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ),
          const SizedBox(height: 32),
          
          const Divider(),
          
          // Settings 
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('App Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Price Alerts & Notifications'),
            trailing: Switch(
              value: _notificationsEnabled,
              activeColor: Colors.green,
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
              },
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              underline: const SizedBox(),
              items: ['English', 'Tamil (தமிழ்)'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue == 'Tamil (தமிழ்)') {
                  langNotifier.setLanguage('ta');
                } else {
                  langNotifier.setLanguage('en');
                }
              },
            ),
          ),

          const Divider(),

          // Actions
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            subtitle: const Text('Language, notifications, data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('My Saved Markets'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/nearby-markets'),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping_outlined),
            title: const Text('Transport & Bookings'),
            subtitle: const Text('Book trucks, view bookings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/transport'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('My Bookings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/bookings'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showHelpSupportSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showInfoPage(context, 'Terms of Service', _termsOfServiceText),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showInfoPage(context, 'Privacy Policy', _privacyPolicyText),
          ),
          
          const SizedBox(height: 24),
          
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  void _showHelpSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Help & Support',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.call, color: Colors.green),
              ),
              title: const Text('Call Support'),
              subtitle: const Text('+91 1800-XXX-XXXX (Toll Free)'),
              onTap: () {
                Navigator.pop(ctx);
                launchUrl(Uri.parse('tel:+911800000000'));
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.email, color: Colors.blue),
              ),
              title: const Text('Email Us'),
              subtitle: const Text('support@agriprice.ai'),
              onTap: () {
                Navigator.pop(ctx);
                launchUrl(Uri.parse('mailto:support@agriprice.ai?subject=Help%20Request'));
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF8E1),
                child: Icon(Icons.question_answer, color: Colors.orange),
              ),
              title: const Text('FAQs'),
              subtitle: const Text('Find answers to common questions'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('FAQ section coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFCE4EC),
                child: Icon(Icons.bug_report, color: Colors.red),
              ),
              title: const Text('Report a Bug'),
              subtitle: const Text('Help us improve the app'),
              onTap: () {
                Navigator.pop(ctx);
                launchUrl(Uri.parse('mailto:bugs@agriprice.ai?subject=Bug%20Report'));
              },
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'AgriPrice AI v1.0.0',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showInfoPage(BuildContext context, String title, String content) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(content, style: const TextStyle(fontSize: 14, height: 1.6)),
        ),
      ),
    ));
  }

  static const String _termsOfServiceText = '''
AgriPrice AI - Terms of Service

Last Updated: June 2025

1. Acceptance of Terms
By using AgriPrice AI, you agree to these terms.

2. Service Description
AgriPrice AI provides agricultural market price data, AI-powered predictions, and market discovery tools for farmers in Tamil Nadu.

3. Data Accuracy
Price data and AI predictions are provided for informational purposes only. We do not guarantee accuracy. Always verify prices directly with markets before making buying/selling decisions.

4. User Responsibilities
- Provide accurate registration information
- Keep your login credentials secure
- Use the app for lawful agricultural purposes only

5. Limitation of Liability
AgriPrice AI is not liable for any financial losses resulting from decisions made based on app data or predictions.

6. Contact
For questions: support@agriprice.ai
''';

  static const String _privacyPolicyText = '''
AgriPrice AI - Privacy Policy

Last Updated: June 2025

1. Information We Collect
- Account information (name, email, phone)
- Location data (for nearby market discovery)
- App usage data

2. How We Use Your Data
- Provide personalized price alerts and predictions
- Show nearby markets based on your location
- Improve our AI models and services

3. Data Sharing
We do not sell your personal data. We may share anonymized, aggregated data for research purposes.

4. Location Data
Location data is used only for finding nearby markets and weather information. You can disable location access in your device settings.

5. Data Security
We use industry-standard encryption to protect your data.

6. Your Rights
You can request deletion of your account and data by contacting support@agriprice.ai.

7. Contact
Privacy concerns: support@agriprice.ai
''';
}
