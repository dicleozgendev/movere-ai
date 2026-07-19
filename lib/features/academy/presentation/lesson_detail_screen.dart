import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/movere_navigation.dart';
import '../application/academy_providers.dart';
import '../domain/lesson.dart';

/// Ders detayı: içerik + kaydırmaya bağlı okuma ilerlemesi.
/// İlerleme mantığı: kullanıcının ulaştığı en derin kaydırma noktası
/// 0..1 aralığına oranlanıp store'a yazılır (store yalnızca ileri
/// gidişi kaydeder — geri kaydırmak ilerlemeyi düşürmez).
/// %95 ve üzeri "okundu" sayılır; üstteki ince bar canlı ilerler.
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
    // İçerik ekrana sığıyorsa (kaydırma yoksa) açılışı okundu say.
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
          // Okuma ilerlemesi: içerikle birlikte canlı dolan ince bar.
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
