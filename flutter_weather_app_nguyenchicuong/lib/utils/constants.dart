import 'package:flutter/material.dart';

enum TemperatureUnit { celsius, fahrenheit }

enum WindSpeedUnit { metersPerSecond, kilometersPerHour, milesPerHour }

class AppDimensions {
  AppDimensions._();

  static const double screenPadding = 20;
  static const double cardRadius = 20;
  static const double cardElevation = 4;
}

class AppColors {
  AppColors._();

  static const Color sunnyPrimary = Color(0xFFFDB813);
  static const Color sunnyBackground = Color(0xFF87CEEB);
  static const Color rainyPrimary = Color(0xFF4A5568);
  static const Color rainyBackground = Color(0xFF718096);
  static const Color cloudyPrimary = Color(0xFFA0AEC0);
  static const Color cloudyBackground = Color(0xFFCBD5E0);
  static const Color nightPrimary = Color(0xFF2D3748);
  static const Color nightBackground = Color(0xFF1A202C);
}

class WeatherGradients {
  WeatherGradients._();

  static LinearGradient byCondition(String condition) {
    final value = condition.toLowerCase();

    if (value.contains('clear')) {
      return const LinearGradient(
        colors: [AppColors.sunnyPrimary, AppColors.sunnyBackground],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (value.contains('rain') || value.contains('drizzle') || value.contains('storm')) {
      return const LinearGradient(
        colors: [AppColors.rainyPrimary, AppColors.rainyBackground],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (value.contains('cloud') || value.contains('mist') || value.contains('fog')) {
      return const LinearGradient(
        colors: [AppColors.cloudyPrimary, AppColors.cloudyBackground],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return const LinearGradient(
      colors: [AppColors.nightPrimary, AppColors.nightBackground],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
