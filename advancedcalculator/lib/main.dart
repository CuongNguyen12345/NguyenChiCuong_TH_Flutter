import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/calculator_settings.dart';
import 'providers/calculator_provider.dart';
import 'providers/history_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/calculator_screen.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final StorageService storageService = StorageService();
  final CalculatorSettings settings = await storageService.loadSettings();
  final double memory = await storageService.loadMemoryValue();

  runApp(
    MyApp(
      storageService: storageService,
      initialSettings: settings,
      initialMemory: memory,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.storageService,
    required this.initialSettings,
    required this.initialMemory,
  });

  final StorageService storageService;
  final CalculatorSettings initialSettings;
  final double initialMemory;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final HistoryProvider _historyProvider = HistoryProvider(
    storageService: widget.storageService,
    maxEntries: widget.initialSettings.historySize,
  )..loadHistory();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) =>
              ThemeProvider(initialThemeMode: widget.initialSettings.themeMode),
        ),
        ChangeNotifierProvider<CalculatorProvider>(
          create: (_) => CalculatorProvider(
            storageService: widget.storageService,
            initialSettings: widget.initialSettings,
            initialMemory: widget.initialMemory,
          ),
        ),
        ChangeNotifierProvider<HistoryProvider>.value(value: _historyProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, ThemeProvider themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            home: const CalculatorScreen(),
          );
        },
      ),
    );
  }
}
