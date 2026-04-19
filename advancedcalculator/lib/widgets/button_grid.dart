import 'package:flutter/material.dart';
import 'calculator_button.dart';
import '../utils/constants.dart';

class ButtonGrid extends StatelessWidget {
  final Function(String) onButtonPressed;

  const ButtonGrid({
    super.key,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return Column(
      children: [
        _buildRow(['AC', '(', ')', '/'], accentColor, isDark),
        _buildRow(['7', '8', '9', 'x'], accentColor, isDark, isOperatorRow: true),
        _buildRow(['4', '5', '6', '-'], accentColor, isDark, isOperatorRow: true),
        _buildRow(['1', '2', '3', '+'], accentColor, isDark, isOperatorRow: true),
        _buildRow(['00', '0', '.', '='], accentColor, isDark, isLastRow: true),
      ],
    );
  }

  Widget _buildRow(List<String> labels, Color accent, bool isDark, {bool isOperatorRow = false, bool isLastRow = false}) {
    return Expanded(
      child: Row(
        children: labels.map((label) {
          Color? bgColor;
          Color? textColor;
          
          // Operator buttons and special functional buttons
          bool isSpecial = ['AC', '(', ')', '/', 'x', '-', '+', '=', 'DEL'].contains(label);
          
          if (isSpecial) {
            bgColor = accent;
            textColor = Colors.white;
          } else {
            // Number buttons
            bgColor = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
            textColor = Colors.white.withOpacity(0.9);
          }

          // Special case for '=' to make it standout if needed (optional)
          if (label == '=') {
            // You can make '=' buttons even more prominent here if you want
          }

          return CalculatorButton(
            label: label,
            onPressed: () => onButtonPressed(label),
            backgroundColor: bgColor,
            textColor: textColor,
          );
        }).toList(),
      ),
    );
  }
}
