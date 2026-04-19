import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/display_area.dart';
import '../widgets/button_grid.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/history_provider.dart';
import '../utils/constants.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  @override
  void initState() {
    super.initState();
    // Connect history provider to calculator provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final history = context.read<HistoryProvider>();
      context.read<CalculatorProvider>().updateHistoryProvider(history);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final scaffoldBg = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Calculator',
          style: AppDesign.historyTextStyle.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: Colors.white,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              // Navigate to history screen (if implemented)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDesign.screenPadding),
          child: Column(
            children: [
              // Display Area with better spacing
              const SizedBox(height: 10),
              Expanded(
                flex: 3,
                child: Consumer<CalculatorProvider>(
                  builder: (context, provider, child) {
                    return DisplayArea(
                      expression: provider.expression.isEmpty ? '0' : provider.expression,
                      result: provider.result,
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              // Separator line (optional for modern look)
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.white.withOpacity(0.1),
              ),
              const SizedBox(height: 30),
              // Button Grid
              Expanded(
                flex: 7,
                child: ButtonGrid(
                  onButtonPressed: (label) {
                    context.read<CalculatorProvider>().append(label);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
