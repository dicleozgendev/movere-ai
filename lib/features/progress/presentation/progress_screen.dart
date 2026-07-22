import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/movere_card.dart';
import '../../focus/application/focus_providers.dart';
import '../../focus/domain/focus_session.dart';

/// Progress tab: weekly focus stats + session history.
/// Data source is Focus Mode's session store — when a new session is saved
/// this screen updates itself too (thanks to watch).
/// The chart was intentionally hand-drawn (Container bars):
/// without adding an external chart package, using theme colors.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final sessions = ref.watch(focusSessionsProvider);

    // Total minutes per day for the last 7 days (going backward, including today).
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final minutes = sessions
          .where((s) =>
              s.startedAt.year == d.year &&
              s.startedAt.month == d.month &&
              s.startedAt.day == d.day,)
          .fold<int>(0, (sum, s) => sum + s.elapsedMinutes);
      return (date: d, minutes: minutes);
    });
    final weekTotal = days.fold<int>(0, (sum, d) => sum + d.minutes);
    final completedCount = sessions.where((s) => s.completed).length;
    final maxMinutes =
        days.fold<int>(0, (m, d) => d.minutes > m ? d.minutes : m);

    if (sessions.isEmpty) {
      return _EmptyState(textTheme: textTheme);
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: [
        Text('Your Progress', style: textTheme.displayMedium),
        const SizedBox(height: 4),
        Text('Focus adds up. Here is your week.', style: textTheme.bodyMedium),
        const SizedBox(height: AppConstants.spacingLg),

        // --- Weekly summary card ---
        MovereCard(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Metric(label: 'This week', value: _format(weekTotal)),
              _Metric(label: 'Sessions', value: '${sessions.length}'),
              _Metric(label: 'Completed', value: '$completedCount'),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // --- Last 7 days bar chart ---
        MovereCard(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last 7 days', style: textTheme.titleMedium),
              const SizedBox(height: AppConstants.spacingLg),
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final d in days)
                      Expanded(
                        child: _DayBar(
                          minutes: d.minutes,
                          maxMinutes: maxMinutes,
                          label: _dayNames[d.date.weekday - 1],
                          isToday: d.date.day == now.day &&
                              d.date.month == now.month,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // --- Session history ---
        Text('Recent sessions', style: textTheme.titleMedium),
        const SizedBox(height: AppConstants.spacingSm),
        for (final s in sessions.reversed.take(10)) _SessionTile(session: s),
      ],
    );
  }

  static String _format(int m) =>
      m >= 60 ? '${m ~/ 60}h ${(m % 60).toString().padLeft(2, '0')}m' : '${m}m';
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

/// A single day's bar: height is proportional to that day's minutes.
class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.minutes,
    required this.maxMinutes,
    required this.label,
    required this.isToday,
  });

  final int minutes;
  final int maxMinutes;
  final String label;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    // Scale so the highest day is 90px; an empty day shows a thin trace.
    final height =
        maxMinutes == 0 ? 4.0 : (minutes / maxMinutes * 90).clamp(4.0, 90.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (minutes > 0)
            Text('$minutes',
                style: Theme.of(context).textTheme.labelSmall,),
          const SizedBox(height: 2),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: minutes == 0
                  ? primary.withValues(alpha: 0.12)
                  : primary.withValues(alpha: isToday ? 1 : 0.55),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// A single session row in the history list.
class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final FocusSession session;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    final t = session.startedAt;
    final time =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: MovereCard(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          children: [
            Icon(
              session.completed
                  ? Icons.check_circle_outline
                  : Icons.timelapse_outlined,
              color: session.completed
                  ? primary
                  : textTheme.labelSmall?.color,
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${session.elapsedMinutes} min focus',
                    style: textTheme.titleMedium,
                  ),
                  Text(
                    session.completed
                        ? 'Completed · started $time'
                        : 'Ended early · started $time'
                            '${session.interruptions > 0 ? ' · ${session.interruptions} interruption(s)' : ''}',
                    style: textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An honest empty state shown when there are no sessions.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insights_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text('No sessions yet', style: textTheme.headlineMedium),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Complete your first focus session and your weekly '
              'progress will appear here.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
