import 'package:flutter/material.dart';

import '../utils/constants.dart';

class CalculatorButton extends StatefulWidget {
  const CalculatorButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isAccent = false,
    this.isWide = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isAccent;
  final bool isWide;

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    lowerBound: 0.94,
    upperBound: 1,
    value: 1,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = widget.isAccent
        ? (isDark ? AppColors.darkAccent : AppColors.lightAccent)
        : (isDark ? AppColors.darkSecondary : Colors.white);
    final Color foregroundColor =
        widget.isAccent ? Colors.white : (isDark ? Colors.white : AppColors.lightPrimary);

    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapCancel: _controller.forward,
      onTapUp: (_) => _controller.forward(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _controller,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppDesign.buttonRadius),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: AppDesign.buttonTextStyle.copyWith(
                color: foregroundColor,
                fontWeight: widget.isAccent ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
