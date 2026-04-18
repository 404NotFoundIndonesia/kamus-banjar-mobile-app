# TASKS.md

Implementation task breakdown for the Kamus Banjar community module (API v2). Tasks are ordered by dependency — complete each phase before starting the next. Within a phase, tasks marked with `*` can be done in parallel.

---

## Phase 0 — API v2 Model & Service Alignment

The existing `Word` model and `DictionaryService` were built against API v1. These must be updated before any new feature is built.

### 0-A. Update `Word` model (`lib/core/models/word.dart`) *

API v2 changes the shape of the word object:

| Field | v1 | v2 |
|---|---|---|
| definitions | `List<List<WordDefinition>>` | via `meanings: [{ definitions: [...] }]` |
| syllable | `String` | `syllables: String` |
| votes | missing | `{ up: int, down: int }` |
| source | missing | `"official" \| "community"` |

**Steps:**
1. Add `WordVotes` model: `{ int up, int down }` — parse from `votes` map in JSON.
2. Add `WordMeaning` model: `{ List<WordDefinition> definitions }` — parse from `meanings` array.
3. Change `Word.syllable` → `Word.syllables`.
4. Change `Word.definitions` type from `List<List<WordDefinition>>` to `List<WordMeaning>`.
5. Add `Word.votes` field of type `WordVotes?` (nullable — absent on old API).
6. Add `Word.source` field of type `String?` (nullable — absent on old API).
7. Update `Word.fromJson` factory to parse the new structure.

**Also update** `WordDerivative`: rename `syllable` → `syllables` to match API.

### 0-B. Update word detail widgets to match new model structure *

After 0-A, `word.definitions` no longer exists — it is `word.meanings`.

**Files to update:**
- `lib/features/dictionary/widgets/word_detail_mobile.dart`
- `lib/features/dictionary/widgets/word_detail_tablet.dart`

**Change:** Replace `word.definitions.expand((meaning) { ... })` with `word.meanings.expand((meaning) => meaning.definitions.map(...))`.

Also replace all `derivative.syllable` with `derivative.syllables`.

### 0-C. Add `source` and `votes` display to word detail *

Once the model has `source` and `votes`:

- In `word_detail_mobile.dart` and `word_detail_tablet.dart`, below the word title row, show:
  - If `word.source == 'community'`: a small badge "Komunitas" (use orange, matching the derivative part-of-speech badge color).
  - If `word.votes != null`: show upvote count (`▲ N`) in grey below the title. Full vote interaction comes in Phase 3.

---

## Phase 1 — Authentication

**Goal:** Optional login/register. App still fully works without an account.

### 1-A. Add `flutter_secure_storage` dependency

In `pubspec.yaml`, add:
```yaml
flutter_secure_storage: ^9.2.2
```

Run `flutter pub get`.

### 1-B. Create auth models (`lib/core/models/`) *

**`lib/core/models/user.dart`**
```dart
class User {
  final String id;
  final String name;
  final String email;
  final String role; // "user" | "admin"
  final bool isActive;
}
```
Parse from JSON keys: `id`, `name`, `email`, `role`, `is_active`.

**`lib/core/models/token_pair.dart`**
```dart
class TokenPair {
  final String accessToken;
  final String refreshToken;
}
```
Parse from JSON keys: `access_token`, `refresh_token`.

### 1-C. Create `AuthService` (`lib/core/services/auth_service.dart`)

Raw HTTP layer. All methods return decoded `data` from the `{ code, status, message, data }` envelope. Throw typed exceptions on non-2xx.

| Method | Endpoint | Body / Notes |
|---|---|---|
| `register(name, email, password)` | `POST /api/v1/auth/register` | Returns `User` |
| `login(email, password)` | `POST /api/v1/auth/login` | Returns `TokenPair` |
| `refresh(refreshToken)` | `POST /api/v1/auth/refresh` | Body: `{ refresh_token }`. Returns `TokenPair` |
| `logout(refreshToken)` | `POST /api/v1/auth/logout` | Requires Bearer. Body: `{ refresh_token }` |
| `getMe(accessToken)` | `GET /api/v1/auth/me` | Requires Bearer. Returns `User` |
| `updateMe(accessToken, {name?, oldPassword?, newPassword?})` | `PUT /api/v1/auth/me` | Returns `User` |

