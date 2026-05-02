import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/location_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';
import 'services/connectivity_service.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';
import 'services/weather_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env', isOptional: true);
  } catch (_) {
    // Env file is optional in this mock build; API integration can be added later.
  }

  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<WeatherService>(create: (_) => WeatherService()),
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<ConnectivityService>(create: (_) => ConnectivityService()),
        ChangeNotifierProvider<LocationProvider>(
          create: (context) =>
              LocationProvider(context.read<LocationService>()),
        ),
        ChangeNotifierProvider<WeatherProvider>(
          create: (context) => WeatherProvider(
            context.read<WeatherService>(),
            context.read<LocationService>(),
            context.read<StorageService>(),
            context.read<ConnectivityService>(),
          ),
        ),
      ],
      child: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Weather App',
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A202C)),
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF90CAF9),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
