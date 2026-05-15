# Offline Music Player

A Flutter offline music player for Lab 6. The app scans local songs from the
device, can import audio files manually, plays music with background media
controls, manages custom playlists, and persists playback preferences locally.

## Features

- Music library scan from Android MediaStore with audio/storage permission handling
- Manual import for MP3, M4A/AAC, WAV, FLAC, and OGG files
- Play, pause, stop, next, previous, and seek controls
- Shuffle mode and repeat modes: off, all, one
- Full Now Playing screen with progress and metadata
- Bottom mini player with progress, play/pause, and next controls
- Search by title, artist, or album
- Sort and filter by title, artist, album, and date added
- Create, rename, delete, and reorder playlists
- Add songs to playlists and remove songs from playlists
- Recently played tracking
- Persistent last song, playback position, volume, speed, shuffle, repeat, and playlists
- Background audio playback through `audio_service`
- Android notification and media-button controls
- Album artwork from device metadata when available, with an in-app fallback

## Setup

```bash
flutter pub get
flutter run
```

On Android, grant audio/storage permission when requested. If the device scan
returns no songs, use the import button in the Library screen to choose local
audio files.

## Testing With Music

Option 1: copy small, properly licensed audio files into:

```text
assets/audio/sample_songs/
```

Then keep the asset entries already configured in `pubspec.yaml`.

Option 2: run the app on a real device and import audio from local storage using
the add/import button on the Library screen.

Recommended sources for test music:

- Free Music Archive
- YouTube Audio Library
- Bensound
- Incompetech
- ccMixter

Always add attribution to `MUSIC_CREDITS.md` if sample music is bundled.

## Project Structure

```text
lib/
  main.dart
  models/
  providers/
  screens/
  services/
  utils/
  widgets/
assets/
  audio/sample_songs/
  images/
test/
  services/
screenshots/
android/
ios/
```

## Main Screens

- Library screen: songs, sorting, filters, import, refresh
- Search screen: search by title, artist, album
- Playlists screen: create, rename, delete playlists
- Playlist detail screen: play playlist, reorder songs, remove songs
- Now Playing screen: artwork, metadata, seek bar, playback controls
- Settings screen: shuffle, repeat, volume, playback speed, persistence info
- Mini player: bottom playback bar available from the main tabs

## Technologies

- Flutter
- Provider
- just_audio
- audio_service
- audio_session
- on_audio_query
- file_picker
- permission_handler
- shared_preferences
- rxdart
- palette_generator

## Platform Configuration

Android permissions and background service are configured in:

```text
android/app/src/main/AndroidManifest.xml
```

iOS music permission and background audio mode are configured in:

```text
ios/Runner/Info.plist
```

## Tests

Run:

```bash
flutter test
flutter analyze
```

Current tests cover duration formatting, model serialization, playlist model
updates, playback progress behavior, and basic audio service state.

## Screenshots

Before submitting, add screenshots to `screenshots/`:

- `home_library.png`
- `now_playing.png`
- `mini_player.png`
- `playlist.png`
- `search.png`
- `settings.png`
- `permission_dialog.png`

## Known Limitations

- No bundled music files are included to avoid licensing problems.
- Real background playback behavior should be tested on a physical Android device.
- iOS local music access may require extra device-specific testing.
- Equalizer, lyrics, visualizer, sleep timer, crossfade, and gapless playback are planned as bonus improvements.

## Submission Notes

Before creating the ZIP file for E-Learning:

```bash
flutter clean
```

Do not include `build/`, `.dart_tool/`, or `ios/Pods/` in the submitted archive.

Recommended ZIP name:

```text
MusicPlayer_[StudentID]_[Name].zip
```

Add a submission comment with:

- Audio formats tested
- Device tested on
- Extra features implemented
- Challenges faced