The base URL is the same `API_BASE_URL` dart-define as `DictionaryService`.

### 1-D. Create `AuthRepository` (`lib/core/repositories/auth_repository.dart`)

Provider-based. Wraps `AuthService` and `flutter_secure_storage`. Exposes `AuthState` to the widget tree.

**Storage keys:**
- `auth_access_token`
- `auth_refresh_token`

**State:**
```dart
enum AuthRole { guest, user, admin }

class AuthState {
  final AuthRole role;
  final User? user;
  final bool isLoading;
}
```

**Methods:**
- `Future<void> init()` — on app start: read tokens from secure storage, call `GET /api/v1/auth/me`. If 401, attempt silent refresh. If refresh fails, clear storage and stay guest.
- `Future<void> login(email, password)` — call `AuthService.login`, save tokens, call `getMe`, set user + role.
- `Future<void> register(name, email, password)` — call `AuthService.register`, then auto-login.
- `Future<void> logout()` — call `AuthService.logout`, clear tokens, reset to guest.
- `Future<void> refreshIfNeeded()` — called by HTTP interceptor on 401. Rotate tokens silently.
- `Future<void> updateProfile({name?, oldPassword?, newPassword?})` — call `AuthService.updateMe`, update local user state.

### 1-E. Wire `AuthRepository` into app (`lib/main.dart`)

1. Wrap `MaterialApp` with `MultiProvider` (add `provider` already in deps).
2. Provide `AuthRepository` at the root.
3. Call `authRepository.init()` before `FlutterNativeSplash.remove()`.

### 1-F. Create Login screen (`lib/features/auth/login_view.dart`)

Fields: Email (`TextFormField`), Password (`TextFormField`, obscured). Submit button calls `AuthRepository.login`. On success, `Navigator.pop`.

Validation (client-side before submit):
- Email: non-empty, valid format.
- Password: non-empty, minimum 8 characters.

Show `CircularProgressIndicator` during request. Show inline error message on failure (use `Fluttertoast` for brief messages, inline `Text` in red for field errors from 422).

Link to Register screen at bottom.

### 1-G. Create Register screen (`lib/features/auth/register_view.dart`)

Fields: Name (min 2, max 100), Email, Password (min 8), Confirm Password (must match).

On success, auto-login via `AuthRepository.register` and `Navigator.pop`.

Same error/loading pattern as Login.

### 1-H. Create Profile screen (`lib/features/auth/profile_view.dart`)

Shows: name, email, role badge. Edit button opens an edit form (name + optional password change: old password, new password, confirm new password).

For admin role, show a distinct badge — use the same orange color as derivative part-of-speech badges.

### 1-I. Add auth entry point to navigation

In `lib/main.dart` `MainScreen`:
- Add a new navigation destination: "Akun" with `Icons.person_outlined` / `Icons.person`.
- If guest: show Login screen with a prominent "Daftar / Masuk" button.
- If logged in: show Profile screen.
- Place as the last destination (after Pengaturan, or replace it — keep Pengaturan accessible from Profile).

### 1-J. Add login nudge widget (`lib/shared/widgets/login_nudge.dart`)

A dismissible bottom sheet or card shown when a guest taps a community action (bookmark sync, vote, comment, contribute).

Text: "Masuk untuk menyimpan markah, memberi suara, dan berkontribusi."  
Buttons: "Masuk" (opens Login), "Daftar" (opens Register), "Nanti saja" (dismisses).

---

## Phase 2 — Server-Side Bookmarks

**Depends on:** Phase 1 complete.

### 2-A. Create `CommunityService` (`lib/core/services/community_service.dart`)

Start with bookmark endpoints only (votes, comments, WOTD added in Phase 3).

| Method | Endpoint | Notes |
|---|---|---|
| `getBookmarks(accessToken, {page, limit})` | `GET /api/v1/me/bookmarks` | Returns `List<String>` (word strings) |
| `addBookmark(accessToken, word)` | `POST /api/v1/me/bookmarks/{word}` | No body |
| `removeBookmark(accessToken, word)` | `DELETE /api/v1/me/bookmarks/{word}` | No body |

