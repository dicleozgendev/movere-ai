import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../academy/application/academy_providers.dart';
import '../../focus/application/focus_providers.dart';

/// Reality Score: a single 0–100 number that summarises how the user is
/// actually doing today, computed from data we already collect — not a
/// fixed placeholder. Three signals, weighted:
///
///  - 50% Daily focus goal: today's focus minutes vs. the daily goal.
///  - 30% Session follow-through: of the sessions started in the last 7
///    days, how many were completed rather than given up on.
///  - 20% Learning engagement: average reading progress across lessons
///    the user has actually opened.
///
/// Each sub-score is exposed too, so the Dashboard card can explain the
/// number instead of just showing it.
class RealityScore {
  const RealityScore({
    required this.value,
    required this.focusGoalRatio,
    required this.completionRatio,
    required this.learningRatio,
  });

  final int value; // 0..100, the headline number
  final double focusGoalRatio; // 0..1
  final double completionRatio; // 0..1
  final double learningRatio; // 0..1

  /// Which message band the current score falls in — the actual text is
  /// picked in the widget layer (AppLocalizations needs a BuildContext,
  /// which this plain data class deliberately doesn't have).
  RealityScoreBand get band {
    if (value >= 75) return RealityScoreBand.strong;
    if (value >= 50) return RealityScoreBand.good;
    if (value >= 25) return RealityScoreBand.slow;
    return RealityScoreBand.none;
  }
}

enum RealityScoreBand { strong, good, slow, none }

const _dailyGoalMinutes = 210; // 3h 30m, same goal shown on the focus card

final realityScoreProvider = Provider<RealityScore>((ref) {
  final sessions = ref.watch(focusSessionsProvider);
  final todayMinutes = ref.watch(todayFocusMinutesProvider);
  final readingProgress = ref.watch(readingProgressProvider);

  // Signal 1: today's focus goal.
  final focusGoalRatio =
      (todayMinutes / _dailyGoalMinutes).clamp(0.0, 1.0).toDouble();

  // Signal 2: of the sessions started in the last 7 days, what fraction
  // were actually completed (not given up on).
  final weekAgo = DateTime.now().subtract(const Duration(days: 7));
  final recentSessions =
      sessions.where((s) => s.startedAt.isAfter(weekAgo)).toList();
  final completionRatio = recentSessions.isEmpty
      ? 0.0
      : recentSessions.where((s) => s.completed).length /
          recentSessions.length;

  // Signal 3: average reading progress across lessons the user has
  // actually opened (lessons never opened don't drag the average down —
  // starting nothing isn't the same as failing at something).
  final learningRatio = readingProgress.isEmpty
      ? 0.0
      : (readingProgress.values.reduce((a, b) => a + b) /
              readingProgress.length)
          .clamp(0.0, 1.0);

  final composite =
      focusGoalRatio * 0.5 + completionRatio * 0.3 + learningRatio * 0.2;

  return RealityScore(
    value: (composite * 100).round().clamp(0, 100),
    focusGoalRatio: focusGoalRatio,
    completionRatio: completionRatio,
    learningRatio: learningRatio,
  );
});
