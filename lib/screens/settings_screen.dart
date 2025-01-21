import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cricket/controllers/controllers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsController>(
        builder: (context, settingsController, child) {
          return ListView(
            children: [
              // Theme Toggle
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: settingsController.isDarkMode,
                onChanged: (_) => settingsController.toggleTheme(),
              ),

              // Delete Account Option
              ListTile(
                title: const Text('Delete Account'),
                subtitle: const Text('Permanently remove your account'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () {
                    _showDeleteAccountDialog(context, settingsController);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteAccountDialog(
      BuildContext context, SettingsController settingsController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              settingsController.deleteAccount();
              Navigator.of(context).pop();
              // Optionally navigate to login or show confirmation
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