### 2-B. Update `SavedWordsRepository` (`lib/core/repositories/saved_words_repository.dart`)

The existing repo is local-only. Extend it to delegate to server when user is authenticated.

**Changes:**
- Inject `CommunityService` and `AuthRepository` (or just accept a token parameter).
- `isBookmarked(word)`:
  - If guest → read from `SharedPreferences` as before.
  - If logged in → call `GET /api/v1/me/bookmarks` and check inclusion. Cache the list in memory per session.
- `addBookmark(word)`:
  - If guest → local `SharedPreferences`.
  - If logged in → `POST /api/v1/me/bookmarks/{word}`. Optimistic: update local cache immediately, revert on error.
- `removeBookmark(word)`:
  - If guest → local `SharedPreferences`.
  - If logged in → `DELETE /api/v1/me/bookmarks/{word}`. Optimistic.
- `migrateLocalToServer()` — called once on first login:
  1. Read all words from local `SharedPreferences`.
  2. For each word, call `addBookmark` on the server.
  3. On full success, clear `SharedPreferences` bookmark data.

**Call `migrateLocalToServer()`** inside `AuthRepository.login` after successful login.

### 2-C. Update `BookmarkButton` widget (`lib/shared/widgets/bookmark_button_state.dart`)

Currently reads/writes local only. After 2-B, `SavedWordsRepository` handles the routing transparently. No widget change should be needed if the repository interface stays the same. Verify state updates correctly for both guest and logged-in paths.

### 2-D. Update `SavedWordsPage` (`lib/features/bookmarks/saved_words_page.dart`)

When the user is logged in, bookmarks come from the server as a flat `List<String>` — no categories. The existing UI uses a category-grouped layout that only makes sense for local storage.

**Changes:**
- If guest: show existing category-grouped UI (unchanged).
- If logged in: show a flat grid of word chips (same style as existing word chips: `Colors.blue.shade400`, `BorderRadius.circular(80)`). Tapping navigates to `WordView`. Show total count.

---

## Phase 3 — Community Engagement

**Depends on:** Phase 1 complete. Phase 2 recommended but not required.

### 3-A. Add vote endpoints to `CommunityService`

| Method | Endpoint | Body | Notes |
|---|---|---|---|
| `vote(accessToken, word, int vote)` | `POST /api/v1/entries/{word}/votes` | `{ vote: 1 \| -1 }` | Same vote toggles off, opposite replaces |

### 3-B. Add vote UI to word detail

In both `word_detail_mobile.dart` and `word_detail_tablet.dart`:

- Show `▲ {up}  ▼ {down}` counts using `word.votes` (from Phase 0-C, now make them tappable).
- If guest: tapping either shows `LoginNudge`.
- If logged in: tapping `▲` calls `CommunityService.vote(word, 1)`, tapping `▼` calls with `-1`. Toggle off if already voted same way.
- Optimistic UI: update count locally on tap, revert on API error with a `Fluttertoast` message.

### 3-C. Add comment endpoints to `CommunityService`

| Method | Endpoint | Notes |
|---|---|---|
| `getComments(word)` | `GET /api/v1/entries/{word}/comments` | Public. Returns `List<Comment>` |
| `postComment(accessToken, word, body, {parentId?})` | `POST /api/v1/entries/{word}/comments` | Returns `Comment` |
| `deleteOwnComment(accessToken, word, commentId)` | `DELETE /api/v1/entries/{word}/comments/{commentId}` | |

### 3-D. Create `Comment` model (`lib/core/models/comment.dart`)

```dart
class Comment {
  final String id;
  final String userId;
  final String userName;
  final String? parentId;
  final String body;
  final List<Comment> replies;
  final DateTime createdAt;
}
```
Parse from JSON. `replies` is a nested array of the same schema.

### 3-E. Create comment section widget (`lib/features/dictionary/widgets/comment_section.dart`)

