import 'package:flutter/material.dart';

import '../models/calculator_mode.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  final CalculatorMode currentMode;
  final ValueChanged<CalculatorMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<CalculatorMode>(
      segments: CalculatorMode.values
          .map(
            (mode) => ButtonSegment<CalculatorMode>(
              value: mode,
              label: Text(mode.label),
            ),
          )
          .toList(),
      selected: <CalculatorMode>{currentMode},
      onSelectionChanged: (Set<CalculatorMode> selected) {
        onChanged(selected.first);
      },
    );
  }
}
