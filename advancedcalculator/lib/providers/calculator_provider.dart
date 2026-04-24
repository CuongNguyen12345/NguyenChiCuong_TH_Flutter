import 'package:flutter/foundation.dart';

import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';
import '../services/storage_service.dart';
import '../utils/expression_parser.dart';

class CalculatorProvider extends ChangeNotifier {
  CalculatorProvider({
    required StorageService storageService,
    required CalculatorSettings initialSettings,
    required double initialMemory,
  })  : _storageService = storageService,
        _settings = initialSettings,
        _mode = initialSettings.lastMode,
        _memory = initialMemory,
        _hasMemory = initialMemory != 0;

  final StorageService _storageService;

  CalculatorSettings _settings;
  String _expression = '';
  String _result = '0';
  String _previousResult = '';
  String? _errorMessage;
  double _lastEvaluatedValue = 0;
  double _memory;
  bool _hasMemory;
  CalculatorMode _mode;

  String get expression => _expression;
  String get result => _result;
  String get previousResult => _previousResult;
  String? get errorMessage => _errorMessage;
  bool get hasMemory => _hasMemory;
  CalculatorMode get mode => _mode;
  CalculatorSettings get settings => _settings;
  AngleMode get angleMode => _settings.angleMode;

  Future<void> updateSettings(CalculatorSettings settings) async {
    _settings = settings;
    _mode = settings.lastMode;
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setMode(CalculatorMode mode) async {
    _mode = mode;
    _settings = _settings.copyWith(lastMode: mode);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  void useHistoryExpression(String value) {
    _expression = value;
    _errorMessage = null;
    notifyListeners();
  }

  void input(String value) {
    _errorMessage = null;
    switch (value) {
      case 'C':
        clearAll();
        return;
      case 'CE':
        clearEntry();
        return;
      case '=':
        return;
      case '±':
        _toggleSign();
        return;
      case 'MC':
        memoryClear();
        return;
      case 'MR':
        _appendValue(_memory.toString());
        return;
      case 'M+':
        memoryAdd();
        return;
      case 'M-':
        memorySubtract();
        return;
      case 'Ans':
        _appendValue(_lastEvaluatedValue.toString());
        return;
      case 'x²':
        _appendValue('^2');
        return;
      case '√':
        _appendValue('sqrt(');
        return;
      case 'π':
        _appendValue('π');
        return;
      case '÷':
      case '×':
      case '+':
      case '-':
      case '%':
      case '^':
      case 'AND':
      case 'OR':
      case 'XOR':
      case '<<':
      case '>>':
        _appendOperator(value);
        return;
      case 'NOT':
        _appendValue('NOT(');
        return;
      default:
        if (<String>{'sin', 'cos', 'tan', 'ln', 'log'}.contains(value)) {
          _appendValue('$value(');
          return;
        }
        _appendValue(value);
    }
  }

  void clearAll() {
    _expression = '';
    _result = '0';
    _previousResult = '';
    _errorMessage = null;
    notifyListeners();
  }

  void clearEntry() {
    _expression = '';
    _errorMessage = null;
    notifyListeners();
  }

  void deleteLast() {
    if (_expression.isEmpty) {
      return;
    }
    _expression = _expression.substring(0, _expression.length - 1);
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> calculate() async {
    if (_expression.trim().isEmpty) {
      return null;
    }
    try {
      final double value = ExpressionParser.evaluate(
        _expression,
        mode: _mode,
        angleMode: angleMode,
      );
      _lastEvaluatedValue = value;
      _previousResult = _result;
      _result = _formatNumber(value);
      _errorMessage = null;
      notifyListeners();
      return _result;
    } on FormatException catch (error) {
      _errorMessage = error.message;
      _result = 'Error';
      notifyListeners();
      return null;
    } catch (_) {
      _errorMessage = 'Invalid expression';
      _result = 'Error';
      notifyListeners();
      return null;
    }
  }

  Future<void> memoryAdd() async {
    _memory += _lastEvaluatedValue;
    _hasMemory = _memory != 0;
    await _storageService.saveMemoryValue(_memory);
    notifyListeners();
  }

  Future<void> memorySubtract() async {
    _memory -= _lastEvaluatedValue;
    _hasMemory = _memory != 0;
    await _storageService.saveMemoryValue(_memory);
    notifyListeners();
  }

  Future<void> memoryClear() async {
    _memory = 0;
    _hasMemory = false;
    await _storageService.saveMemoryValue(_memory);
    notifyListeners();
  }

  void _appendValue(String value) {
    _expression += value;
    notifyListeners();
  }

  void _appendOperator(String value) {
    if (_expression.isEmpty && value != '-') {
      return;
    }
    const List<String> operators = <String>[
      '÷',
      '×',
      '+',
      '-',
      '%',
      '^',
      'AND',
      'OR',
      'XOR',
      '<<',
      '>>',
    ];
    for (final String operator in operators) {
      if (_expression.endsWith(operator)) {
        _expression = _expression.substring(0, _expression.length - operator.length);
        break;
      }
    }
    _expression += value;
    notifyListeners();
  }

  void _toggleSign() {
    if (_expression.isEmpty) {
      _expression = '-';
    } else if (_expression.startsWith('-')) {
      _expression = _expression.substring(1);
    } else {
      _expression = '-$_expression';
    }
    notifyListeners();
  }

  String _formatNumber(double value) {
    if (mode == CalculatorMode.programmer && value == value.roundToDouble()) {
      final int intValue = value.toInt();
      return '$intValue   HEX ${intValue.toRadixString(16).toUpperCase()}';
    }
    String formatted = value
        .toStringAsFixed(_settings.decimalPrecision)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    if (formatted == '-0') {
      formatted = '0';
    }
    return formatted;
  }
}
