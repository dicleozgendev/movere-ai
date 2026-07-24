import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/movere_card.dart';
import '../../../core/widgets/movere_navigation.dart';
import '../../podcast/application/podcast_providers.dart';
import '../../podcast/presentation/player_screen.dart';
import '../application/academy_providers.dart';
import '../domain/lesson.dart';

/// Lesson detail: content + scroll-based reading progress.
/// Progress logic: the deepest scroll point the user reaches
/// is scaled to the 0..1 range and written to the store (the store only records
/// forward movement — scrolling back doesn't lower progress).
/// 95% and above counts as "read"; the thin bar at the top advances live.
class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  ConsumerState<LessonDetailScreen> createState() =>
      _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // If the content fits the screen (no scrolling), count the opening as read.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients && _scroll.position.maxScrollExtent <= 0) {
        ref
            .read(readingProgressProvider.notifier)
            .update(widget.lesson.id, 1);
      }
    });
  }

  void _onScroll() {
    final max = _scroll.position.maxScrollExtent;
    if (max <= 0) return;
    final value = (_scroll.offset / max).clamp(0.0, 1.0);
    ref.read(readingProgressProvider.notifier).update(widget.lesson.id, value);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    final bookmarked =
        ref.watch(bookmarksProvider).contains(widget.lesson.id);
    final progress =
        ref.watch(readingProgressProvider)[widget.lesson.id] ?? 0;

    return Scaffold(
      appBar: MovereAppBar(
        title: widget.lesson.category,
        actions: [
          IconButton(
            tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark this lesson',
            icon: Icon(
              bookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: bookmarked ? primary : null,
            ),
            onPressed: () =>
                ref.read(bookmarksProvider.notifier).toggle(widget.lesson.id),
          ),
        ],
      ),
      body: Column(
        children: [
          // Reading progress: a thin bar that fills live along with the content.
          LinearProgressIndicator(value: progress, minHeight: 3),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              children: [
                Text(widget.lesson.title, style: textTheme.displayMedium),
                const SizedBox(height: 4),
                Text(
                  '${widget.lesson.minutes} min read',
                  style: textTheme.labelSmall?.copyWith(color: primary),
                ),
                const SizedBox(height: AppConstants.spacingLg),
                for (final p in widget.lesson.paragraphs) ...[
                  Text(
                    p,
                    style: textTheme.bodyMedium?.copyWith(height: 1.7),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                ],
                const SizedBox(height: AppConstants.spacingLg),
                // The podcast version of this lesson, right under the text:
                // read it or listen to it — same content, two formats.
                if (episodeForLesson(widget.lesson.id) != null) ...[
                  const Divider(height: AppConstants.spacingXl),
                  Text('Listen to this lesson', style: textTheme.titleMedium),
                  const SizedBox(height: AppConstants.spacingSm),
                  MovereCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(
                          episode: episodeForLesson(widget.lesson.id)!,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusMd),
                          ),
                          child: Icon(Icons.play_arrow, color: primary),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                episodeForLesson(widget.lesson.id)!.title,
                                style: textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'PODCAST \u00b7 '
                                '${episodeForLesson(widget.lesson.id)!.durationLabel}',
                                style: textTheme.labelSmall
                                    ?.copyWith(color: primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                ],
                if (progress >= 0.95)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, color: primary),
                      const SizedBox(width: AppConstants.spacingSm),
                      Text(
                        'Lesson completed',
                        style:
                            textTheme.titleMedium?.copyWith(color: primary),
                      ),
                    ],
                  ),
                const SizedBox(height: AppConstants.spacingXl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
