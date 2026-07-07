import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/settings_service.dart';
import '../../../../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingsCard(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sound effects'),
                subtitle: const Text('Tap, win, and lose sounds'),
                trailing: Switch(
                  value: settings.soundOn,
                  onChanged: settings.toggleSound,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Theme',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              RadioListTile<ThemeMode>(
                contentPadding: EdgeInsets.zero,
                title: const Text('System default'),
                value: ThemeMode.system,
                groupValue: settings.themeMode,
                onChanged: (mode) => settings.setThemeMode(mode!),
              ),
              RadioListTile<ThemeMode>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (mode) => settings.setThemeMode(mode!),
              ),
              RadioListTile<ThemeMode>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (mode) => settings.setThemeMode(mode!),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsCard(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reset all progress'),
                subtitle: const Text('Clears every best score and coins'),
                trailing: const Icon(Icons.delete_outline_rounded),
                onTap: () => _confirmReset(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset all progress?'),
        content: const Text(
          'This clears every game\'s best score and your coin balance. '
              'This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.instance.resetAllProgress();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress reset.')),
        );
      }
    }
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(children: children),
      ),
    );
  }
}