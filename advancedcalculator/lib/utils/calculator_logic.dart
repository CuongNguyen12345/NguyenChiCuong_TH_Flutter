import '../models/calculator_mode.dart';

class CalculatorLayout {
  static const List<String> basicButtons = <String>[
    'C',
    'CE',
    '%',
    '÷',
    '7',
    '8',
    '9',
    '×',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '±',
    '0',
    '.',
    '=',
  ];

  static const List<String> scientificButtons = <String>[
    '2nd', 'sin', 'cos', 'tan', 'Ln', 'log',
    'x²', '√', 'x^y', '(', ')', '÷',
    'MC', '7', '8', '9', 'C', '×',
    'MR', '4', '5', '6', 'CE', '-',
    'M+', '1', '2', '3', '%', '+',
    'M-', '±', '0', '.', 'П', '=',
  ];

  static const List<String> programmerButtons = <String>[
    'A',
    'B',
    'C',
    'D',
    'AND',
    'OR',
    'E',
    'F',
    '(',
    ')',
    'XOR',
    'NOT',
    '7',
    '8',
    '9',
    '<<',
    '>>',
    '÷',
    '4',
    '5',
    '6',
    'C',
    'CE',
    '×',
    '1',
    '2',
    '3',
    '%',
    '-',
    '+',
    '0',
    '.',
    '0x',
    'Ans',
    '±',
    '=',
  ];

  static List<String> buttonsForMode(CalculatorMode mode) {
    switch (mode) {
      case CalculatorMode.basic:
        return basicButtons;
      case CalculatorMode.scientific:
        return scientificButtons;
      case CalculatorMode.programmer:
        return programmerButtons;
    }
  }

  static int crossAxisCount(CalculatorMode mode) {
    switch (mode) {
      case CalculatorMode.basic:
        return 4;
      case CalculatorMode.scientific:
      case CalculatorMode.programmer:
        return 6;
    }
  }
}
