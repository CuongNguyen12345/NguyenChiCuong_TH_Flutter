class PlaybackStateModel {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;

  const PlaybackStateModel({
    required this.position,
    required this.duration,
    required this.isPlaying,
    this.isBuffering = false,
  });

  double get progress {
    final total = duration.inMilliseconds;
    if (total <= 0) {
      return 0;
    }
    return (position.inMilliseconds / total).clamp(0, 1);
  }
}
