import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              const SizedBox(height: 6),
              ListTile(
                title: const Text('Temperature Unit', style: TextStyle(fontWeight: FontWeight.w700)),
                trailing: DropdownButton<TemperatureUnit>(
                  value: provider.temperatureUnit,
                  items: const [
                    DropdownMenuItem(
                      value: TemperatureUnit.celsius,
                      child: Text('Celsius (C)'),
                    ),
                    DropdownMenuItem(
                      value: TemperatureUnit.fahrenheit,
                      child: Text('Fahrenheit (F)'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      provider.setTemperatureUnit(value);
                    }
                  },
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Wind Speed Unit', style: TextStyle(fontWeight: FontWeight.w700)),
                trailing: DropdownButton<WindSpeedUnit>(
                  value: provider.windSpeedUnit,
                  items: const [
                    DropdownMenuItem(
                      value: WindSpeedUnit.metersPerSecond,
                      child: Text('m/s'),
                    ),
                    DropdownMenuItem(
                      value: WindSpeedUnit.kilometersPerHour,
                      child: Text('km/h'),
                    ),
                    DropdownMenuItem(
                      value: WindSpeedUnit.milesPerHour,
                      child: Text('mph'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      provider.setWindSpeedUnit(value);
                    }
                  },
                ),
              ),
              const Divider(),
              SwitchListTile(
                value: provider.use24HourFormat,
                title: const Text('Use 24-hour format'),
                onChanged: provider.setUse24HourFormat,
              ),
              const Divider(),
              SwitchListTile(
                value: provider.isDarkMode,
                title: const Text('Dark Mode'),
                onChanged: provider.setDarkMode,
              ),
              const Divider(),
              ListTile(
                title: const Text('Language (optional)'),
                subtitle: const Text('Only preference is stored in this lab version.'),
                trailing: DropdownButton<String>(
                  value: provider.languageCode,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'vi', child: Text('Vietnamese')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      provider.setLanguageCode(value);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
