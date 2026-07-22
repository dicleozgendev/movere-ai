import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/movere_card.dart';
import '../application/academy_providers.dart';
import '../domain/lesson.dart';
import 'lesson_detail_screen.dart';

/// Academy tab — "Explore. Understand. Transform."
/// Design reference: the Movere Academy mockup (numbered cards,
/// mini illustrations, duration + arrow button).
/// Bookmark and reading progress are read live from Riverpod stores.
class AcademyScreen extends ConsumerStatefulWidget {
  const AcademyScreen({super.key});

  @override
  ConsumerState<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends ConsumerState<AcademyScreen> {
  String? _category; // null = All

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    final bookmarks = ref.watch(bookmarksProvider);
    final progress = ref.watch(readingProgressProvider);

    final categories = {for (final l in lessons) l.category}.toList()..sort();
    final visible = _category == null
        ? lessons
        : lessons.where((l) => l.category == _category).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        AppConstants.spacingMd,
        AppConstants.spacingLg,
        AppConstants.spacingLg,
      ),
      children: [
        // --- Title block (like in the mockup) ---
        Text(
          'MOVERE ACADEMY',
          style: textTheme.labelSmall?.copyWith(
            color: primary,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text('Explore. Understand. Transform.',
            style: textTheme.displayMedium,),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          'Understanding the digital world is the first step '
          'to reclaiming your attention.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppConstants.spacingLg),

        // --- Category filter ---
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _CategoryChip(
                label: 'All',
                selected: _category == null,
                onTap: () => setState(() => _category = null),
              ),
              for (final c in categories)
                _CategoryChip(
                  label: c,
                  selected: _category == c,
                  onTap: () => setState(() => _category = c),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // --- Lesson cards ---
        for (final lesson in visible)
          _LessonCard(
            lesson: lesson,
            // The number and illustration come from the position in the full list;
            // even if a filter is applied, the lesson's number doesn't change.
            order: lessons.indexOf(lesson) + 1,
            bookmarked: bookmarks.contains(lesson.id),
            progress: progress[lesson.id] ?? 0,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LessonDetailScreen(lesson: lesson),
              ),
            ),
            onBookmark: () =>
                ref.read(bookmarksProvider.notifier).toggle(lesson.id),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.spacingSm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? primary.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: selected ? primary : Theme.of(context).dividerColor,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? primary : null,
                ),
          ),
        ),
      ),
    );
  }
}

/// A single lesson card: number + illustration + text + duration/arrow.
class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.order,
    required this.bookmarked,
    required this.progress,
    required this.onTap,
    required this.onBookmark,
  });

  final Lesson lesson;
  final int order;
  final bool bookmarked;
  final double progress;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    final done = progress >= 0.95;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: MovereCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Number: 01, 02...
                Text(
                  order.toString().padLeft(2, '0'),
                  style: textTheme.titleLarge?.copyWith(color: primary),
                ),
                const SizedBox(width: AppConstants.spacingMd),

                // Mini illustration
                _LessonIllustration(
                  art: _LessonArt.values[(order - 1) % _LessonArt.values.length],
                ),
                const SizedBox(width: AppConstants.spacingMd),

                // Title + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lesson.title, style: textTheme.titleMedium),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        lesson.summary,
                        style: textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSm),

                // Duration + bookmark + arrow
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 15,
                          color: textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(width: AppConstants.spacingXs),
                        Text(
                          '${lesson.minutes} min',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(width: AppConstants.spacingXs),
                        GestureDetector(
                          onTap: onBookmark,
                          child: Icon(
                            bookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_outline,
                            size: 18,
                            color: bookmarked
                                ? primary
                                : textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primary.withValues(alpha: 0.5),
                        ),
                      ),
                      child:
                          Icon(Icons.arrow_forward, size: 18, color: primary),
                    ),
                  ],
                ),
              ],
            ),

            // Reading progress (a thin bar under the card, if any)
            if (progress > 0) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Text(
                    done ? 'Read' : '${(progress * 100).round()}%',
                    style: textTheme.labelSmall?.copyWith(
                      color: done ? primary : null,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The abstract mini-illustration variants on the card (the drawings from the mockup).
enum _LessonArt { orbit, lines, radar, squares, dots }

/// 56x56 CustomPaint illustration.
class _LessonIllustration extends StatelessWidget {
  const _LessonIllustration({required this.art});

  final _LessonArt art;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: CustomPaint(
        painter: _LessonArtPainter(
          art: art,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _LessonArtPainter extends CustomPainter {
  const _LessonArtPainter({required this.art, required this.color});

  final _LessonArt art;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withValues(alpha: 0.45);
    final fill = Paint()..color = color;

    switch (art) {
      // Notifications: orbit rings + neon dot.
      case _LessonArt.orbit:
        canvas.drawCircle(center, 10, stroke);
        canvas.drawCircle(center, 18, stroke);
        canvas.drawCircle(center, 26, stroke);
        canvas.drawCircle(center + const Offset(13, -13), 5, fill);

      // Infinite scroll: vertical lines flowing downward + arrowhead.
      case _LessonArt.lines:
        for (var i = 0; i < 5; i++) {
          final x = 8.0 + i * 10;
          final fade = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = color.withValues(alpha: 0.15 + i * 0.1);
          canvas.drawLine(Offset(x, 6), Offset(x, 50), fade);
        }
        final arrow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = color.withValues(alpha: 0.8);
        canvas.drawLine(const Offset(28, 34), const Offset(28, 50), arrow);
        canvas.drawLine(const Offset(23, 44), const Offset(28, 50), arrow);
        canvas.drawLine(const Offset(33, 44), const Offset(28, 50), arrow);

      // Deep work: center dot + focus rings + root line.
      case _LessonArt.radar:
        canvas.drawCircle(center, 8, stroke);
        canvas.drawCircle(center, 16, stroke);
        canvas.drawCircle(center, 24, stroke);
        canvas.drawCircle(center, 3.5, fill);
        canvas.drawLine(center, Offset(center.dx, size.height), stroke);

      // Digital minimalism: nested squares + filled core.
      case _LessonArt.squares:
        for (final s in [40.0, 28.0, 16.0]) {
          canvas.drawRect(
            Rect.fromCenter(center: center, width: s, height: s),
            stroke,
          );
        }
        canvas.drawRect(
          Rect.fromCenter(center: center, width: 6, height: 6),
          fill,
        );

      // Algorithms: a grid of dots glowing toward the center.
      case _LessonArt.dots:
        for (var r = 0; r < 5; r++) {
          for (var c = 0; c < 5; c++) {
            final p = Offset(8.0 + c * 10, 8.0 + r * 10);
            final d = (p - center).distance;
            canvas.drawCircle(
              p,
              d < 12 ? 2.2 : 1.4,
              Paint()
                ..color = color.withValues(
                  alpha: (1 - d / 40).clamp(0.15, 0.9).toDouble(),
                ),
            );
          }
        }
    }
  }

  @override
  bool shouldRepaint(_LessonArtPainter old) =>
      old.art != art || old.color != color;
}
