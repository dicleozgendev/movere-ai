import 'package:flutter_riverpod/flutter_riverpod.dart';

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
class ListenedStore extends StateNotifier<Set<String>> {
  ListenedStore() : super(const {});

  void markListened(String id) => state = {...state, id};
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
