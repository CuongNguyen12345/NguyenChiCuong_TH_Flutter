import 'package:flutter/material.dart';

import '../models/calculator_mode.dart';
import '../utils/calculator_logic.dart';
import '../utils/constants.dart';
import 'calculator_button.dart';

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({
    super.key,
    required this.mode,
    required this.onButtonPressed,
    required this.onButtonLongPressed,
  });

  final CalculatorMode mode;
  final ValueChanged<String> onButtonPressed;
  final ValueChanged<String> onButtonLongPressed;

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = CalculatorLayout.buttonsForMode(mode);
    final int crossAxisCount = CalculatorLayout.crossAxisCount(mode);
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDesign.screenPadding),
      itemCount: buttons.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppDesign.buttonSpacing,
        mainAxisSpacing: AppDesign.buttonSpacing,
        childAspectRatio: mode == CalculatorMode.basic ? 1.15 : 1.1,
      ),
      itemBuilder: (BuildContext context, int index) {
        final String label = buttons[index];
        return GestureDetector(
          onLongPress: label == 'C' ? () => onButtonLongPressed(label) : null,
          child: CalculatorButton(
            label: label,
            isAccent: _isAccentButton(label),
            onPressed: () => onButtonPressed(label),
          ),
        );
      },
    );
  }

  bool _isAccentButton(String label) {
    const Set<String> accentLabels = <String>{
      'C',
      'CE',
      '=',
      '÷',
      '×',
      '+',
      '-',
      'AND',
      'OR',
      'XOR',
      'NOT',
      '<<',
      '>>',
      'M+',
      'M-',
      'MR',
      'MC',
    };
    return accentLabels.contains(label);
  }
}
