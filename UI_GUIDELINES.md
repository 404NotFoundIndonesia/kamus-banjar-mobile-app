# UI_GUIDELINES.md

Developer reference for maintaining visual consistency in Kamus Banjar. All values are taken from existing production code — do not deviate without updating this document.

---

## Theme

Material 3 (`useMaterial3: true`). Seed color: `Colors.blue`. Both light and dark modes are fully supported. Always check `Theme.of(context).brightness == Brightness.dark` — never hardcode colors that ignore theme.

Dark theme is `ThemeData.dark()` (the default). Light theme uses `ColorScheme.fromSeed(seedColor: Colors.blue)`.

---

## Colors

### Primary palette

| Role | Light | Dark |
|---|---|---|
| Primary accent | `Colors.blue` | `Colors.blue` |
| Word/chip highlight bg | `Color.fromARGB(255, 219, 239, 255)` | `Color.fromARGB(100, 25, 118, 210)` |
| Definitions card bg | `Color.fromARGB(255, 219, 239, 255)` | `Color.fromARGB(255, 18, 41, 58)` |
| Derivatives section bg | `Color.fromARGB(255, 255, 218, 138)` | `Color.fromARGB(255, 39, 27, 15)` |
| Derivative card bg | `Color.fromARGB(255, 255, 243, 192)` | `Color.fromARGB(255, 75, 56, 25)` |
| Search bar bg | `Color.fromARGB(255, 243, 243, 243)` | `Colors.grey.shade800` |
| Bookmark category card bg | `Colors.white` | `Colors.grey.shade900` |
| Bookmark category card border | `Colors.grey.shade300` | `Colors.grey.shade800` |
| Nav indicator | `Colors.blue.shade100` | `Colors.blue.shade700` |

### Part-of-speech badges

| Context | Color |
|---|---|
| Main word definitions | `Color.fromARGB(255, 51, 163, 255)` |
| Derivative definitions | `Colors.orange` (light) / `Color(0xFFFB8C00)` (dark) |

Always white text on these badges.

### Backgrounds

`GradientBackground` is a radial gradient from `Alignment.bottomRight`, used as the base layer on every `Stack`-based screen body.

| Mode | Colors | Stops |
|---|---|---|
| Light | `Color.fromARGB(255, 255, 240, 217)` → `Colors.white` | `[0, 0.3]` |
| Dark | `Color.fromARGB(255, 49, 38, 22)` → `Colors.black` | `[0, 0.3]` |

Always render `GradientBackground()` as the bottom child of the body `Stack`.

### AppBar gradient

`CustomAppBar` uses a `LinearGradient` from `topLeft` to `bottomRight`.

| Mode | Colors |
|---|---|
| Light | `Colors.white` → `Color.fromARGB(255, 234, 249, 255)` → `Color.fromARGB(255, 219, 244, 255)` → `Colors.white` |
| Dark | `Colors.grey.shade900` → `Color.fromARGB(255, 12, 47, 61)` → `Color.fromARGB(255, 16, 49, 63)` → `Colors.grey.shade900` |

### Loading indicator

```dart
CircularProgressIndicator(
  color: Color.fromARGB(113, 33, 149, 243),
  backgroundColor: Color.fromARGB(41, 33, 149, 243),
)
```

### Toast

| Type | Background |
|---|---|
| Informational (copy) | `Color.fromARGB(255, 72, 93, 112)` |
| Error / link | `Colors.blue` |

Always `textColor: Colors.white`, `fontSize: 16.0`.

---

## Typography

Two font families are used:

| Family | Usage |
|---|---|
| `GoogleFonts.poppins()` | AppBar titles, word headings, alphabet letters, word list items |
| System default | Body text, definitions, examples, labels |
| `fontFamily: "monospace"` | Language prefix tags (`[bjn]`, `[id]`) |

### Type scale

| Element | Font | Size | Weight |
|---|---|---|---|
| AppBar title | Poppins | 20 | w600 |
| AppBar subtitle badge | Poppins | 18 | w600 |
| Word title (detail) | Poppins | 32 | w600 |
| Alphabet letter card | Poppins | 24 | bold |
| Word list item | Poppins | 18 | w700 |
| Derivative word heading | System | 24 | w700 |
| Category name (bookmarks) | System | 20 | bold |
| Definition text | System | 20 | normal |
| Part-of-speech badge | System | 16 | w600 |
| Bookmark word chip | System | 16 | normal |
| Error heading | Poppins | 18 | bold |
| Error detail | System | 14 | normal |
| Language tag (`[bjn]`) | monospace | default | normal |

---

## Border Radius

| Shape | Radius |
|---|---|
| Search bar | `BorderRadius.circular(60)` |
| Fuzzy suggestion chips | `BorderRadius.circular(100)` |
| Bookmark word chips / pill buttons | `BorderRadius.circular(80)` |
| Part-of-speech badges | `BorderRadius.circular(24)` |
| Alphabet cards | `BorderRadius.circular(32)` |
| AppBar subtitle badge | `BorderRadius.circular(20)` |
| Word grid cards / definition cards / derivative cards | `BorderRadius.circular(20)` |
| Bookmark category cards | `BorderRadius.circular(12)` |
| Derivatives section header | `topLeft: 24, topRight: 24` only |
| Error container | `BorderRadius.circular(20)` |
| Action buttons (`OutlinedButton`) | `BorderRadius.circular(32)` |
| Theme preview thumbnails | `BorderRadius.circular(8)` |

