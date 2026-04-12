import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _equation = '';
  double _num1 = 0;
  double _num2 = 0;
  String _operation = '';
  bool _shouldResetDisplay = false;

  String _formatResult(double result) {
    if (result == result.toInt()) {
      return result.toInt().toString();
    }
    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF000000);
    const Color accentColor = Color(0xFF963E3E);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_equation.isNotEmpty)
                        Text(
                          _equation,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        _display, // Kết quả
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  _buildRow(['C', '%', 'CE', '÷'], accentColor: accentColor),
                  const SizedBox(height: 7),
                  _buildRow(['7', '8', '9', '×']),
                  const SizedBox(height: 7),
                  _buildRow(['4', '5', '6', '-']),
                  const SizedBox(height: 7),
                  _buildRow(['1', '2', '3', '+']),
                  const SizedBox(height: 7),
                  _buildRow(['+/-', '0', '.', '='], equalButton: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    List<String> labels, {
    Color? accentColor,
    bool equalButton = false,
  }) {
    return Row(
      children: labels.map((label) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: _buildButton(label, accentColor),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(String label, Color? accentColor) {
    bool isOperator = ['÷', '×', '-', '+', '=', 'C', '%', 'CE'].contains(label);

    Color btnColor = const Color(0xFF272727);

    if (label == 'C') {
      btnColor = const Color(0xFF963E3E);
    } else if (label == '=') {
      btnColor = const Color(0xFF076544);
    } else if (['÷', '×', '-', '+'].contains(label)) {
      btnColor = const Color(0xFF394734);
    }

    return AspectRatio(
      aspectRatio: 1,
      child: ElevatedButton(
        onPressed: () => _onButtonPressed(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(45),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 32,
            fontWeight: isOperator ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

  void _onButtonPressed(String label) {
    setState(() {
      if (label == 'C') {
        _display = '0';
        _equation = '';
        _num1 = 0;
        _num2 = 0;
        _operation = '';
        _shouldResetDisplay = false;
      } else if (label == '%') {
        double currentVal = double.tryParse(_display) ?? 0;
        if (_operation == '+' || _operation == '-') {
          double val = (_num1 * currentVal) / 100;
          _display = _formatResult(val);
        } else {
          _display = _formatResult(currentVal / 100);
        }
      } else if (label == 'CE') {
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
        }
      } else if (label == '÷' || label == '×' || label == '-' || label == '+') {
        // Lưu số hiện tại trước khi tính trung gian (để hiển thị equation đúng)
        String currentInput = _display;

        // Nếu đã có phép tính đang chờ, tính kết quả trung gian trước
        if (_operation.isNotEmpty && _shouldResetDisplay == false) {
          _num2 = double.tryParse(_display) ?? 0;
          double intermediate = 0;
          switch (_operation) {
            case '+': intermediate = _num1 + _num2; break;
            case '-': intermediate = _num1 - _num2; break;
            case '×': intermediate = _num1 * _num2; break;
            case '÷':
              if (_num2 != 0) {
                intermediate = _num1 / _num2;
              } else {
                _display = 'Error';
                return;
              }
              break;
          }
          _num1 = intermediate;
        } else {
          _num1 = double.tryParse(_display) ?? 0;
        }
        _operation = label;
        // Nối biểu thức với số gốc (không phải kết quả trung gian)
        if (_equation.isEmpty || _equation.endsWith('=')) {
          _equation = '$currentInput $label ';
        } else {
          _equation += '$currentInput $label ';
        }
        _shouldResetDisplay = true;
      } else if (label == '=') {
        _num2 = double.tryParse(_display) ?? 0;
        // Hiển thị phương trình đầy đủ kèm dấu =
        _equation += '$_display =';
        double result = 0;
        switch (_operation) {
          case '+':
            result = _num1 + _num2;
            break;
          case '-':
            result = _num1 - _num2;
            break;
          case '×':
            result = _num1 * _num2;
            break;
          case '÷':
            if (_num2 != 0) {
              result = _num1 / _num2;
            } else {
              _display = 'Error';
              return;
            }
            break;
        }
        _display = _formatResult(result);
        _operation = '';
        _shouldResetDisplay = true;
      } else if (label == '+/-') {
        if (_display.startsWith('-')) {
          _display = _display.substring(1);
        } else if (_display != '0') {
          _display = '-$_display';
        }
      } else if (label == '.') {
        if (!_display.contains('.')) {
          _display += '.';
        }
      } else {
        // Nhập số
        if (_shouldResetDisplay) {
          _display = label;
          _shouldResetDisplay = false;
        } else if (_display == '0') {
          _display = label;
        } else {
          _display += label;
        }
        // Nếu vừa nhấn = rồi nhập số mới -> reset equation
        if (_equation.endsWith('=')) {
          _equation = '';
        }
      }
    });
  }
}

