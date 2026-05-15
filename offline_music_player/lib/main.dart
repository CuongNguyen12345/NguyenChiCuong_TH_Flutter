import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/audio_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final audioService = await AudioService.init<AudioPlayerService>(
    builder: AudioPlayerService.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.offline_music_player.audio',
      androidNotificationChannelName: 'Music playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  runApp(OfflineMusicPlayerApp(audioService: audioService));
}

class OfflineMusicPlayerApp extends StatelessWidget {
  const OfflineMusicPlayerApp({super.key, required this.audioService});

  final AudioPlayerService audioService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AudioProvider(audioService: audioService),
        ),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        title: AppText.appName,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
            primary: AppColors.primary,
            surface: AppColors.background,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.text,
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: CardThemeData(
            color: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          popupMenuTheme: const PopupMenuThemeData(
            color: AppColors.card,
            textStyle: TextStyle(color: AppColors.text),
          ),
          sliderTheme: const SliderThemeData(
            activeTrackColor: AppColors.primary,
            thumbColor: AppColors.text,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: AppColors.card,
            selectedColor: AppColors.primary.withValues(alpha: 0.18),
            labelStyle: const TextStyle(color: AppColors.text),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
            titleLarge: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
            bodyMedium: TextStyle(color: AppColors.text),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
