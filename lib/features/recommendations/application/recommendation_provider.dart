import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../academy/application/academy_providers.dart';
import '../../focus/application/focus_providers.dart';
import '../../podcast/application/podcast_providers.dart';

/// Where an insight's action button should navigate.
enum RecommendationTarget { focus, academy, academyLesson, podcast }

/// Whether an insight currently needs the user's attention, or is just
/// good-news confirmation that this area is already on track. An AI
/// assistant that only ever says "do this!" feels naggy — one that also
/// confirms what's already going well feels like it's actually paying
/// attention.
enum InsightStatus { actionable, positive }

/// One line of the assistant's read on the user's day, covering exactly
/// one category (Focus / Reading / Listening / Explore). The AI tab
/// always shows all four, so the user sees the full picture, not just
/// whichever one rule happened to win.
class AiInsight {
  const AiInsight({
    required this.category,
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    this.actionLabel,
    this.target,
    this.lessonId,
  });

  final String category;
  final IconData icon;
  final String title;
  final String description;
  final InsightStatus status;
  final String? actionLabel;
  final RecommendationTarget? target;
  final String? lessonId; // set for academyLesson/podcast targets
}

/// AI Recommendation Prototype (Sprint 5): a lightweight, rule-based
/// engine — not a trained model — reading the same local data the rest
/// of the app already collects (today's focus minutes, reading progress,
/// listened episodes) to produce one insight per category, always four,
/// so the AI tab reads like a real assistant's daily briefing rather than
/// a single nagging pop-up.
///
/// Deliberately a *prototype*: heuristics over real data now, on the same
/// signals a future ML-based version would train on if the rules turn
/// out not to be good enough on their own.
final aiInsightsProvider = Provider<List<AiInsight>>((ref) {
  final todayMinutes = ref.watch(todayFocusMinutesProvider);
  final readingProgress = ref.watch(readingProgressProvider);
  final listened = ref.watch(listenedProvider);

  // --- 1. Focus ---
  final focusInsight = todayMinutes == 0
      ? const AiInsight(
          category: 'Focus',
          icon: Icons.bolt,
          title: 'No focus time logged yet today',
          description:
              'A single Quick (15 min) session is enough to get today\'s '
              'momentum going.',
          status: InsightStatus.actionable,
          actionLabel: 'Start Focus',
          target: RecommendationTarget.focus,
        )
      : AiInsight(
          category: 'Focus',
          icon: Icons.bolt,
          title: '$todayMinutes min focused today',
          description: 'Nice work — today\'s focus goal is already moving.',
          status: InsightStatus.positive,
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
          category: 'Reading',
          icon: Icons.menu_book_outlined,
          title: '"${inProgressLesson.title}" is '
              '${(inProgress.first.value * 100).round()}% read',
          description: 'A few more minutes and it\'s done.',
          status: InsightStatus.actionable,
          actionLabel: 'Continue Reading',
          target: RecommendationTarget.academyLesson,
          lessonId: inProgressLesson.id,
        )
      : const AiInsight(
          category: 'Reading',
          icon: Icons.menu_book_outlined,
          title: 'Nothing left half-read',
          description: 'No lesson is sitting unfinished right now.',
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
          category: 'Listening',
          icon: Icons.headphones_outlined,
          title: 'A finished lesson still has audio to hear',
          description:
              'The podcast version adds a second angle in a few minutes.',
          status: InsightStatus.actionable,
          actionLabel: 'Open Podcast',
          target: RecommendationTarget.podcast,
          lessonId: unheardLessonId,
        )
      : const AiInsight(
          category: 'Listening',
          icon: Icons.headphones_outlined,
          title: 'All caught up on podcasts',
          description: 'Nothing unheard from the lessons you\'ve finished.',
          status: InsightStatus.positive,
        );

  // --- 4. Explore (always available, lightest-touch nudge) ---
  final unstarted =
      lessons.where((l) => (readingProgress[l.id] ?? 0) < 0.05).toList();
  final exploreInsight = unstarted.isNotEmpty
      ? AiInsight(
          category: 'Explore',
          icon: Icons.auto_awesome,
          title: '"${unstarted.first.title}" is still unopened',
          description: 'Worth a look next time you have five minutes.',
          status: InsightStatus.actionable,
          actionLabel: 'Open Academy',
          target: RecommendationTarget.academy,
        )
      : const AiInsight(
          category: 'Explore',
          icon: Icons.auto_awesome,
          title: 'You\'ve opened every lesson',
          description: 'Revisit any of them any time from the Academy tab.',
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
