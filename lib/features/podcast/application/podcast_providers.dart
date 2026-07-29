import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/episode.dart';

/// Episodes recorded for the Academy lessons — two parts each, played from
/// bundled audio (see pubspec.yaml assets and lib/features/podcast for the
/// player). Durations are measured from the actual recordings.
const episodes = <Episode>[
  // --- Why Are Notifications Addictive? ---
  Episode(
    id: 'ep-notifications-1',
    description: 'Why every notification pulls at your attention — the psychology of the pull, part one.',
    title: 'The Notification Loop',
    host: 'Movere',
    seconds: 252,
    series: 'Season 1 · Digital Awareness',
    category: 'Digital Awareness',
    lessonId: 'notification-addiction',
    audioAsset: 'assets/audio/notifications_part1.m4a',
    part: 1,
  ),
  Episode(
    id: 'ep-notifications-2',
    description: 'The second half: how the notification loop keeps repeating, and how to interrupt it.',
    title: 'Breaking the Loop',
    host: 'Movere',
    seconds: 162,
    series: 'Season 1 · Digital Awareness',
    category: 'Digital Awareness',
    lessonId: 'notification-addiction',
    audioAsset: 'assets/audio/notifications_part2.m4a',
    part: 2,
  ),

  // --- How Do Social Media Algorithms Work? ---
  Episode(
    id: 'ep-algorithms-1',
    description: 'What is really happening behind your feed — how algorithms read your behavior.',
    title: 'Behind the Feed',
    host: 'Movere',
    seconds: 189,
    series: 'Season 1 · Digital Awareness',
    category: 'Digital Awareness',
    lessonId: 'social-algorithms',
    audioAsset: 'assets/audio/algorithms_part1.m4a',
    part: 1,
  ),
  Episode(
    id: 'ep-algorithms-2',
    description: 'The second half: echo chambers, engagement, and who the attention really serves.',
    title: 'Who the Feed Serves',
    host: 'Movere',
    seconds: 262,
    series: 'Season 1 · Digital Awareness',
    category: 'Digital Awareness',
    lessonId: 'social-algorithms',
    audioAsset: 'assets/audio/algorithms_part2.m4a',
    part: 2,
  ),

  // --- Digital Minimalism ---
  Episode(
    id: 'ep-minimalism-1',
    description: 'A calmer approach to technology — deciding deliberately what belongs in your life.',
    title: 'Choosing on Purpose',
    host: 'Movere',
    seconds: 193,
    series: 'Season 1 · Life Design',
    category: 'Life Design',
    lessonId: 'digital-minimalism',
    audioAsset: 'assets/audio/minimalism_part1.m4a',
    part: 1,
  ),
  Episode(
    id: 'ep-minimalism-2',
    description: 'The second half: turning digital minimalism from an idea into a daily practice.',
    title: 'Making It a Practice',
    host: 'Movere',
    seconds: 320,
    series: 'Season 1 · Life Design',
    category: 'Life Design',
    lessonId: 'digital-minimalism',
    audioAsset: 'assets/audio/minimalism_part2.m4a',
    part: 2,
  ),

  // --- What Is Deep Work? ---
  Episode(
    id: 'ep-deepwork-1',
    description: 'Why focused, undistracted work is a skill worth building — and why it is getting rarer.',
    title: 'The Rare Skill',
    host: 'Movere',
    seconds: 181,
    series: 'Season 1 · Deep Focus',
    category: 'Deep Focus',
    lessonId: 'deep-work',
    audioAsset: 'assets/audio/deepwork_part1.m4a',
    part: 1,
  ),
  Episode(
    id: 'ep-deepwork-2',
    description: 'The second half: practical habits that make deep work sessions stick.',
    title: 'Building the Habit',
    host: 'Movere',
    seconds: 144,
    series: 'Season 1 · Deep Focus',
    category: 'Deep Focus',
    lessonId: 'deep-work',
    audioAsset: 'assets/audio/deepwork_part2.m4a',
    part: 2,
  ),

  // --- How Does Infinite Scroll Affect Your Brain? ---
  Episode(
    id: 'ep-infinitescroll-1',
    description: 'Why scrolling never feels like it is time to stop — the design behind the feed.',
    title: 'Designed Not to Stop',
    host: 'Movere',
    seconds: 360,
    series: 'Season 1 · Digital Awareness',
    category: 'Digital Awareness',
    lessonId: 'infinite-scroll',
    audioAsset: 'assets/audio/infinitescroll_part1.m4a',
    part: 1,
  ),
  Episode(
    id: 'ep-infinitescroll-2',
    description: 'The second half: reclaiming a sense of "enough" from an interface built to avoid one.',
    title: 'Finding Your Enough',
    host: 'Movere',
    seconds: 262,
    series: 'Season 1 · Digital Awareness',
    category: 'Digital Awareness',
    lessonId: 'infinite-scroll',
    audioAsset: 'assets/audio/infinitescroll_part2.m4a',
    part: 2,
  ),
];

/// All episodes that belong to a given lesson, in Part 1 → Part 2 order.
List<Episode> episodesForLesson(String lessonId) {
  final list = episodes.where((e) => e.lessonId == lessonId).toList()
    ..sort((a, b) => a.part.compareTo(b.part));
  return list;
}

/// Ids of episodes the user has finished listening to.
/// Backed by SQLite (Sprint 4): the "played" mark on a lesson's episode
/// survives an app restart, same as the reading progress it sits next to.
class ListenedStore extends StateNotifier<Set<String>> {
  ListenedStore() : super(const {}) {
    _load();
  }

  Future<void> _load() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('listened_episodes');
    state = rows.map((r) => r['episode_id'] as String).toSet();
  }

  Future<void> markListened(String id) async {
    if (state.contains(id)) return;
    state = {...state, id};
    final db = await AppDatabase.instance.database;
    await db.insert(
      'listened_episodes',
      {'episode_id': id},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

final listenedProvider =
    StateNotifierProvider<ListenedStore, Set<String>>((ref) => ListenedStore());
