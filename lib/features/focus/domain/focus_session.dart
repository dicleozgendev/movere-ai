/// The record of a focus session.
/// Maps one-to-one to the focus_sessions SQLite table via [toMap]/[fromMap];
/// kept in the domain folder so the model stays independent of the data layer.
class FocusSession {
  const FocusSession({
    required this.startedAt,
    required this.plannedMinutes,
    required this.elapsedMinutes,
    required this.completed,
    required this.interruptions,
  });

  final DateTime startedAt;
  final int plannedMinutes; // target duration
  final int elapsedMinutes; // time actually spent focusing
  final bool completed; // did it end by the timer running out, or was it stopped early
  final int interruptions; // how many times the app was left during the session

  bool get isToday {
    final now = DateTime.now();
    return startedAt.year == now.year &&
        startedAt.month == now.month &&
        startedAt.day == now.day;
  }

  Map<String, Object?> toMap() => {
        'started_at': startedAt.toIso8601String(),
        'planned_minutes': plannedMinutes,
        'elapsed_minutes': elapsedMinutes,
        'completed': completed ? 1 : 0,
        'interruptions': interruptions,
      };

  factory FocusSession.fromMap(Map<String, Object?> map) => FocusSession(
        startedAt: DateTime.parse(map['started_at'] as String),
        plannedMinutes: map['planned_minutes'] as int,
        elapsedMinutes: map['elapsed_minutes'] as int,
        completed: (map['completed'] as int) == 1,
        interruptions: map['interruptions'] as int,
      );
}
