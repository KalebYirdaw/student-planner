import 'package:flutter/material.dart';

import '../notifications/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _testNotification(BuildContext context) async {
    await NotificationService.instance.showTestNotification();

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Test notification sent.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'Test your notification system before setting up reminders.',
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Test Notification'),
              subtitle: const Text('Send a test notification to this device'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _testNotification(context),
            ),
          ),
        ],
      ),
    );
  }
}
