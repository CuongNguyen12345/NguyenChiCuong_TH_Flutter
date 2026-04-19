import 'package:flutter/material.dart';

class HistoryItem {
  final String expression;
  final String result;
  final DateTime time;

  HistoryItem({
    required this.expression,
    required this.result,
    required this.time,
  });
}

class HistoryProvider with ChangeNotifier {
  final List<HistoryItem> _history = [];

  List<HistoryItem> get history => List.unmodifiable(_history);

  void addEntry(String expression, String result) {
    _history.insert(0, HistoryItem(
      expression: expression,
      result: result,
      time: DateTime.now(),
    ));
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
