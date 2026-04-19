import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CalculatorButton extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback onPressed;
  final bool isLarge;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Default background color based on theme if not provided
    Color defaultBg = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    
    return Expanded(
      flex: isLarge ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(AppDesign.buttonSpacing / 2),
        child: Material(
          color: backgroundColor ?? defaultBg,
          borderRadius: BorderRadius.circular(AppDesign.buttonRadius),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppDesign.buttonRadius),
            child: Container(
              alignment: Alignment.center,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDesign.buttonRadius),
              ),
              child: Text(
                label,
                style: AppDesign.buttonTextStyle.copyWith(
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
