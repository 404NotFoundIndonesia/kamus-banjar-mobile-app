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
  core/
    models/word.dart          # Word, WordDefinition, WordExample, WordDerivative
    repositories/
      dictionary_repository.dart
      saved_words_repository.dart   # SharedPreferences-backed bookmark storage
    services/dictionary_service.dart  # HTTP layer
    utils/word_class_util.dart        # partOfSpeech abbreviation → full name
  features/
    dictionary/
      views/                  # words_view, word_view, alphabets_view
      widgets/
        word_detail_helpers.dart   # shared: speakWord, copyWordToClipboard, highlightWord, toTitleCase
        word_detail_mobile.dart
        word_detail_tablet.dart
    bookmarks/saved_words_page.dart
    info/info_view.dart
    settings/setting_page.dart
    word_types/word_type_view.dart
  shared/widgets/             # CustomAppBar, CustomAppBarHome, ErrorView, GradientBackground, BookmarkButton
  main.dart                   # App entry, MainScreen, theme + navigation setup
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
