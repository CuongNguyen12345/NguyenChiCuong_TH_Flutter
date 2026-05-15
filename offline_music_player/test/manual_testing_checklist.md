# Manual Testing Checklist

Use this checklist on a real Android device before submission.

## Playback

- Play MP3, M4A/AAC, WAV, FLAC, and OGG files when available.
- Pause and resume playback.
- Stop playback.
- Skip to next and previous tracks.
- Seek forward and backward.
- Change volume and playback speed.
- Confirm playback continues when the app goes to background.
- Confirm notification controls work: play, pause, stop, next, previous.
- Restart the app and confirm last song and position restore.

## Library

- Grant audio/storage permission and scan device songs.
- Deny permission and confirm the app shows a helpful message.
- Import audio files manually.
- Search by song title, artist, and album.
- Sort by title, artist, album, and date added.
- Filter by artist and album.
- Confirm empty library state is readable.

## Playlists

- Create a playlist.
- Rename a playlist.
- Delete a playlist.
- Add songs to a playlist.
- Remove songs from a playlist.
- Reorder songs in a playlist.
- Play an entire playlist.

## Shuffle And Repeat

- Shuffle plays different tracks.
- Repeat all loops the queue.
- Repeat one loops the current track.
- Settings persist after app restart.

## Edge Cases

- Missing artist/album metadata shows fallback text.
- Missing album art shows fallback artwork.
- Very long song names are truncated cleanly.
- Corrupted or unsupported files show an error instead of crashing.
