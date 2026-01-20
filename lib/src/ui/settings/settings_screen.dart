import 'package:flutter/material.dart';
import '../../notifications/notification_center.dart';

class SettingsScreen extends StatelessWidget {
  final String deviceId;
  final ThemeMode themeMode;
  final Future<void> Function(ThemeMode mode) onChangeTheme;
  final Future<void> Function() onChangeDevice;
  final Future<void> Function() onResetApp;
  final NotificationCenter center;

  const SettingsScreen({
    super.key,
    required this.deviceId,
    required this.themeMode,
    required this.onChangeTheme,
    required this.onChangeDevice,
    required this.onResetApp,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: const Text('Theme'),
            subtitle: Text(themeMode.toString()),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (v) {
                if (v == null) return;
                onChangeTheme(v);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Change device'),
            subtitle: Text('Current: $deviceId'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onChangeDevice,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('About'),
            subtitle: const Text(
              'IoT Fish Feeder System\nFlutter + Firebase RTDB',
            ),
            trailing: const Icon(Icons.info_outline),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Fish Feeder',
                applicationVersion: '1.0.0',
                children: const [
                  Text(
                    'Dashboard, Control, History charts, Settings and in-app notifications.',
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Reset App'),
            subtitle: const Text('Clears saved device + settings'),
            trailing: const Icon(Icons.restart_alt),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset App'),
                  content: const Text(
                    'This will clear saved device and settings. Continue?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await onResetApp();
              }
            },
          ),
        ),
      ],
    );
  }
}
