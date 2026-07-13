# Movere AI

A digital wellbeing and focus app built with Flutter. Movere helps users track focus sessions, build healthier screen habits and follow their progress through a personal "Reality Score".

> Internship project — developed with Agile Scrum (weekly sprints, progress reports every 2 days).

🌐 **Landing page:** [movere-landing](https://github.com/dicleozgendev/movere-landing) · **Live:** [movereai.com](https://movereai.com)

## Status

**Sprint 1 (06-12 July): Foundation + Design System** — in progress

- [x] Flutter project & development environment
- [x] GitHub repository
- [x] Feature-first architecture
- [x] App theme (dark default, light supported)
- [x] Color palette & typography
- [x] Reusable UI component library (7 components) + showcase screen
- [ ] Splash, Onboarding and Authentication screens (due 12 July)

## Architecture

Feature-first structure:
From Sprint 2 on, each feature follows `presentation / application / domain` layering.

## Design System — "Move Beyond"

Dark-first identity with neon green accents.

| Role | Hex |
| --- | --- |
| Primary (neon green) | `#4ADE80` |
| Secondary (teal) | `#34D399` |
| Background (dark, default) | `#0A0E0C` |
| Surface (dark) | `#131A16` |
| Background (light) | `#F6FAF7` |

Typography: **Poppins** (headings) + **Inter** (body) via Google Fonts.

Components: `MovereButton`, `MovereCard`, `MovereTextField`, `MovereAppBar`, `MovereBottomNav`, `MovereLoading` / `MovereSkeleton`, `MovereProgressRing` (CustomPaint, gradient). All components take their styling from the central theme — no hard-coded colors inside widgets.

## Tech Decisions

- **State management:** Riverpod (compile-time safety, low boilerplate)
- **Local database:** SQLite (`sqflite`) — Sprint 4
- **Backend:** Firebase Auth + Firestore — Sprint 4 (dependencies kept commented out until then to keep builds fast)
- **Charts:** fl_chart — Sprint 5
- **Localization:** flutter_localizations + intl — Sprint 5 (EN/TR)

## Getting Started

```
git clone https://github.com/dicleozgendev/movere-ai.git
cd movere_ai
flutter pub get
flutter run
```

Lint rules live in `analysis_options.yaml` — `flutter analyze` should stay clean.

> Note: code comments are currently in Turkish (personal learning notes during the internship); they will be translated to English before the final release.

## Related Repositories

| Repo | Description |
| --- | --- |
| [movere-ai](https://github.com/dicleozgendev/movere-ai) | Flutter mobile app (this repo) |
| [movere-landing](https://github.com/dicleozgendev/movere-landing) | Landing page & waitlist — live at [movereai.com](https://movereai.com) |
