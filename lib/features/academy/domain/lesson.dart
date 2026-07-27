/// The model of an Academy lesson.
/// Content is sample text shipped with the app for now;
/// real content management (remote content/CMS) is out of internship scope,
/// reading progress and bookmarks are saved to SQLite (Sprint 4).
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
  final int minutes; // estimated reading time
  final String summary;
  final List<String> paragraphs;
}