---

## Spacing

### Horizontal page margin

`horizontal: 30` — used on search bar, grid padding. Do not use arbitrary values.

### Card padding

`EdgeInsets.all(16)` or `EdgeInsets.fromLTRB(16, 16, 16, 16)` for content cards.

### Vertical rhythm

| Usage | Value |
|---|---|
| Between content sections | `SizedBox(height: 24)` |
| Between list items / inline elements | `SizedBox(height: 8)` |
| Between definitions | `SizedBox(height: 8)` |
| AppBar bottom padding | `EdgeInsets.only(bottom: 16)` (title) / `bottom: 8` (icon buttons) |

### Grid layout

Column count: `(MediaQuery.of(context).size.width / 180).floor()`  
Spacing: `crossAxisSpacing: 16`, `mainAxisSpacing: 16`, `childAspectRatio: 2`  
Padding: `EdgeInsets.fromLTRB(30, 20, 30, 30)`

---

## Icons

Always use the outlined variant for unselected/inactive state and the filled variant for selected/active state.

| Icon | Usage |
|---|---|
| `Icons.book_outlined` / `Icons.book` | Kamus tab |
| `Icons.library_books_outlined` / `Icons.library_books` | Kata tab |
| `Icons.bookmark_outline` / `Icons.bookmark` | Markah tab |
| `Icons.info_outlined` / `Icons.info` | Tentang tab |
| `Icons.settings_outlined` / `Icons.settings` | Pengaturan tab |
| `Icons.volume_up` | TTS – main word (24px, `Colors.blue`) |
| `Icons.volume_up_outlined` | TTS – derivative (20px, `Colors.grey.shade600`) |
| `Icons.content_copy` | Copy to clipboard (20px, `Colors.grey.shade600`) |
| `Icons.search` | Search bar prefix |
| `Icons.close` | Clear search (`Colors.grey.shade500`) |
| `Icons.arrow_forward_ios` | Word list item trailing (16px) |
| `Icons.edit_outlined` | Edit category (`Colors.grey.shade500`, 20px) |
| `Icons.subject` | About/info shortcut in AppBar |

---

## Elevation

Cards and chips use `elevation: 0`. Buttons use `elevation: 0`. Do not add shadow to interactive chips or word cards.

---

## Buttons

### Outlined action buttons (errors, confirmations)

```dart
OutlinedButton.icon(
  style: OutlinedButton.styleFrom(
    backgroundColor: Colors.blue.shade50,
    side: const BorderSide(color: Colors.blue),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
  ),
)
```

Icon and label both `Colors.blue`.

### Elevated word chips (bookmarks)

```dart
ElevatedButton.styleFrom(
  elevation: 0,
  backgroundColor: Colors.blue.shade400,
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
)
```

### Custom tap targets

Use `GestureDetector` wrapping a `Container` for word grid cards, alphabet chips, and part-of-speech badges. Do not use `InkWell` — the app does not use ripple effects on cards.

### Icon buttons

Use `padding: EdgeInsets.zero` when inside a sized `SizedBox`. Use `padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12)` for inline icon buttons in the word detail header row.

---

## AppBar

Use `CustomAppBar` for all secondary screens. Use `CustomAppBarHome` only for the home/alphabet overview variant with shortcut buttons. Never use the default Flutter `AppBar` directly.

`isClipped` must always be computed from `MediaQuery.of(context).viewPadding.top == 0.0` and passed to the AppBar.

---

## Navigation

| Screen width | Navigation pattern |
|---|---|
| ≤ 600px | `NavigationBar` (bottom) |
| > 600px | `NavigationRail` (left side) with `VerticalDivider(thickness: 1, width: 1)` |

Indicator colors follow the nav color table above. `labelType: NavigationRailLabelType.all` for the rail.

---

## Responsive layout

Word detail dispatches based on width:
- ≤ 600px → `WordDetailsMobile`
- > 600px → `WordDetailsTablet`

Any new full-screen feature with complex layout should follow the same pattern: a single dispatcher widget that renders the mobile or tablet variant.

---

## Scroll fade overlay

Scrollable lists with a colored background use a gradient overlay at the top to fade content in:

```dart
Container(
  height: 20,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: isDark
          ? [Colors.black, Colors.transparent]
          : [Colors.white, const Color.fromARGB(0, 255, 255, 255)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.3, 1],
    ),
  ),
)
```

Place this as the second child in a `Stack` above the `ListView`/`GridView`.

---

## Dividers

- Between nav rail and content: `VerticalDivider(thickness: 1, width: 1)` wrapped in `SafeArea`
- Below AppBar content: `Container(height: 1, width: width, color: Colors.black12)`

Do not use `Divider()` widget for structural separators.

---

## Empty and error states

- **Empty**: centered `Column` with descriptive `Text` widgets, no icon required.
- **Error**: use `ErrorView` widget — pass `shortErrorMessage` and optionally `detailedErrorMessage` and a `pageToRefresh` widget for the reload action.

---

## Splash screen

- Light bg: `#E4EFF9`, dark bg: `#1A385B`
- Splash icon: `assets/icon/splash-icon.png`
- Branding: `assets/icon/branding.png` (dark variant: `branding-dark.png`)

Regenerate with `dart run flutter_native_splash:create` after any change to `pubspec.yaml` splash config.