A `StatefulWidget` that:
1. On init, calls `CommunityService.getComments(word)` and renders the list.
2. Shows top-level comments with nested replies indented (max 2 visual levels).
3. Each comment shows `userName`, `body`, `createdAt` (relative time: "2 jam lalu").
4. Reply button → opens an inline text input pre-filled with `parent_id`.
5. Delete button (own comments only, compare `comment.userId == authState.user?.id`) → confirmation dialog → `deleteOwnComment`.
6. If guest: comment input field is replaced by a login nudge inline text: "Masuk untuk berkomentar →" (tappable).
7. If no comments: "Belum ada komentar. Jadilah yang pertama!"

Show this widget in `word_detail_mobile.dart` below the definitions card, and in `word_detail_tablet.dart` below the definitions column.

### 3-F. Add WOTD endpoint to `CommunityService`

| Method | Endpoint | Notes |
|---|---|---|
| `getWordOfTheDay()` | `GET /api/v1/word-of-the-day` | Public. Returns `Word` |

### 3-G. Create WOTD card widget (`lib/features/dictionary/widgets/word_of_the_day_card.dart`)

A dismissible `Card` displayed at the top of `WordsView` (above the search bar).

- On init: check `SharedPreferences` key `wotd_date`. If it equals today's date string (`yyyy-MM-dd`), read cached `wotd_word` from prefs and show it. Otherwise, call `getWordOfTheDay()`, cache the word string and date, and display.
- Card shows: "Kata Hari Ini", the word in large Poppins bold text, a subtitle (first definition truncated to 1 line).
- Tapping navigates to `WordView` for that word.
- Dismiss (X button): sets `SharedPreferences` key `wotd_dismissed_date` to today. On next app open (new day), card reappears.

---

## Phase 4 — Word Proposals

**Depends on:** Phase 1 complete.

### 4-A. Create `ContributionService` (`lib/core/services/contribution_service.dart`)

| Method | Endpoint | Notes |
|---|---|---|
| `submit(accessToken, WordSubmitRequest)` | `POST /api/v1/contributions` | Returns `Contribution` |
| `getMine(accessToken, {page, limit})` | `GET /api/v1/contributions/mine` | Returns paginated `List<Contribution>` |
| `getById(accessToken, id)` | `GET /api/v1/contributions/{id}` | Returns `Contribution` |
| `edit(accessToken, id, WordSubmitRequest)` | `PUT /api/v1/contributions/{id}` | Returns `Contribution`. Resets status to pending |
| `delete(accessToken, id)` | `DELETE /api/v1/contributions/{id}` | Only pending entries |

`WordSubmitRequest` fields: `word` (required), `syllables`, `alphabet` (required, single char), `meanings` (required, min 1 item), `derivatives`.

### 4-B. Create `Contribution` model (`lib/core/models/contribution.dart`)

```dart
class Contribution {
  final String id;
  final String wordId;
  final Word word;
  final String contributorId;
  final String? reviewerId;
  final String action; // submitted | approved | rejected | revised
  final String? notes;
  final DateTime createdAt;
}
```

### 4-C. Create `ContributionRepository` (`lib/core/repositories/contribution_repository.dart`)

Thin wrapper over `ContributionService`. Passes access token from `AuthRepository`. No local caching — always fetch from server.

### 4-D. Create word submission form (`lib/features/contributions/submit_word_view.dart`)

Multi-section form:

**Section 1 — Word info:**
- Word (`TextFormField`, required)
- Syllables (`TextFormField`, optional, hint: "con-toh")
- Alphabet (`DropdownButtonFormField`, required, list: Banjar alphabet letters)

**Section 2 — Meanings (dynamic list):**
- At least 1 meaning required.
- Each meaning has 1+ definitions: Part of Speech (`DropdownButtonFormField` using `WordClassUtil` map), Definition text.
- Each definition can have 0+ examples: Banjar sentence + Indonesian translation.
- "Tambah definisi" and "Tambah makna" buttons to add rows.
- "Hapus" button to remove rows.

**Section 3 — Derivatives (dynamic list, optional):**
- Each derivative: word, syllables, and definitions (same structure as Section 2 but without nested examples).
- "Tambah turunan" button.

