/// Bir Academy dersinin modeli.
/// İçerik şimdilik uygulamayla birlikte gelen örnek metinler;
/// gerçek içerik yönetimi (uzaktan içerik/CMS) staj kapsamı dışında,
/// Sprint 4'te SQLite'a okuma ilerlemesi ve yer imleri kaydedilecek.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.category,
    required this.minutes,
    required this.summary,
    required this.paragraphs,
  });

  final String id;
  final String title;
  final String category;
  final int minutes; // tahmini okuma süresi
  final String summary;
  final List<String> paragraphs;
}
