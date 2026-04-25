import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/calculation_history.dart';
import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../widgets/button_grid.dart';
import '../widgets/display_area.dart';
import '../widgets/mode_selector.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CalculatorProvider, HistoryProvider>(
      builder: (
        BuildContext context,
        CalculatorProvider calculator,
        HistoryProvider history,
        _,
      ) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Advanced Calculator'),
            actions: <Widget>[
              IconButton(
                onPressed: () => _openHistory(context, history.history),
                icon: const Icon(Icons.history_rounded),
              ),
              IconButton(
                onPressed: () => _openSettings(context, calculator.settings),
                icon: const Icon(Icons.settings_rounded),
              ),
              IconButton(
                onPressed: context.read<ThemeProvider>().toggleTheme,
                icon: const Icon(Icons.brightness_6_rounded),
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFFF6F1EB),
                  Color(0xFFE7F1ED),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDesign.screenPadding),
                child: Column(
                  children: <Widget>[
                    ModeSelector(
                      currentMode: calculator.mode,
                      onChanged: calculator.setMode,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        onHorizontalDragEnd: (_) => calculator.deleteLast(),
                        onVerticalDragEnd: (DragEndDetails details) {
                          if ((details.primaryVelocity ?? 0) < 0) {
                            _openHistory(context, history.history);
                          }
                        },
                        child: DisplayArea(
                          expression: calculator.expression,
                          result: calculator.result,
                          previousResult: calculator.previousResult,
                          mode: calculator.mode,
                          angleMode: calculator.angleMode,
                          hasMemory: calculator.hasMemory,
                          errorMessage: calculator.errorMessage,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 90,
                      child: _HistoryPreview(
                        history: history.history.take(3).toList(),
                        onReuse: (CalculationHistory item) {
                          calculator.useHistoryExpression(item.expression);
                        },
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: ButtonGrid(
                          key: ValueKey<CalculatorMode>(calculator.mode),
                          mode: calculator.mode,
                          onButtonPressed: (String label) async {
                            if (label == '=') {
                              final String? result = await calculator.calculate();
                              if (result != null) {
                                await history.addEntry(
                                  expression: calculator.expression,
                                  result: result,
                                );
                              }
                              return;
                            }
                            calculator.input(label);
                          },
                          onButtonLongPressed: (_) async {
                            await history.clearHistory();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openHistory(
    BuildContext context,
    List<CalculationHistory> history,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HistoryScreen(
          history: history,
          onReuse: (CalculationHistory item) {
            context.read<CalculatorProvider>().useHistoryExpression(item.expression);
          },
          onClear: () async {
            final HistoryProvider historyProvider = context.read<HistoryProvider>();
            final NavigatorState navigator = Navigator.of(context);
            await historyProvider.clearHistory();
            navigator.pop();
          },
        ),
      ),
    );
  }

  Future<void> _openSettings(
    BuildContext context,
    CalculatorSettings settings,
  ) async {
    final CalculatorProvider calculatorProvider =
        context.read<CalculatorProvider>();
    final HistoryProvider historyProvider = context.read<HistoryProvider>();
    final ThemeProvider themeProvider = context.read<ThemeProvider>();

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          onSettingsChanged: (CalculatorSettings newSettings) async {
            await calculatorProvider.updateSettings(newSettings);
            await historyProvider.setMaxEntries(newSettings.historySize);
            themeProvider.setThemeMode(newSettings.themeMode);
          },
          onClearHistory: () async {
            await historyProvider.clearHistory();
          },
        ),
      ),
    );
  }
}

class _HistoryPreview extends StatelessWidget {
  const _HistoryPreview({
    required this.history,
    required this.onReuse,
  });

  final List<CalculationHistory> history;
  final ValueChanged<CalculationHistory> onReuse;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Text(
          'Swipe up for history',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: history.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (BuildContext context, int index) {
        final CalculationHistory item = history[index];
        return SizedBox(
          width: 180,
          child: InkWell(
            onTap: () => onReuse(item),
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    item.expression,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.result,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