Submit button → calls `ContributionRepository.submit`. On success: show toast "Kiriman berhasil dikirim!" and pop.

### 4-E. Create My Proposals screen (`lib/features/contributions/my_contributions_view.dart`)

Accessed from the Akun/Profile screen.

List of contributions fetched from `GET /api/v1/contributions/mine`. Each card shows:
- Word name (large)
- Status badge:
  - `submitted` → blue "Menunggu"
  - `approved` → green "Disetujui"
  - `rejected` → red "Ditolak"
  - `revised` → orange "Direvisi"
- If `rejected`: show `notes` field in red below the status.
- Submitted date.

Actions per card:
- `submitted` or `rejected`: "Edit" button → navigates to edit form (pre-filled), "Hapus" button → confirmation dialog → `ContributionRepository.delete`.
- `approved`: no actions (read-only).

Pagination: load more button at bottom (not infinite scroll) — fetch next page on tap.

### 4-F. Create edit form (`lib/features/contributions/edit_contribution_view.dart`)

Same form as `submit_word_view.dart` but pre-filled from the `Contribution.word` data. On submit, calls `ContributionRepository.edit(id, ...)`. On success: toast "Kiriman berhasil diperbarui!" and pop.

### 4-G. Add "Usulkan Kata" entry point

In `lib/features/auth/profile_view.dart`, add a list tile "Usulan Saya" that navigates to `MyContributionsView`, and a floating action button or prominent button "Usulkan Kata Baru" that navigates to `SubmitWordView`.

If guest views the profile/account tab, show the `LoginNudge` instead of these options.

---

## Phase 5 — Admin Panel

**Depends on:** Phase 1 complete. Only rendered when `authState.role == AuthRole.admin`.

### 5-A. Create `AdminService` (`lib/core/services/admin_service.dart`)

**Words:**
| Method | Endpoint |
|---|---|
| `listWords(accessToken, {status?, source?, page, limit})` | `GET /api/v1/admin/words` |
| `createWord(accessToken, WordSubmitRequest)` | `POST /api/v1/admin/words` |
| `updateWord(accessToken, id, WordSubmitRequest)` | `PUT /api/v1/admin/words/{id}` |
| `deleteWord(accessToken, id)` | `DELETE /api/v1/admin/words/{id}` (soft-delete — sets status to rejected) |

**Contributions:**
| Method | Endpoint |
|---|---|
| `listContributions(accessToken, {status?, page, limit})` | `GET /api/v1/admin/contributions` |
| `approve(accessToken, id)` | `PATCH /api/v1/admin/contributions/{id}/approve` |
| `reject(accessToken, id, {notes?})` | `PATCH /api/v1/admin/contributions/{id}/reject` |

**Comments:**
| Method | Endpoint |
|---|---|
| `deleteComment(accessToken, word, commentId)` | `DELETE /api/v1/admin/entries/{word}/comments/{commentId}` |

**Users:**
| Method | Endpoint |
|---|---|
| `listUsers(accessToken, {role?, active?, page, limit})` | `GET /api/v1/admin/users` |
| `deactivateUser(accessToken, id)` | `PATCH /api/v1/admin/users/{id}/deactivate` |
| `activateUser(accessToken, id)` | `PATCH /api/v1/admin/users/{id}/activate` |
| `promoteUser(accessToken, id)` | `PATCH /api/v1/admin/users/{id}/promote` |

**Stats + WOTD:**
| Method | Endpoint |
|---|---|
| `getStats(accessToken)` | `GET /api/v1/admin/stats` |
| `setWordOfTheDay(accessToken, word, date)` | `PUT /api/v1/admin/word-of-the-day` |

### 5-B. Create `AdminStats` model (`lib/core/models/admin_stats.dart`)

```dart
class AdminStats {
  final int wordsOfficial;
  final int wordsCommunity;
  final int wordsPending;
  final int wordsRejected;
  final int usersTotal;
  final int usersActive;
  final int usersInactive;
  final int contributionsPending;
  final int contributionsThisWeek;
  final int contributionsThisMonth;
  final List<TopContributor> topContributors;
}

class TopContributor {
  final String userId;
  final String name;
  final int approvedCount;
}
```

