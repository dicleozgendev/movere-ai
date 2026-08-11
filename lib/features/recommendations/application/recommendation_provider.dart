import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../academy/application/academy_providers.dart';
import '../../focus/application/focus_providers.dart';
import '../../podcast/application/podcast_providers.dart';

/// Where an insight's action button should navigate.
enum RecommendationTarget { focus, academy, academyLesson, podcast }

/// Whether an insight currently needs the user's attention, or is just
/// good-news confirmation that this area is already on track.
enum InsightStatus { actionable, positive }

/// Which category an insight belongs to, and which of its two possible
/// states (needs attention / already good) it's in — the actual English/
/// Turkish text is generated from this in the widget layer (it needs a
/// BuildContext for AppLocalizations, which this data-only class
/// deliberately doesn't carry). Dynamic numbers/names ride along
/// separately (todayMinutes, lessonTitle, progressPercent).
enum InsightKind {
  focusNone,
  focusActive,
  readingActionable,
  readingPositive,
  listeningActionable,
  listeningPositive,
  exploreActionable,
  explorePositive,
}

/// One line of the assistant's read on the user's day, covering exactly
/// one category (Focus / Reading / Listening / Explore). The AI tab
/// always shows all four, so the user sees the full picture, not just
/// whichever one rule happened to win.
class AiInsight {
  const AiInsight({
    required this.kind,
    required this.icon,
    required this.status,
    this.target,
    this.lessonId,
    this.todayMinutes,
    this.lessonTitle,
    this.progressPercent,
  });

  final InsightKind kind;
  final IconData icon;
  final InsightStatus status;
  final RecommendationTarget? target;
  final String? lessonId; // set for academyLesson/podcast targets
  final int? todayMinutes; // for focusActive
  final String? lessonTitle; // for reading/exploreActionable
  final int? progressPercent; // for readingActionable
}

/// AI Recommendation Prototype (Sprint 5): a lightweight, rule-based
/// engine — not a trained model — reading the same local data the rest
/// of the app already collects to produce one insight per category,
/// always four, so the AI tab reads like a real assistant's daily
/// briefing rather than a single nagging pop-up.
final aiInsightsProvider = Provider<List<AiInsight>>((ref) {
  final todayMinutes = ref.watch(todayFocusMinutesProvider);
  final readingProgress = ref.watch(readingProgressProvider);
  final listened = ref.watch(listenedProvider);

  // --- 1. Focus ---
  final focusInsight = todayMinutes == 0
      ? const AiInsight(
          kind: InsightKind.focusNone,
          icon: Icons.bolt,
          status: InsightStatus.actionable,
          target: RecommendationTarget.focus,
        )
      : AiInsight(
          kind: InsightKind.focusActive,
          icon: Icons.bolt,
          status: InsightStatus.positive,
          todayMinutes: todayMinutes,
        );

  // --- 2. Reading (a lesson started but not finished) ---
  final inProgress = readingProgress.entries
      .where((e) => e.value > 0.05 && e.value < 0.95)
      .toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final inProgressLesson = inProgress.isEmpty
      ? null
      : lessons.where((l) => l.id == inProgress.first.key).firstOrNull;

  final readingInsight = inProgressLesson != null
      ? AiInsight(
          kind: InsightKind.readingActionable,
          icon: Icons.menu_book_outlined,
          status: InsightStatus.actionable,
          target: RecommendationTarget.academyLesson,
          lessonId: inProgressLesson.id,
          lessonTitle: inProgressLesson.title,
          progressPercent: (inProgress.first.value * 100).round(),
        )
      : const AiInsight(
          kind: InsightKind.readingPositive,
          icon: Icons.menu_book_outlined,
          status: InsightStatus.positive,
        );

  // --- 3. Listening (a read lesson whose episodes are unheard) ---
  String? unheardLessonId;
  for (final lessonId in readingProgress.keys) {
    if ((readingProgress[lessonId] ?? 0) < 0.95) continue;
    final unheard =
        episodesForLesson(lessonId).where((e) => !listened.contains(e.id));
    if (unheard.isNotEmpty) {
      unheardLessonId = lessonId;
      break;
    }
  }
  final listeningInsight = unheardLessonId != null
      ? AiInsight(
          kind: InsightKind.listeningActionable,
          icon: Icons.headphones_outlined,
          status: InsightStatus.actionable,
          target: RecommendationTarget.podcast,
          lessonId: unheardLessonId,
        )
      : const AiInsight(
          kind: InsightKind.listeningPositive,
          icon: Icons.headphones_outlined,
          status: InsightStatus.positive,
        );

  // --- 4. Explore (always available, lightest-touch nudge) ---
  final unstarted =
      lessons.where((l) => (readingProgress[l.id] ?? 0) < 0.05).toList();
  final exploreInsight = unstarted.isNotEmpty
      ? AiInsight(
          kind: InsightKind.exploreActionable,
          icon: Icons.auto_awesome,
          status: InsightStatus.actionable,
          target: RecommendationTarget.academy,
          lessonTitle: unstarted.first.title,
        )
      : const AiInsight(
          kind: InsightKind.explorePositive,
          icon: Icons.auto_awesome,
          status: InsightStatus.positive,
        );

  return [focusInsight, readingInsight, listeningInsight, exploreInsight];
});

/// The single most relevant insight, in priority order — used for the
/// compact teaser shown on the Home tab, which deep-links into the full
/// AI tab for the other three.
final topRecommendationProvider = Provider<AiInsight>((ref) {
  final insights = ref.watch(aiInsightsProvider);
  return insights.firstWhere(
    (i) => i.status == InsightStatus.actionable,
    orElse: () => insights.last,
  );
});
