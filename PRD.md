# PRD: Kamus Banjar Mobile App

## Overview

Kamus Banjar is a Flutter mobile app (Android + iOS) providing a Banjar–Indonesian dictionary. Version 1.2.0 (current) supports read-only dictionary access with local bookmarks. This PRD defines the roadmap to integrate community features enabled by the v2 backend API.

- **Package**: `com.iqbaleff214.kamus_banjar_mobile_app`
- **Current version**: 1.2.0 (versionCode 6)
- **API base**: `https://kamus-banjar.404notfound.fun`
- **API version**: v2.0.0 (OpenAPI 3.0.3)

---

## Current State (v1.2.0)

| Feature | Status |
|---|---|
| Browse/search Banjar–Indonesian dictionary | ✅ |
| Word detail: definitions, examples, derivatives | ✅ |
| TTS pronunciation | ✅ |
| Alphabet index view | ✅ |
| Local bookmarks (SharedPreferences) | ✅ |
| Word type reference | ✅ |
| Dark/light theme | ✅ |
| Responsive layout (mobile/tablet) | ✅ |
| User authentication | ❌ |
| Community contributions | ❌ |
| Voting / comments | ❌ |
| Server-side bookmarks | ❌ |
| Word of the day | ❌ |

---

## User Roles

| Role | Access |
|---|---|
| **Guest** (unauthenticated) | Browse dictionary, search, TTS, read-only |
| **User** (authenticated) | + Server bookmarks, submit contributions, vote, comment |
| **Admin** | + Review contributions, manage words, moderate comments, view stats |

---

## Features

### Phase 1 — Authentication

**Goal**: Enable user accounts.

**Screens**:
- Register (`POST /auth/register`): email, username, password
- Login (`POST /auth/login`): email + password → `accessToken` (15min TTL) + `refreshToken` (7 days TTL)
- Token refresh (`POST /auth/refresh`): silent background refresh before expiry
- Logout (`POST /auth/logout`): revoke refresh token

**Storage**: Store tokens in `flutter_secure_storage`. Never store in `SharedPreferences`.

**Auth state**: Provider-based `AuthRepository` wrapping token lifecycle. Unauthenticated users continue using the app as guests with limited features surfaced via nudge banners.

---

### Phase 2 — Server-Side Bookmarks

**Goal**: Migrate bookmarks from local `SharedPreferences` to server, preserving existing data.

**Endpoints**:
- `GET /bookmarks` — fetch user's bookmarks
- `POST /bookmarks` — add bookmark `{ word: string }`
- `DELETE /bookmarks/{word}` — remove bookmark

**Migration**:
1. On first login after upgrade, read existing local bookmarks.
2. Batch-sync to server via `POST /bookmarks`.
3. Clear local storage after successful sync.
4. Guests retain local-only bookmarks (no change).

**UI**: Bookmark button state resolves from server for authenticated users, local for guests. Optimistic updates — toggle immediately, revert on API error.

---

### Phase 3 — Word Contributions

**Goal**: Allow users to submit new words or corrections.

**Endpoints**:
- `POST /contributions` — submit new word
- `GET /contributions/my` — list user's own contributions
- `GET /contributions/{id}` — detail view
- `PUT /contributions/{id}` — edit pending contribution
- `DELETE /contributions/{id}` — withdraw pending contribution

**Contribution states**: `pending` → `active` (approved) or `rejected`

**Submission form fields** (per OpenAPI `Contribution` schema):
- Word (required)
- Syllable breakdown
- Definitions: array of `{ partOfSpeech, definition, examples: [{bjn, id}] }`
- Derivatives: array of `{ word, syllable, definitions }`
- Source: always `community` for user submissions

**My Contributions screen**: List with status badges. Pending entries are editable. Show rejection reason if rejected.

---

### Phase 4 — Community Engagement

#### Voting

