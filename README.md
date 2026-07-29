# Movere AI

A digital wellbeing and focus app built with Flutter. Movere helps users track focus sessions, build healthier screen habits and follow their progress through a personal "Reality Score".

> Internship project — developed with Agile Scrum (weekly sprints, progress reports every 2 days).

## Status

**Sprint 1 (06-12 July): Foundation + Design System** — ✅ completed

- [x] Flutter project & development environment
- [x] GitHub repository
- [x] Feature-first architecture
- [x] App theme (dark default, light supported)
- [x] Color palette & typography
- [x] Reusable UI component library (7 components) + showcase screen
- [x] Splash, Onboarding and Authentication screens

> Development has continued beyond Sprint 1 — see the `lib/features` folder for the latest functionality built on top of this foundation.

## Architecture

Feature-first structure:
From Sprint 2 on, each feature follows `presentation / application / domain` layering.

## Design System — "Move Beyond"

Dark-first identity with neon green accents.

| Role | Hex |
|---|---|
| Primary (neon green) | `#4ADE80` |
| Secondary (teal) | `#34D399` |
| Background (dark, default) | `#0A0E0C` |
| Surface (dark) | `#131A16` |
| Background (light) | `#F6FAF7` |

Typography: **Poppins** (headings) + **Inter** (body) via Google Fonts.

Components: `MovereButton`, `MovereCard`, `MovereTextField`, `MovereAppBar`, `MovereBottomNav`, `MovereLoading` / `MovereSkeleton`, `MovereProgressRing` (CustomPaint, gradient). All components take their styling from the central theme — no hard-coded colors inside widgets.

## Tech Decisions

- **State management:** Riverpod (compile-time safety, low boilerplate)
- **Local database:** SQLite (`sqflite`)
- **Backend:** Firebase Auth + Firestore
- **Charts:** fl_chart
- **Localization:** flutter_localizations + intl (EN/TR)

## Getting Started

```bash
git clone https://github.com/dicleozgendev/movere-ai.git
cd movere_ai
flutter pub get
flutter run
```

Lint rules live in `analysis_options.yaml` — `flutter analyze` should stay clean.

## Audio Assets

The Academy podcast episodes reference recordings in `assets/audio/`, which
are intentionally **not included in this public repository** — the voice
used belongs to a third party under a signed agreement limiting its use to
this app. Running the app without these files simply means the podcast
player has nothing to load; everything else works as normal. Contributors
with access to the recordings can drop them into `assets/audio/` locally
(see `pubspec.yaml` for the expected filenames).

> Note: all code comments are written in English.
