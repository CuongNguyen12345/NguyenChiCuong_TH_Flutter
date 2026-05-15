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

Current tests cover:

- Duration formatting
- Song, playlist, and playback state models
- Song and playlist JSON serialization
- Storage persistence with mocked `SharedPreferences`
- Playlist provider create, rename, delete, add, remove, duplicate prevention, and reorder flows
- Manual real-device scenarios in `test/manual_testing_checklist.md`

## Screenshots

Before submitting, add screenshots to `screenshots/`:

- `home_screen.png`
<img width="425" height="959" alt="image" src="https://github.com/user-attachments/assets/8164061e-efcf-4c50-ac7a-166ef597c218" />


- `now_playing.png`
<img width="425" height="959" alt="image" src="https://github.com/user-attachments/assets/e4f92b16-4f0c-4692-b287-3516b514675c" />


- `mini_player.png`
<img width="431" height="230" alt="image" src="https://github.com/user-attachments/assets/d1a2e700-da08-4f43-9d09-2e6424078acc" />

  
- `playlist.png`
<img width="425" height="959" alt="image" src="https://github.com/user-attachments/assets/81988bdc-441b-42a8-a301-5fb1385e8308" />


- `search.png`
<img width="425" height="959" alt="image" src="https://github.com/user-attachments/assets/c838714c-2331-43a9-9240-542b2705e097" />


- `settings.png`
<img width="425" height="959" alt="image" src="https://github.com/user-attachments/assets/c9af6033-bbde-4b93-b5a2-1bc4e9d9e381" />

- `permission_dialog.png`
<img width="425" height="959" alt="image" src="https://github.com/user-attachments/assets/219df544-a61f-4326-9a44-b682e3f5a8f4" />

## Known Limitations

- No bundled music files are included to avoid licensing problems.
- Real background playback behavior should be tested on a physical Android device.
- iOS local music access may require extra device-specific testing.
- Equalizer, lyrics, visualizer, sleep timer, crossfade, and gapless playback are planned as bonus improvements.


```

Add a submission comment with:

- Audio formats tested
- Device tested on
- Extra features implemented
- Challenges faced
