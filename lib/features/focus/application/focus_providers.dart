import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/focus_session.dart';

/// Session store: the list of completed/interrupted sessions.
/// I used StateNotifier so that listening screens like the Dashboard
/// update automatically when a new record is added.
/// In Sprint 4 the internals of this class will switch to SQLite read/write,
/// while the interface it exposes stays the same.
class FocusSessionStore extends StateNotifier<List<FocusSession>> {
  FocusSessionStore() : super(const []);

  void add(FocusSession session) => state = [...state, session];
}

final focusSessionsProvider =
    StateNotifierProvider<FocusSessionStore, List<FocusSession>>(
  (ref) => FocusSessionStore(),
);

/// Total minutes spent focusing today — the Dashboard's
/// "Focus time today" card now reads this real value.
final todayFocusMinutesProvider = Provider<int>((ref) {
  final sessions = ref.watch(focusSessionsProvider);
  return sessions
      .where((s) => s.isToday)
      .fold(0, (sum, s) => sum + s.elapsedMinutes);
});
