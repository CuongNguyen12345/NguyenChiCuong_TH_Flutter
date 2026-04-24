import 'package:flutter/foundation.dart';

import '../models/calculation_history.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider({
    required StorageService storageService,
    int maxEntries = 50,
  })  : _storageService = storageService,
        _maxEntries = maxEntries;

  final StorageService _storageService;
  final List<CalculationHistory> _history = <CalculationHistory>[];
  int _maxEntries;

  List<CalculationHistory> get history => List.unmodifiable(_history);

  Future<void> loadHistory() async {
    _history
      ..clear()
      ..addAll(await _storageService.loadHistory());
    notifyListeners();
  }

  Future<void> addEntry({
    required String expression,
    required String result,
  }) async {
    if (expression.trim().isEmpty) {
      return;
    }
    _history.insert(
      0,
      CalculationHistory(
        expression: expression,
        result: result,
        timestamp: DateTime.now(),
      ),
    );
    if (_history.length > _maxEntries) {
      _history.removeRange(_maxEntries, _history.length);
    }
    await _storageService.saveHistory(_history);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _storageService.saveHistory(_history);
    notifyListeners();
  }

  Future<void> setMaxEntries(int maxEntries) async {
    _maxEntries = maxEntries;
    if (_history.length > _maxEntries) {
      _history.removeRange(_maxEntries, _history.length);
      await _storageService.saveHistory(_history);
    }
    notifyListeners();
  }
}
