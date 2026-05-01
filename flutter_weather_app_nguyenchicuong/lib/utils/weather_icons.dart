import 'package:flutter/material.dart';

class WeatherIcons {
  WeatherIcons._();

  static IconData iconForCondition(String condition) {
    final value = condition.toLowerCase();

    if (value.contains('clear')) {
      return Icons.wb_sunny_rounded;
    }
    if (value.contains('cloud')) {
      return Icons.cloud_rounded;
    }
    if (value.contains('rain') || value.contains('drizzle')) {
      return Icons.grain_rounded;
    }
    if (value.contains('storm') || value.contains('thunder')) {
      return Icons.bolt_rounded;
    }
    if (value.contains('snow')) {
      return Icons.ac_unit_rounded;
    }
    if (value.contains('mist') || value.contains('fog')) {
      return Icons.blur_on_rounded;
    }

    return Icons.wb_cloudy_rounded;
  }
}
