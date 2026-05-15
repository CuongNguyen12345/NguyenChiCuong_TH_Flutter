import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AudioProvider, ThemeProvider>(
      builder: (context, audioProvider, themeProvider, child) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _SettingsCard(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Shuffle'),
                  subtitle: const Text('Play tracks in random order'),
                  value: audioProvider.isShuffleEnabled,
                  onChanged: (_) => audioProvider.toggleShuffle(),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Repeat mode'),
                  subtitle: Text(audioProvider.repeatMode.name),
                  trailing: IconButton(
                    tooltip: 'Change repeat mode',
                    onPressed: audioProvider.toggleRepeat,
                    icon: const Icon(Icons.repeat_rounded),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                Text('Volume ${(audioProvider.volume * 100).round()}%'),
                Slider(
                  value: audioProvider.volume,
                  onChanged: audioProvider.setVolume,
                ),
                Text(
                  'Playback speed ${audioProvider.speed.toStringAsFixed(2)}x',
                ),
                Slider(
                  min: 0.5,
                  max: 2,
                  divisions: 6,
                  value: audioProvider.speed,
                  onChanged: audioProvider.setSpeed,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dynamic artwork theme'),
                  subtitle: const Text(
                    'Use album color accents in player artwork',
                  ),
                  value: themeProvider.useDynamicArtworkTheme,
                  onChanged: themeProvider.toggleDynamicArtworkTheme,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsCard(
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.storage_rounded),
                  title: Text('Persistence'),
                  subtitle: Text(
                    'Playlists, volume, repeat, shuffle, last song and playback position are saved locally.',
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.phone_android_rounded),
                  title: Text('Formats'),
                  subtitle: Text(
                    'MP3, M4A/AAC, WAV, FLAC and OGG are supported by the importer.',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
