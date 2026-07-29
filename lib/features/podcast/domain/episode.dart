/// The model of a podcast episode.
/// Each lesson's episode is recorded in two parts; [audioAsset] points to
/// the bundled file (see pubspec.yaml assets) and [part] orders them under
/// the lesson (1 then 2).
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
    required this.audioAsset,
    required this.part,
  });

  final String id;
  final String title;
  final String host;
  final int seconds; // total duration
  final String description;
  final String series;
  final String category; // shared with Academy lesson categories
  final String lessonId; // the lesson this episode belongs to
  final String audioAsset; // bundled asset path, played via just_audio
  final int part; // 1 or 2 — display order under the lesson

  String get durationLabel {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
