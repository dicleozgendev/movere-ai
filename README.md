# Movere AI

Dijital denge, odaklanma ve farkındalık uygulaması — Flutter ile geliştirilmektedir.

## Sprint Durumu

**Sprint 1 (06-07 Temmuz): Proje Kurulumu & Planlama** — tamamlandı

- [x] Flutter projesi oluşturuldu
- [x] Geliştirme ortamı yapılandırıldı
- [x] GitHub reposu oluşturuldu
- [x] Klasör mimarisi tanımlandı (feature-first)
- [x] Proje teması yapılandırıldı (light & dark)
- [x] Renk paleti & tipografi hazırlandı

## Klasör Mimarisi (Feature-First)

```
lib/
├── main.dart               # Giriş noktası + Riverpod ProviderScope
├── core/
│   ├── theme/              # app_colors, app_typography, app_theme
│   ├── constants/          # app_constants (route isimleri, spacing, radius)
│   ├── utils/              # yardımcı fonksiyonlar
│   └── widgets/            # ortak reusable widget'lar (Sprint 2)
└── features/
    ├── splash/             # Sprint 3
    ├── onboarding/         # Sprint 3
    ├── auth/               # Sprint 4
    ├── focus/              # Sprint 5
    ├── dashboard/          # Sprint 6
    ├── progress/           # Sprint 7
    ├── academy/            # Sprint 8
    ├── podcast/            # Sprint 9
    └── settings/           # Sprint 10
```

Sprint 2'den itibaren her feature kendi içinde şu yapıyı kullanacak:

```
features/<feature>/
├── presentation/   # ekranlar & widget'lar
├── application/    # riverpod provider'lar / controller'lar
└── domain/         # modeller
```

## Tasarım Sistemi

| Rol | Renk | Hex |
|---|---|---|
| Primary | Teal-Yeşil | `#2E7D6B` |
| Secondary | Sakin Mavi | `#4A90A4` |
| Accent | Mint | `#8FD9C4` |
| Background (light) | | `#F7FAF9` |
| Background (dark) | | `#0F1715` |

Tipografi: **Poppins** (başlıklar) + **Inter** (gövde metni), Google Fonts üzerinden.

## Teknoloji Kararları

- **State management:** Riverpod
- **Yerel veritabanı:** SQLite (`sqflite`) — Sprint 11
- **Backend:** Firebase Auth + Firestore — Sprint 12-13
  - Not: Firebase bağımlılıkları build sürelerini kısaltmak için Sprint 12'ye
    kadar `pubspec.yaml` içinde yorum satırında bekliyor.
- **Grafikler:** fl_chart — Sprint 7
- **Localization:** flutter_localizations + intl — Sprint 15 (EN/TR/DE/ES)

## Kurulum

```bash
git clone <repo-url>
cd movere_ai
flutter pub get
flutter run -d chrome   # UI sprint'lerinde en hızlı iterasyon
```

## Geliştirme Notları

- Lint kuralları `analysis_options.yaml` içinde — `flutter analyze` temiz olmalı.
- Boş feature klasörleri `.gitkeep` ile takip ediliyor; ilk dosya eklenince
  `.gitkeep` silinebilir.
