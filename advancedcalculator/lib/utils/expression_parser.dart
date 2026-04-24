import 'dart:math' as math;

import '../models/calculator_mode.dart';

class ExpressionParser {
  static double evaluate(
    String expression, {
    required CalculatorMode mode,
    required AngleMode angleMode,
  }) {
    final _Tokenizer tokenizer = _Tokenizer(expression, mode: mode);
    final List<_Token> tokens = tokenizer.tokenize();
    final _TokenStream stream = _TokenStream(tokens);
    final _Parser parser = _Parser(
      stream,
      mode: mode,
      angleMode: angleMode,
    );
    final double value = parser.parseExpression();
    if (!stream.isAtEnd) {
      throw const FormatException('Unexpected token');
    }
    if (!value.isFinite) {
      throw const FormatException('Invalid result');
    }
    return value;
  }
}

enum _TokenType {
  number,
  identifier,
  plus,
  minus,
  multiply,
  divide,
  modulo,
  power,
  factorial,
  leftParen,
  rightParen,
  shiftLeft,
  shiftRight,
  and,
  or,
  xor,
  not,
  sqrt,
}

class _Token {
  const _Token(this.type, this.lexeme);

  final _TokenType type;
  final String lexeme;

  bool get startsValue =>
      type == _TokenType.number ||
      type == _TokenType.identifier ||
      type == _TokenType.leftParen ||
      type == _TokenType.not;

  bool get endsValue =>
      type == _TokenType.number ||
      type == _TokenType.identifier ||
      type == _TokenType.rightParen ||
      type == _TokenType.factorial;
}

class _Tokenizer {
  _Tokenizer(this.source, {required this.mode});

  final String source;
  final CalculatorMode mode;

  List<_Token> tokenize() {
    final List<_Token> tokens = <_Token>[];
    int index = 0;
    while (index < source.length) {
      final String char = source[index];
      if (char.trim().isEmpty) {
        index++;
        continue;
      }
      if (_isHexPrefix(index)) {
        final int start = index;
        index += 2;
        while (index < source.length && _isHexChar(source[index])) {
          index++;
        }
        tokens.add(_Token(_TokenType.number, source.substring(start, index)));
        continue;
      }
      if (_isDigit(char) || char == '.') {
        final int start = index;
        index++;
        while (index < source.length &&
            (_isDigit(source[index]) || source[index] == '.')) {
          index++;
        }
        tokens.add(_Token(_TokenType.number, source.substring(start, index)));
        continue;
      }
      if (_isLetter(char) || char == 'π') {
        final int start = index;
        index++;
        while (index < source.length &&
            (_isLetter(source[index]) || _isDigit(source[index]))) {
          index++;
        }
        final String raw = source.substring(start, index);
        final String upper = raw.toUpperCase();
        switch (upper) {
          case 'AND':
            tokens.add(const _Token(_TokenType.and, 'AND'));
            break;
          case 'OR':
            tokens.add(const _Token(_TokenType.or, 'OR'));
            break;
          case 'XOR':
            tokens.add(const _Token(_TokenType.xor, 'XOR'));
            break;
          case 'NOT':
            tokens.add(const _Token(_TokenType.not, 'NOT'));
            break;
          default:
            tokens.add(_Token(_TokenType.identifier, raw));
            break;
        }
        continue;
      }
      if (_match(index, '<<')) {
        tokens.add(const _Token(_TokenType.shiftLeft, '<<'));
        index += 2;
        continue;
      }
      if (_match(index, '>>')) {
        tokens.add(const _Token(_TokenType.shiftRight, '>>'));
        index += 2;
        continue;
      }

      switch (char) {
        case '+':
          tokens.add(const _Token(_TokenType.plus, '+'));
          break;
        case '-':
          tokens.add(const _Token(_TokenType.minus, '-'));
          break;
        case '×':
        case '*':
        case 'x':
          tokens.add(const _Token(_TokenType.multiply, '×'));
          break;
        case '÷':
        case '/':
          tokens.add(const _Token(_TokenType.divide, '÷'));
          break;
        case '%':
          tokens.add(const _Token(_TokenType.modulo, '%'));
          break;
        case '^':
          tokens.add(const _Token(_TokenType.power, '^'));
          break;
        case '!':
          tokens.add(const _Token(_TokenType.factorial, '!'));
          break;
        case '(':
          tokens.add(const _Token(_TokenType.leftParen, '('));
          break;
        case ')':
          tokens.add(const _Token(_TokenType.rightParen, ')'));
          break;
        case '&':
          tokens.add(const _Token(_TokenType.and, '&'));
          break;
        case '|':
          tokens.add(const _Token(_TokenType.or, '|'));
          break;
        case '~':
          tokens.add(const _Token(_TokenType.not, '~'));
          break;
        case '√':
          tokens.add(const _Token(_TokenType.sqrt, '√'));
          break;
        default:
          throw FormatException('Unknown token: $char');
      }
      index++;
    }
    return _insertImplicitMultiplication(tokens);
  }

