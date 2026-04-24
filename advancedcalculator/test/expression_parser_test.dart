import 'package:flutter_test/flutter_test.dart';

import 'package:lab3/models/calculator_mode.dart';
import 'package:lab3/utils/expression_parser.dart';

void main() {
  group('ExpressionParser', () {
    test('evaluates complex expression with precedence', () {
      final double result = ExpressionParser.evaluate(
        '(5 + 3) × 2 - 4 ÷ 2',
        mode: CalculatorMode.basic,
        angleMode: AngleMode.degrees,
      );

      expect(result, 14);
    });

    test('evaluates scientific expression in degrees', () {
      final double result = ExpressionParser.evaluate(
        'sin(45)+cos(45)',
        mode: CalculatorMode.scientific,
        angleMode: AngleMode.degrees,
      );

      expect(result, closeTo(1.4142, 0.001));
    });

    test('handles implicit multiplication', () {
      final double result = ExpressionParser.evaluate(
        '2π',
        mode: CalculatorMode.scientific,
        angleMode: AngleMode.degrees,
      );

      expect(result, closeTo(6.28318, 0.001));
    });

    test('supports programmer bitwise expressions', () {
      final double result = ExpressionParser.evaluate(
        '0xFF AND 0x0F',
        mode: CalculatorMode.programmer,
        angleMode: AngleMode.degrees,
      );

      expect(result, 15);
    });
  });
}
