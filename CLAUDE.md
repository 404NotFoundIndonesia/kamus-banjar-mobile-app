# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run (requires API_BASE_URL)
flutter run --dart-define=API_BASE_URL=https://your-api.com

# Build release APK
flutter build apk --dart-define=API_BASE_URL=https://your-api.com

# Lint / analyze
flutter analyze

# Tests
flutter test
flutter test test/path/to/test_file.dart  # single test file

# Regenerate splash screen
dart run flutter_native_splash:create

# Regenerate launcher icons
dart run flutter_launcher_icons
```

## Architecture

`Service → Repository → View` — no business logic in views.

```
lib/
  model/           # Plain data classes (Word, WordDefinition, WordExample, WordDerivative)
  service/         # HTTP layer — DictionaryService hits REST API
  repository/      # DictionaryRepository wraps DictionaryService; SavedWordsRepository uses SharedPreferences
  utils/           # SavedWordsRepository, WordClassUtil
  view/
    components/    # Reusable widgets (CustomAppBar, ErrorView, GradientBackground, BookmarkButtonState)
    words_view.dart        # Main dictionary tab: alphabet filter + search + word grid
    word_view.dart         # Word detail (dispatches to mobile/tablet layout)
    word_detail_mobile.dart / word_detail_tablet.dart
    word_type_view.dart    # Browse by word class (kata)
    saved_words_page.dart  # Bookmarked words (categories)
    alphabets_view.dart    # Alphabet overview
    info_view.dart / setting_page.dart
  main.dart        # App entry, MainScreen, theme + navigation setup
```

## Key patterns

**API base URL** — injected at compile time via `--dart-define=API_BASE_URL`. No `.env` file; wrong value = runtime HTTP failures.

**Responsive layout** — `MainScreen` checks `MediaQuery.size.width`: ≤600px → `NavigationBar` (mobile), >600px → `NavigationRail` (tablet). Word detail also splits between `word_detail_mobile.dart` and `word_detail_tablet.dart`.

**Search** — two-stage: local `String.contains` filter on cached word list + debounced (500ms) API fuzzy search via `/api/v1/entries?search=`. Results merged and deduplicated in `_fetchWords`.

**Saved words** — stored in `SharedPreferences` as a nested JSON structure `List<List<List<String>>>`: outer = categories, inner[0] = `[categoryName]`, inner[1] = `[word, ...]`. Managed entirely by `SavedWordsRepository`.

**Theme** — persisted in `SharedPreferences` key `themeMode` (0=system, 1=light, 2=dark). `updateTheme` callback propagates from `MyApp` down through `MainScreen`.

**Selected alphabet** — persisted in `SharedPreferences` key `selectedAlphabet`, read on app start to restore last-used letter.

## API endpoints used

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/api/v1/alphabets` | Letter list with word counts |
| GET | `/api/v1/alphabets/:letter` | Words for a letter |
| GET | `/api/v1/entries/:word` | Full word detail |
| GET | `/api/v1/entries?search=:q` | Fuzzy search |
