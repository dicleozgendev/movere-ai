import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/focus_session.dart';

/// Seans deposu: tamamlanan/yarıda kalan seansların listesi.
/// StateNotifier kullandım ki Dashboard gibi dinleyen ekranlar
/// yeni kayıt eklenince otomatik güncellensin.
/// Sprint 4'te bu sınıfın içi SQLite okuma/yazmasıyla değişecek,
/// dışarıya verdiği arayüz aynı kalacak.
class FocusSessionStore extends StateNotifier<List<FocusSession>> {
  FocusSessionStore() : super(const []);

  void add(FocusSession session) => state = [...state, session];
}

final focusSessionsProvider =
    StateNotifierProvider<FocusSessionStore, List<FocusSession>>(
  (ref) => FocusSessionStore(),
);

/// Bugün odakta geçirilen toplam dakika — Dashboard'daki
/// "Focus time today" kartı artık bu gerçek değeri okuyor.
final todayFocusMinutesProvider = Provider<int>((ref) {
  final sessions = ref.watch(focusSessionsProvider);
  return sessions
      .where((s) => s.isToday)
      .fold(0, (sum, s) => sum + s.elapsedMinutes);
});