- `POST /words/{word}/vote` — upvote or downvote `{ type: "up"|"down" }`
- `DELETE /words/{word}/vote` — remove vote
- Display net vote count on word detail. Authenticated-only; show login prompt for guests.

#### Comments

- `GET /words/{word}/comments` — paginated list (cursor-based)
- `POST /words/{word}/comments` — post comment `{ content, parentId? }`
- `PUT /comments/{id}` — edit own comment
- `DELETE /comments/{id}` — delete own comment

**UI**: Threaded comment section below word detail (collapsed by default, expand on tap). Support reply nesting up to 2 levels visually. Show comment count on word detail header.

#### Word of the Day

- `GET /words/of-the-day` — returns single `Word` object
- Display on home/dictionary tab header as a dismissible featured card.
- Cache response until next calendar day (compare date string, not TTL).

---

### Phase 5 — Admin Panel (In-App)

Only visible to users with `role == admin`. Accessible via Settings tab or dedicated nav rail item on tablet.

**Contribution review**:
- `GET /admin/contributions` — list with `status` filter (`pending`, `active`, `rejected`)
- `POST /admin/contributions/{id}/approve`
- `POST /admin/contributions/{id}/reject` — body: `{ reason: string }`

**Word management**:
- `GET /admin/words` — paginated with search
- `POST /admin/words` — create word directly (source: `official`)
- `PUT /admin/words/{word}` — edit
- `DELETE /admin/words/{word}` — remove

**Comment moderation**:
- `DELETE /admin/comments/{id}`

**Stats dashboard**:
- `GET /admin/stats` → `AdminStats` schema: total words, active/pending/rejected counts, total users, today's contributions

---

## API Integration

### Client Architecture

```
core/
  services/
    auth_service.dart          # raw HTTP, token injection
    dictionary_service.dart    # existing
    contribution_service.dart
    community_service.dart
    admin_service.dart
  repositories/
    auth_repository.dart       # token lifecycle, AuthState provider
    dictionary_repository.dart # existing
    saved_words_repository.dart # existing, extended for server sync
    contribution_repository.dart
    community_repository.dart
    admin_repository.dart
  models/
    word.dart                  # existing, add `source`, `votes` fields
    user.dart
    contribution.dart
    comment.dart
    token_pair.dart
    admin_stats.dart
```

### Auth Interceptor

All authenticated requests attach `Authorization: Bearer <accessToken>`. On 401 response, attempt silent refresh via `POST /auth/refresh`. If refresh fails (expired), emit logout event → redirect to login.

### Error Handling

| HTTP status | Behavior |
|---|---|
| 401 | Silent token refresh → retry once |
| 403 | Show "insufficient permissions" snackbar |
| 404 | Show "not found" inline message |
| 422 | Map field errors to form validation messages |
| 5xx | Show retry banner |
| Network timeout | Offline banner, retry on connectivity restore |

---

## Non-Functional Requirements

| Requirement | Target |
|---|---|
| Cold start to word list | < 2s on mid-range device |
| Search response | < 500ms (debounced 300ms) |
| Token refresh | Transparent to user (< 1s) |
| Offline mode | Dictionary browsable if cached; auth features degrade gracefully |
| Min Android SDK | As defined by `flutter.minSdkVersion` |
| Min iOS | 12.0 |

---

## Phased Delivery

| Phase | Features | API endpoints involved |
|---|---|---|
| 1 | Auth (register, login, logout, refresh) | `/auth/*` |
| 2 | Server-side bookmarks + migration | `/bookmarks/*` |
| 3 | Word contributions + My Contributions screen | `/contributions/*` |
| 4 | Voting, comments, word of the day | `/words/{word}/vote`, `/words/{word}/comments`, `/comments/*`, `/words/of-the-day` |
| 5 | Admin panel (contribution review, word management, stats) | `/admin/*` |

Each phase ships independently. Phases 1 and 2 are prerequisites for phases 3–5.
