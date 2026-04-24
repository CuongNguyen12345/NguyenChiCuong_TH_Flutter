import 'package:flutter/material.dart';

class AppColors {
  static const Color lightPrimary = Color(0xFF1E1E1E);
  static const Color lightSecondary = Color(0xFF424242);
  static const Color lightAccent = Color(0xFFFF6B6B);

  static const Color darkPrimary = Color(0xFF121212);
  static const Color darkSecondary = Color(0xFF2C2C2C);
  static const Color darkAccent = Color(0xFF4ECDC4);
}

class AppDesign {
  static const double buttonSpacing = 12;
  static const double screenPadding = 24;
  static const double buttonRadius = 16;
  static const double displayRadius = 24;

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle displayTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 32,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle historyTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18,
    fontWeight: FontWeight.w300,
  );
}

class AppThemes {
  static ThemeData get lightTheme {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.lightAccent,
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightAccent,
      surface: const Color(0xFFF8F6F1),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF4EFE7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: Typography.blackMountainView.apply(
        bodyColor: AppColors.lightPrimary,
        displayColor: AppColors.lightPrimary,
      ),
    );
  }

  static ThemeData get darkTheme {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkAccent,
      brightness: Brightness.dark,
      primary: AppColors.darkAccent,
      secondary: AppColors.darkAccent,
      surface: AppColors.darkPrimary,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF101418),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: Typography.whiteMountainView,
    );
  }
}
