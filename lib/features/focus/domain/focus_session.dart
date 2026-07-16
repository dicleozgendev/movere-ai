/// Bir odak seansının kaydı.
/// Şimdilik bellekte tutuluyor; Sprint 4'te SQLite tablosuna birebir
/// bu alanlarla taşınacak (model, veri katmanından bağımsız dursun diye
/// domain klasöründe).
class FocusSession {
  const FocusSession({
    required this.startedAt,
    required this.plannedMinutes,
    required this.elapsedMinutes,
    required this.completed,
    required this.interruptions,
  });

  final DateTime startedAt;
  final int plannedMinutes; // hedeflenen süre
  final int elapsedMinutes; // fiilen odakta geçen süre
  final bool completed; // süre dolarak mı bitti, yarıda mı bırakıldı
  final int interruptions; // seans sırasında uygulamadan kaç kez çıkıldı

  bool get isToday {
    final now = DateTime.now();
    return startedAt.year == now.year &&
        startedAt.month == now.month &&
        startedAt.day == now.day;
  }
}
