import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'history_provider.dart';

class CalculatorProvider with ChangeNotifier {
  String _expression = '';
  String _result = '0';
  HistoryProvider? _historyProvider;

  String get expression => _expression;
  String get result => _result;

  void updateHistoryProvider(HistoryProvider provider) {
    _historyProvider = provider;
  }

  void append(String value) {
    if (value == 'AC') {
      _expression = '';
      _result = '0';
    } else if (value == 'DEL') {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    } else if (value == '=') {
      _calculate(saveToHistory: true);
    } else {
      _expression += value;
      _calculate(saveToHistory: false);
    }
    notifyListeners();
  }

  void _calculate({bool saveToHistory = false}) {
    if (_expression.isEmpty) {
      _result = '0';
      return;
    }

    try {
      String finalExpression = _expression.replaceAll('x', '*');
      Parser p = Parser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      
      String res;
      if (eval == eval.toInt()) {
        res = eval.toInt().toString();
      } else {
        res = eval.toString();
      }
      
      _result = res;

      if (saveToHistory && _historyProvider != null) {
        _historyProvider!.addEntry(_expression, _result);
      }
    } catch (e) {
      if (saveToHistory) _result = 'Error';
    }
  }
}
