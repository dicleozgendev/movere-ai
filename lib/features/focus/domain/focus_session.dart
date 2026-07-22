/// The record of a focus session.
/// Kept in memory for now; in Sprint 4 it will map one-to-one to a SQLite table
/// with these fields (kept in the domain folder so the model stays independent
/// of the data layer).
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
}
