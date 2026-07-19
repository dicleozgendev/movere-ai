import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/lesson.dart';

/// Ders içerikleri — Academy mockup'ındaki 5 ders.
/// İçerik şimdilik uygulamayla geliyor; Sprint 4'te okuma ilerlemesi
/// ve yer imleri SQLite'a taşınacak. TR çeviriler Sprint 5'te
/// (flutter_localizations) eklenecek.
const lessons = <Lesson>[
  Lesson(
    id: 'notification-addiction',
    title: 'Why Are Notifications Addictive?',
    category: 'Digital Awareness',
    minutes: 5,
    summary: 'Discover the reward loop notifications create in your brain.',
    paragraphs: [
      'Every notification sends a small dopamine signal to your brain: "This might be important." The problem is not the notification itself but the uncertainty — not knowing when the reward will arrive is exactly the pattern the brain gets hooked on.',
      'Slot machines work on the same principle: variable reward. Every time you pick up your phone, sometimes there is good news, sometimes nothing. That randomness turns checking into a habit.',
      'The loop works like this: a notification arrives, attention splits, you check, a brief relief follows, and then the anticipation of the next one begins. By the end of the day, hundreds of micro-interruptions have piled up.',
      'The way out is design, not willpower: turn off every notification that does not come from a person, and batch-check the rest at times you choose. When you manage the anticipation, the loop starts working for you.',
    ],
  ),
  Lesson(
    id: 'infinite-scroll',
    title: 'How Does Infinite Scroll Affect Your Brain?',
    category: 'Digital Awareness',
    minutes: 7,
    summary: 'Learn how infinite scrolling shrinks your attention span.',
    paragraphs: [
      'Infinite scroll deliberately removes the stopping point. Natural endings — the last page of a newspaper, the end of a chapter — send the brain a "done" signal. The feed never sends it.',
      'Every swipe carries the possibility that the next piece of content might be better. This locks your attention in "almost there" mode: you never fully engage with what is on screen, because your mind is already waiting for the next thing.',
      'Over time this habit erodes your capacity for deep reading and sustained focus. As the brain adapts to quick, rapid rewards, slow but deep work starts to feel harder and harder.',
      'The practical fix: set a purpose and a time limit before opening any feed-based app. A frame like "five minutes, just checking this one thing" draws a finish line across an endless stream.',
    ],
  ),
  Lesson(
    id: 'deep-work',
    title: 'What Is Deep Work?',
    category: 'Deep Focus',
    minutes: 12,
    summary: 'Deepen your attention and focus on work that matters.',
    paragraphs: [
      'Deep work is the ability to focus without distraction on a cognitively demanding task. Hard, valuable things only get made in that state — and the skill is becoming rare exactly when it is becoming most valuable.',
      'Every context switch leaves an "attention residue" behind. A quick glance at a notification is never quick: part of your mind stays there for minutes afterwards.',
      'The answer is not heroic willpower but structure: decide in advance when you will work deeply, for how long, and what counts as a distraction. A timer turns an intention into a container.',
      'Start small. One clean, uninterrupted session a day changes more than three broken ones. Depth is a skill, and skills grow with repetition.',
    ],
  ),
  Lesson(
    id: 'digital-minimalism',
    title: 'Digital Minimalism',
    category: 'Life Design',
    minutes: 8,
    summary: 'Ways to achieve more with less.',
    paragraphs: [
      'Digital minimalism is not hostility toward technology; it is a philosophy of selectivity: keep the tools that genuinely add value to your life, and deliberately let go of the rest.',
      'Most apps stay on your phone "just in case". The minimalist question is: does this tool concretely support something I care about? If the answer is not a clear yes, the answer is no.',
      'Try a thirty-day declutter: remove every non-essential app, and at the end of the month reinstall only the ones you truly missed. Most people bring back very few.',
      'Freed-up time does not fill itself — plan it in advance. The goal of minimalism is not emptiness but the better things you put in its place: reading, walking, real contact with people.',
    ],
  ),
  Lesson(
    id: 'social-algorithms',
    title: 'How Do Social Media Algorithms Work?',
    category: 'Digital Awareness',
    minutes: 10,
    summary:
        'Discover how algorithms steer you — and how to break free.',
    paragraphs: [
      'The algorithm has a single goal: maximize your time on screen. It does not show you what is interesting; it shows you what will keep you there — and those are rarely the same thing.',
      'The system learns from every interaction: what you look at, how long you pause, what you scroll past. Because outrage and curiosity are the strongest retention signals, the feed gradually bends toward those emotions.',
      'This personalization creates a filter bubble: everyone mistakes their own feed for reality itself. What you see is a mirror of your past behavior — not of the world.',
      'The first step to freedom is noticing the machinery: curate who you follow deliberately, keep your distance from "suggested for you", and switch the feed to chronological now and then. You decide what you feed the algorithm.',
    ],
  ),
];

/// Yer imleri: ders id'lerinin kümesi.
class BookmarkStore extends StateNotifier<Set<String>> {
  BookmarkStore() : super(const {});

  void toggle(String id) {
    state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
  }
}

final bookmarksProvider =
    StateNotifierProvider<BookmarkStore, Set<String>>((ref) => BookmarkStore());

/// Okuma ilerlemesi: ders id -> 0..1 (en çok ulaşılan kaydırma noktası).
class ReadingProgressStore extends StateNotifier<Map<String, double>> {
  ReadingProgressStore() : super(const {});

  void update(String id, double value) {
    final current = state[id] ?? 0;
    if (value > current) state = {...state, id: value};
  }
}

final readingProgressProvider =
    StateNotifierProvider<ReadingProgressStore, Map<String, double>>(
  (ref) => ReadingProgressStore(),
);
