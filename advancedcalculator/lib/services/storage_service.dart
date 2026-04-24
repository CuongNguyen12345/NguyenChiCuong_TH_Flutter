import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/calculation_history.dart';
import '../models/calculator_settings.dart';

class StorageService {
  static const String _historyKey = 'calculator_history';
  static const String _settingsKey = 'calculator_settings';
  static const String _memoryKey = 'calculator_memory';

  Future<List<CalculationHistory>> loadHistory() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> rawList =
        preferences.getStringList(_historyKey) ?? <String>[];
    return rawList
        .map((String raw) => CalculationHistory.fromJson(
              jsonDecode(raw) as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<void> saveHistory(List<CalculationHistory> history) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _historyKey,
      history.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<CalculatorSettings> loadSettings() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return const CalculatorSettings();
    }
    return CalculatorSettings.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> saveSettings(CalculatorSettings settings) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<double> loadMemoryValue() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getDouble(_memoryKey) ?? 0;
  }

  Future<void> saveMemoryValue(double value) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_memoryKey, value);
  }
}
