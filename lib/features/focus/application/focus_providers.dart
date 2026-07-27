import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../domain/focus_session.dart';

/// Session store: the list of completed/interrupted sessions.
/// Backed by SQLite (Sprint 4): loads existing sessions from the database
/// on start, and persists every new one — so a session survives an app
/// restart. The public interface (a list you can `add` to) hasn't changed,
/// only what happens behind it.
class FocusSessionStore extends StateNotifier<List<FocusSession>> {
  FocusSessionStore() : super(const []) {
    _load();
  }

  Future<void> _load() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('focus_sessions', orderBy: 'id ASC');
    state = rows.map(FocusSession.fromMap).toList();
  }

  /// Optimistic update: the UI reflects the new session immediately,
  /// the write to disk happens right after.
  Future<void> add(FocusSession session) async {
    state = [...state, session];
    final db = await AppDatabase.instance.database;
    await db.insert('focus_sessions', session.toMap());
  }
}

final focusSessionsProvider =
    StateNotifierProvider<FocusSessionStore, List<FocusSession>>(
  (ref) => FocusSessionStore(),
);

/// Total minutes spent focusing today — the Dashboard's
/// "Focus time today" card reads this real, now-persisted value.
final todayFocusMinutesProvider = Provider<int>((ref) {
  final sessions = ref.watch(focusSessionsProvider);
  return sessions
      .where((s) => s.isToday)
      .fold(0, (sum, s) => sum + s.elapsedMinutes);
});
