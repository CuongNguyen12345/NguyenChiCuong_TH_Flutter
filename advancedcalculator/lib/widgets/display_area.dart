import 'package:flutter/material.dart';

import '../models/calculator_mode.dart';
import '../utils/constants.dart';

class DisplayArea extends StatelessWidget {
  const DisplayArea({
    super.key,
    required this.expression,
    required this.result,
    required this.previousResult,
    required this.mode,
    required this.angleMode,
    required this.hasMemory,
    this.errorMessage,
  });

  final String expression;
  final String result;
  final String previousResult;
  final CalculatorMode mode;
  final AngleMode angleMode;
  final bool hasMemory;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color cardColor = isDark
        ? AppColors.darkSecondary.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.92);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxHeight < 140;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.all(AppDesign.screenPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDesign.displayRadius),
            color: cardColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (!compact)
                Row(
                  children: <Widget>[
                    _Pill(label: mode.label),
                    const SizedBox(width: 8),
                    _Pill(label: angleMode.label),
                    if (hasMemory) ...<Widget>[
                      const SizedBox(width: 8),
                      const _Pill(label: 'MEM'),
                    ],
                  ],
                ),
              if (!compact) const Spacer(),
              if (!compact && previousResult.isNotEmpty)
                Text(
                  previousResult,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppDesign.historyTextStyle.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              if (!compact) const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  expression.isEmpty ? '0' : expression,
                  style: AppDesign.historyTextStyle.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    fontSize: compact ? 16 : AppDesign.historyTextStyle.fontSize,
                  ),
                ),
              ),
              SizedBox(height: compact ? 6 : 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: FittedBox(
                  key: ValueKey<String>(errorMessage ?? result),
                  fit: BoxFit.scaleDown,
                  child: Text(
                    errorMessage ?? result,
                    textAlign: TextAlign.end,
                    style: AppDesign.displayTextStyle.copyWith(
                      color: errorMessage == null
                          ? colorScheme.onSurface
                          : colorScheme.error,
                      fontSize: compact ? 24 : AppDesign.displayTextStyle.fontSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