  List<_Token> _insertImplicitMultiplication(List<_Token> tokens) {
    final List<_Token> result = <_Token>[];
    for (int i = 0; i < tokens.length; i++) {
      final _Token current = tokens[i];
      if (result.isNotEmpty) {
        final _Token previous = result.last;
        final bool needsMultiply =
            previous.endsValue &&
            current.startsValue &&
            current.type != _TokenType.and &&
            current.type != _TokenType.or &&
            current.type != _TokenType.xor &&
            current.type != _TokenType.shiftLeft &&
            current.type != _TokenType.shiftRight &&
            !_isFunctionIdentifier(previous.lexeme);
        if (needsMultiply &&
            !(previous.type == _TokenType.identifier &&
                _isFunctionIdentifier(previous.lexeme) &&
                current.type == _TokenType.leftParen)) {
          result.add(const _Token(_TokenType.multiply, '×'));
        }
      }
      result.add(current);
    }
    return result;
  }

  bool _isHexPrefix(int index) {
    return mode == CalculatorMode.programmer &&
        index + 1 < source.length &&
        source[index] == '0' &&
        (source[index + 1] == 'x' || source[index + 1] == 'X');
  }

  bool _match(int index, String pattern) {
    return index + pattern.length <= source.length &&
        source.substring(index, index + pattern.length) == pattern;
  }

  bool _isDigit(String char) => RegExp(r'[0-9]').hasMatch(char);
  bool _isLetter(String char) => RegExp(r'[A-Za-z_]').hasMatch(char);
  bool _isHexChar(String char) => RegExp(r'[0-9A-Fa-f]').hasMatch(char);

  bool _isFunctionIdentifier(String value) {
    const Set<String> functions = <String>{
      'sin',
      'cos',
      'tan',
      'asin',
      'acos',
      'atan',
      'ln',
      'log',
      'log2',
      'sqrt',
      'cbrt',
      'abs',
    };
    return functions.contains(value.toLowerCase());
  }
}

class _TokenStream {
  _TokenStream(this.tokens);

  final List<_Token> tokens;
  int _index = 0;

  bool get isAtEnd => _index >= tokens.length;
  _Token? get current => isAtEnd ? null : tokens[_index];

  bool match(_TokenType type) {
    if (current?.type == type) {
      _index++;
      return true;
    }
    return false;
  }

  _Token consume(_TokenType type) {
    final _Token? token = current;
    if (token == null || token.type != type) {
      throw const FormatException('Unexpected token');
    }
    _index++;
    return token;
  }
}

class _Parser {
  _Parser(
    this.stream, {
    required this.mode,
    required this.angleMode,
  });

  final _TokenStream stream;
  final CalculatorMode mode;
  final AngleMode angleMode;

  double parseExpression() {
    if (mode == CalculatorMode.programmer) {
      return _parseBitwiseOr();
    }
    return _parseAdditive();
  }

  double _parseBitwiseOr() {
    double value = _parseBitwiseXor();
    while (stream.match(_TokenType.or)) {
      value = (_toInt(value) | _toInt(_parseBitwiseXor())).toDouble();
    }
    return value;
  }

  double _parseBitwiseXor() {
    double value = _parseBitwiseAnd();
    while (stream.match(_TokenType.xor)) {
      value = (_toInt(value) ^ _toInt(_parseBitwiseAnd())).toDouble();
    }
    return value;
  }

  double _parseBitwiseAnd() {
    double value = _parseShift();
    while (stream.match(_TokenType.and)) {
      value = (_toInt(value) & _toInt(_parseShift())).toDouble();
    }
    return value;
  }

  double _parseShift() {
    double value = _parseAdditive();
    while (true) {
      if (stream.match(_TokenType.shiftLeft)) {
        value = (_toInt(value) << _toInt(_parseAdditive())).toDouble();
      } else if (stream.match(_TokenType.shiftRight)) {
        value = (_toInt(value) >> _toInt(_parseAdditive())).toDouble();
      } else {
        return value;
      }
    }
  }

