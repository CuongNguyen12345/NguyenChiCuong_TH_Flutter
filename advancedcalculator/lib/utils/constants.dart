import 'package:flutter/material.dart';

class AppColors {
  // Light Theme (as per spec)
  static const Color lightPrimary = Color(0xFFffffff);
  static const Color lightSecondary = Color(0xFF424242);
  static const Color lightAccent = Color(0xFFFF6B6B);

  // Dark Theme (as per spec)
  static const Color darkPrimary = Color(0xFF121212);
  static const Color darkSecondary = Color(0xFF2C2C2C);
  static const Color darkAccent = Color(0xFF4ECDC4);
}

class AppDesign {
  static const double buttonSpacing = 12.0;
  static const double screenPadding = 24.0;
  static const double buttonRadius = 16.0;
  static const double displayRadius = 24.0;

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle displayTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 32.0,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle historyTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18.0,
    fontWeight: FontWeight.w300,
  );
}
