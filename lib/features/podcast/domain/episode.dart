/// The model of a podcast episode.
/// Episode content is authored separately; this model carries only the
/// metadata the interface needs. When real audio files are ready, an
/// [audioUrl] can be added here and the player connected to it —
/// no screen changes will be required.
class Episode {
  const Episode({
    required this.id,
    required this.title,
    required this.host,
    required this.seconds,
    required this.description,
    required this.series,
    required this.category,
    required this.lessonId,
  });

  final String id;
  final String title;
  final String host;
  final int seconds; // total duration
  final String description;
  final String series;
  final String category; // shared with Academy lesson categories
  final String lessonId; // the lesson this episode belongs to

  String get durationLabel {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