  double _parseAdditive() {
    double value = _parseMultiplicative();
    while (true) {
      if (stream.match(_TokenType.plus)) {
        value += _parseMultiplicative();
      } else if (stream.match(_TokenType.minus)) {
        value -= _parseMultiplicative();
      } else {
        return value;
      }
    }
  }

  double _parseMultiplicative() {
    double value = _parsePower();
    while (true) {
      if (stream.match(_TokenType.multiply)) {
        value *= _parsePower();
      } else if (stream.match(_TokenType.divide)) {
        final double divisor = _parsePower();
        if (divisor == 0) {
          throw const FormatException('Division by zero');
        }
        value /= divisor;
      } else if (stream.match(_TokenType.modulo)) {
        value %= _parsePower();
      } else {
        return value;
      }
    }
  }

  double _parsePower() {
    double value = _parseUnary();
    if (stream.match(_TokenType.power)) {
      value = math.pow(value, _parsePower()).toDouble();
    }
    return value;
  }

  double _parseUnary() {
    if (stream.match(_TokenType.plus)) {
      return _parseUnary();
    }
    if (stream.match(_TokenType.minus)) {
      return -_parseUnary();
    }
    if (stream.match(_TokenType.not)) {
      return (~_toInt(_parseUnary())).toDouble();
    }
    if (stream.match(_TokenType.sqrt)) {
      final double value = _parseUnary();
      if (value < 0) {
        throw const FormatException('Invalid input');
      }
      return math.sqrt(value);
    }
    return _parsePostfix();
  }

  double _parsePostfix() {
    double value = _parsePrimary();
    while (stream.match(_TokenType.factorial)) {
      value = _factorial(value).toDouble();
    }
    return value;
  }

  double _parsePrimary() {
    final _Token? token = stream.current;
    if (token == null) {
      throw const FormatException('Unexpected end');
    }
    if (stream.match(_TokenType.number)) {
      return _parseNumber(token.lexeme);
    }
    if (stream.match(_TokenType.leftParen)) {
      final double value = parseExpression();
      stream.consume(_TokenType.rightParen);
      return value;
    }
    if (stream.match(_TokenType.identifier)) {
      final String name = token.lexeme;
      if (_isConstant(name)) {
        return _constantValue(name);
      }
      stream.consume(_TokenType.leftParen);
      final double arg = parseExpression();
      stream.consume(_TokenType.rightParen);
      return _applyFunction(name, arg);
    }
    throw const FormatException('Unexpected token');
  }

  bool _isConstant(String value) {
    final String lower = value.toLowerCase();
    return lower == 'pi' || lower == 'π' || lower == 'e';
  }

  double _constantValue(String value) {
    final String lower = value.toLowerCase();
    if (lower == 'e') {
      return math.e;
    }
    return math.pi;
  }

  double _applyFunction(String rawName, double arg) {
    final String name = rawName.toLowerCase();
    switch (name) {
      case 'sin':
        return math.sin(_toRadians(arg));
      case 'cos':
        return math.cos(_toRadians(arg));
      case 'tan':
        return math.tan(_toRadians(arg));
      case 'asin':
        return _fromRadians(math.asin(arg));
      case 'acos':
        return _fromRadians(math.acos(arg));
      case 'atan':
        return _fromRadians(math.atan(arg));
      case 'ln':
        return math.log(arg);
      case 'log':
        return math.log(arg) / math.ln10;
      case 'log2':
        return math.log(arg) / math.ln2;
      case 'sqrt':
      case '√':
        return math.sqrt(arg);
      case 'cbrt':
        return math.pow(arg, 1 / 3).toDouble();
      case 'abs':
        return arg.abs();
      default:
        throw FormatException('Unknown function $rawName');
    }
  }

  double _toRadians(double value) {
    return angleMode == AngleMode.degrees ? value * math.pi / 180 : value;
  }

  double _fromRadians(double value) {
    return angleMode == AngleMode.degrees ? value * 180 / math.pi : value;
  }

  int _factorial(double value) {
    if (value < 0 || value != value.roundToDouble()) {
      throw const FormatException('Invalid factorial');
    }
    int result = 1;
    for (int i = 2; i <= value; i++) {
      result *= i;
    }
    return result;
  }

  int _toInt(double value) => value.round();

  double _parseNumber(String lexeme) {
    if (lexeme.startsWith('0x') || lexeme.startsWith('0X')) {
      return int.parse(lexeme.substring(2), radix: 16).toDouble();
    }
    return double.parse(lexeme);
  }
}