### 5-C. Create `AdminRepository` (`lib/core/repositories/admin_repository.dart`)

Thin wrapper over `AdminService`, passes token from `AuthRepository`. Guards all calls — if called without admin role, throw `UnauthorizedException` immediately without hitting the network.

### 5-D. Create Admin dashboard screen (`lib/features/admin/admin_dashboard_view.dart`)

Entry point for all admin features. Show as a new navigation destination (icon: `Icons.admin_panel_settings_outlined` / `Icons.admin_panel_settings`, label: "Admin") — **only visible when `authState.role == AuthRole.admin`**.

The dashboard shows:
- Stats card: 4 counters in a 2×2 grid — Total Kata Resmi, Total Kata Komunitas, Menunggu Review, Total Pengguna. Fetch from `GET /api/v1/admin/stats`.
- Quick-action buttons: "Review Usulan", "Kelola Kata", "Kelola Pengguna", "Atur Kata Hari Ini".

### 5-E. Create Contribution review screen (`lib/features/admin/contribution_review_view.dart`)

Tabbed list with filters: All / Menunggu / Disetujui / Ditolak.

Each card shows: word, contributor name, submission date, current status.

Actions on pending items:
- "Setujui" → `AdminRepository.approve(id)` → update list.
- "Tolak" → bottom sheet with optional `notes` text field → `AdminRepository.reject(id, notes)`.

### 5-F. Create admin word management screen (`lib/features/admin/word_management_view.dart`)

Searchable, filterable list of all words (status + source filters).

Each item:
- Edit → reuse `SubmitWordView` / `EditContributionView` form logic with `AdminRepository.updateWord`.
- Delete → confirmation dialog → `AdminRepository.deleteWord` (soft delete).

"Tambah Kata" FAB → opens `SubmitWordView` form that calls `AdminRepository.createWord`.

### 5-G. Create admin user management screen (`lib/features/admin/user_management_view.dart`)

Paginated list of users. Filter by role and active status.

Per user actions:
- Active users: "Nonaktifkan" button → `deactivateUser`. Deactivated users cannot log in.
- Inactive users: "Aktifkan" button → `activateUser`.
- `user` role: "Jadikan Admin" button → confirmation → `promoteUser`. Show a clear warning: "Tindakan ini tidak dapat dibatalkan melalui aplikasi."

### 5-H. Create WOTD scheduler screen (`lib/features/admin/wotd_scheduler_view.dart`)

Simple form:
- Word field (`TextFormField` with autocomplete from dictionary search).
- Date picker (`showDatePicker`, default: tomorrow).

Submit → `AdminRepository.setWordOfTheDay(word, date)`. Show success toast.

---

## Cross-cutting: HTTP Error Handling

After Phase 1, all services must implement a consistent 401 retry flow. Refactor `DictionaryService` and all new services to share an `ApiClient` base or mixin:

1. On any 401 response, call `AuthRepository.refreshIfNeeded()`.
2. Retry the original request once with the new token.
3. If refresh also returns 401, call `AuthRepository.logout()` (clears tokens, sets guest state). The provider notifies the widget tree — the UI responds by showing the auth screen.

| Status | Toast / UI |
|---|---|
| 403 | Fluttertoast: "Akses ditolak" |
| 404 | Inline: "Tidak ditemukan" |
| 409 | Inline form error (e.g. "Email sudah terdaftar") |
| 422 | Map `message` field to inline form validation error |
| 429 | Fluttertoast: "Terlalu banyak permintaan, coba lagi sebentar" |
| 5xx | Fluttertoast: "Terjadi kesalahan server" + retry option |

---

## Dependency Summary

```
Phase 0 (model fixes)  ← no dependencies, do first
Phase 1 (auth)         ← depends on Phase 0
Phase 2 (bookmarks)    ← depends on Phase 1
Phase 3 (community)    ← depends on Phase 1
Phase 4 (proposals)    ← depends on Phase 1
Phase 5 (admin)        ← depends on Phase 1
```

Phases 2, 3, 4, 5 are independent of each other and can be worked on in parallel once Phase 1 is complete.
