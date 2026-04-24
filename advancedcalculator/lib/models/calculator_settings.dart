import 'package:flutter/material.dart';

import 'calculator_mode.dart';

class CalculatorSettings {
  const CalculatorSettings({
    this.decimalPrecision = 4,
    this.angleMode = AngleMode.degrees,
    this.hapticFeedback = true,
    this.soundEffects = false,
    this.historySize = 50,
    this.themeMode = ThemeMode.system,
    this.lastMode = CalculatorMode.basic,
  });

  final int decimalPrecision;
  final AngleMode angleMode;
  final bool hapticFeedback;
  final bool soundEffects;
  final int historySize;
  final ThemeMode themeMode;
  final CalculatorMode lastMode;

  CalculatorSettings copyWith({
    int? decimalPrecision,
    AngleMode? angleMode,
    bool? hapticFeedback,
    bool? soundEffects,
    int? historySize,
    ThemeMode? themeMode,
    CalculatorMode? lastMode,
  }) {
    return CalculatorSettings(
      decimalPrecision: decimalPrecision ?? this.decimalPrecision,
      angleMode: angleMode ?? this.angleMode,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEffects: soundEffects ?? this.soundEffects,
      historySize: historySize ?? this.historySize,
      themeMode: themeMode ?? this.themeMode,
      lastMode: lastMode ?? this.lastMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'decimalPrecision': decimalPrecision,
      'angleMode': angleMode.name,
      'hapticFeedback': hapticFeedback,
      'soundEffects': soundEffects,
      'historySize': historySize,
      'themeMode': themeMode.name,
      'lastMode': lastMode.name,
    };
  }

  factory CalculatorSettings.fromJson(Map<String, dynamic> json) {
    return CalculatorSettings(
      decimalPrecision: json['decimalPrecision'] as int? ?? 4,
      angleMode: AngleMode.values.firstWhere(
        (mode) => mode.name == json['angleMode'],
        orElse: () => AngleMode.degrees,
      ),
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      soundEffects: json['soundEffects'] as bool? ?? false,
      historySize: json['historySize'] as int? ?? 50,
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      lastMode: CalculatorMode.values.firstWhere(
        (mode) => mode.name == json['lastMode'],
        orElse: () => CalculatorMode.basic,
      ),
    );
  }
}
