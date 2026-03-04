import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          const Center(
            child: Text(
              'Kumar (Farmer)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(
            child: Text('+91 9876543210', style: TextStyle(color: Colors.grey, fontSize: 16)),
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
              value: _selectedLanguage,
              underline: const SizedBox(),
              items: ['English', 'Tamil (தமிழ்)'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
            ),
          ),

          const Divider(),

          // Actions
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('My Saved Markets'),
            onTap: () {
               context.push('/nearby-markets');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              // Support Logic
            },
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
    );
  }
}
