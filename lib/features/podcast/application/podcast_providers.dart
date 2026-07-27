import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/episode.dart';

/// Placeholder episodes shown until the real recordings are produced.
/// Titles follow the Movere content plan; durations are indicative.
const episodes = <Episode>[
  Episode(
    id: 'ep-01',
    lessonId: 'notification-addiction',
    category: 'Digital Awareness',
    title: 'Why Your Attention Feels Broken',
    host: 'Movere',
    seconds: 512,
    series: 'Season 1 · Foundations',
    description:
        'A short introduction to attention residue, context switching and '
        'why focus feels harder than it used to.',
  ),
  Episode(
    id: 'ep-02',
    lessonId: 'deep-work',
    category: 'Deep Focus',
    title: 'The First Hour of Your Day',
    host: 'Movere',
    seconds: 634,
    series: 'Season 1 · Foundations',
    description:
        'How the first hour sets the tone for everything that follows, and '
        'a simple morning structure that protects it.',
  ),
  Episode(
    id: 'ep-03',
    lessonId: 'infinite-scroll',
    category: 'Deep Focus',
    title: 'Designing a Distraction-Free Desk',
    host: 'Movere',
    seconds: 428,
    series: 'Season 1 · Environment',
    description:
        'Small changes in your physical space that remove decisions before '
        'they turn into distractions.',
  ),
  Episode(
    id: 'ep-04',
    lessonId: 'digital-minimalism',
    category: 'Life Design',
    title: 'Rest Is Part of the Work',
    host: 'Movere',
    seconds: 741,
    series: 'Season 1 · Environment',
    description:
        'Why deliberate breaks make focus sessions stronger, and what a '
        'real break actually looks like.',
  ),
];

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

/// The podcast episode that accompanies a given lesson, if there is one.
/// Lessons and episodes are two formats of the same content: the episode
/// appears at the end of the lesson it belongs to.
Episode? episodeForLesson(String lessonId) {
  for (final e in episodes) {
    if (e.lessonId == lessonId) return e;
  }
  return null;
}
