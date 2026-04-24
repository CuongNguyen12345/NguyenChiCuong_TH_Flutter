import 'package:flutter/material.dart';

import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.onClearHistory,
  });

  final CalculatorSettings settings;
  final ValueChanged<CalculatorSettings> onSettingsChanged;
  final VoidCallback onClearHistory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(settings.themeMode.name),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  onSettingsChanged(settings.copyWith(themeMode: value));
                }
              },
              items: ThemeMode.values
                  .map(
                    (mode) => DropdownMenuItem<ThemeMode>(
                      value: mode,
                      child: Text(mode.name),
                    ),
                  )
                  .toList(),
            ),
          ),
          ListTile(
            title: const Text('Decimal precision'),
            subtitle: Text('${settings.decimalPrecision} digits'),
            trailing: DropdownButton<int>(
              value: settings.decimalPrecision,
              onChanged: (int? value) {
                if (value != null) {
                  onSettingsChanged(settings.copyWith(decimalPrecision: value));
                }
              },
              items: List<int>.generate(9, (index) => index + 2)
                  .map(
                    (value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    ),
                  )
                  .toList(),
            ),
          ),
          SwitchListTile(
            value: settings.angleMode == AngleMode.degrees,
            onChanged: (bool value) {
              onSettingsChanged(
                settings.copyWith(
                  angleMode: value ? AngleMode.degrees : AngleMode.radians,
                ),
              );
            },
            title: const Text('Degrees mode'),
            subtitle: const Text('Turn off to use radians'),
          ),
          SwitchListTile(
            value: settings.hapticFeedback,
            onChanged: (bool value) {
              onSettingsChanged(settings.copyWith(hapticFeedback: value));
            },
            title: const Text('Haptic feedback'),
          ),
          SwitchListTile(
            value: settings.soundEffects,
            onChanged: (bool value) {
              onSettingsChanged(settings.copyWith(soundEffects: value));
            },
            title: const Text('Sound effects'),
          ),
          ListTile(
            title: const Text('History size'),
            subtitle: Text('${settings.historySize} items'),
            trailing: DropdownButton<int>(
              value: settings.historySize,
              onChanged: (int? value) {
                if (value != null) {
                  onSettingsChanged(settings.copyWith(historySize: value));
                }
              },
              items: const <int>[25, 50, 100]
                  .map(
                    (value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Are you sure you want to clear all history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                onClearHistory();
              }
            },
            child: const Text('Clear all history'),
          ),
        ],
      ),
    );
  }
}
