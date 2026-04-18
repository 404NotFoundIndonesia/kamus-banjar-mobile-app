# PRD: Kamus Banjar Mobile App

## Overview

Kamus Banjar is a Flutter mobile app (Android + iOS) providing a Banjar–Indonesian dictionary. Version 1.2.0 (current) supports read-only dictionary access with local bookmarks. This PRD defines the roadmap to add a community module powered by the v2 backend API.

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
| Admin word management | ❌ |

---

## User Roles

Account creation is optional. Users who are not logged in can still browse the full dictionary.

| Role | How obtained | Access |
|---|---|---|
| **Guest** | No account required | Browse, search, TTS, local bookmarks |
| **User** | Register / login | + Server bookmarks, vote, comment, submit word proposals |
| **Admin** | Assigned by system | All user access + add/edit/delete words directly (source: `official`), review proposals, moderate comments, view stats |

Admins are users — they go through the same login flow. Role is returned in the auth token payload and drives conditional UI.

---

## Features

### Authentication (optional)

Login and registration are presented as an option, not a gate. Guests encounter a soft nudge ("Login to save bookmarks, vote, and contribute") when they attempt a community action.

**Endpoints**:
- `POST /auth/register` — email, username, password
- `POST /auth/login` → `accessToken` (15min) + `refreshToken` (7 days)
- `POST /auth/refresh` — silent background token refresh
- `POST /auth/logout` — revoke refresh token

**Storage**: `flutter_secure_storage` for tokens. `SharedPreferences` only for non-sensitive state (theme, selected alphabet).

**Auth state**: Provider-based `AuthRepository`. Exposes `AuthState` (guest / user / admin). Silent refresh on 401 before emitting logout.

---

### Community Module

#### Bookmarks (server-side for logged-in users)

Guests continue using local `SharedPreferences` bookmarks unchanged.

On first login, existing local bookmarks are migrated to the server automatically, then local storage is cleared.

| Endpoint | Purpose |
|---|---|
| `GET /bookmarks` | Fetch user's saved words |
| `POST /bookmarks` | Add bookmark `{ word }` |
| `DELETE /bookmarks/{word}` | Remove bookmark |

UI: Bookmark button resolves state from server for authenticated users, local for guests. Optimistic updates — toggle immediately, revert on error.

---

#### Voting

Authenticated users can upvote or downvote any word. Vote count is shown on the word detail screen. Guests see the count but get a login nudge on tap.

| Endpoint | Purpose |
|---|---|
| `POST /words/{word}/vote` | Cast vote `{ type: "up"\|"down" }` |
| `DELETE /words/{word}/vote` | Remove vote |

---

#### Comments

Threaded comments per word. Guests can read; login required to post.

| Endpoint | Purpose |
|---|---|
| `GET /words/{word}/comments` | Paginated list (cursor-based) |
| `POST /words/{word}/comments` | Post comment `{ content, parentId? }` |
| `PUT /comments/{id}` | Edit own comment |
| `DELETE /comments/{id}` | Delete own comment |

UI: Comment section below word detail, collapsed by default. Support 2-level visual nesting for replies. Show comment count in word detail header.

---

#### Word Proposals (user contributions)

Authenticated users can propose new words or definitions. Source is always `community`. Proposals go through admin review before appearing in the dictionary.

| Endpoint | Purpose |
|---|---|
| `POST /contributions` | Submit proposal |
| `GET /contributions/my` | List own proposals |
| `GET /contributions/{id}` | Proposal detail |
| `PUT /contributions/{id}` | Edit pending proposal |
| `DELETE /contributions/{id}` | Withdraw proposal |

**Proposal states**: `pending` → `active` (approved) or `rejected`

**Form fields** (per `Contribution` schema):
- Word (required)
- Syllable breakdown
- Definitions: `[{ partOfSpeech, definition, examples: [{bjn, id}] }]`
- Derivatives: `[{ word, syllable, definitions }]`

**My Proposals screen**: status badge per entry. Pending entries are editable. Rejection reason shown when rejected.

---

#### Word of the Day

Surfaced on the dictionary tab header as a featured card. Dismissible per day.

| Endpoint | Purpose |
|---|---|
| `GET /word-of-the-day` | Today's featured word |

Cache until next calendar day (compare date string, not TTL).

---

### Admin Features

Only rendered for users with `role == admin`. Accessible via a dedicated Admin entry in Settings or an extra nav rail item on tablet.

#### Direct Word Management

Admins add words with source `official` (verified). No review step — changes are live immediately.

| Endpoint | Purpose |
|---|---|
| `GET /admin/words` | Paginated word list with search |
| `POST /admin/words` | Create word (source: `official`) |
| `PUT /admin/words/{word}` | Edit word |
| `DELETE /admin/words/{word}` | Delete word |

#### Proposal Review

| Endpoint | Purpose |
|---|---|
| `GET /admin/contributions` | List proposals filtered by status |
| `POST /admin/contributions/{id}/approve` | Approve → word goes `active` |
| `POST /admin/contributions/{id}/reject` | Reject `{ reason }` |

#### Comment Moderation

| Endpoint | Purpose |
|---|---|
| `DELETE /admin/comments/{id}` | Remove any comment |

#### Stats Dashboard

| Endpoint | Purpose |
|---|---|
| `GET /admin/stats` | Total words, status breakdown, total users, today's contributions |

---

## API Integration Architecture

```
core/
  services/
    auth_service.dart           # raw HTTP, token injection interceptor
    dictionary_service.dart     # existing
    community_service.dart      # bookmarks, votes, comments, WOTD
    contribution_service.dart   # proposals
    admin_service.dart          # admin-only endpoints
  repositories/
    auth_repository.dart        # AuthState provider, token lifecycle
    dictionary_repository.dart  # existing
    saved_words_repository.dart # existing — delegates to server if logged in, local if guest
    community_repository.dart
    contribution_repository.dart
    admin_repository.dart
  models/
    word.dart                   # existing — add `source`, `votes` fields
    user.dart                   # id, username, email, role
    contribution.dart
    comment.dart
    token_pair.dart
    admin_stats.dart
```

### Auth Interceptor

Attach `Authorization: Bearer <accessToken>` to all authenticated requests. On 401, attempt silent refresh (`POST /auth/refresh`). If refresh fails, emit logout → navigate to login page.

### Error Handling

| HTTP status | Behavior |
|---|---|
| 401 | Silent token refresh → retry once; logout on second failure |
| 403 | Snackbar: "Akses ditolak" |
| 404 | Inline "tidak ditemukan" message |
| 422 | Map field-level errors to form validation |
| 5xx | Retry banner |
| Network timeout | Offline banner; dictionary readable from cache |

---

## Non-Functional Requirements

| Requirement | Target |
|---|---|
| Cold start to word list | < 2s on mid-range device |
| Search response (debounced 300ms) | < 500ms |
| Token refresh | Silent, < 1s, transparent to user |
| Guest experience | Full dictionary access, no degradation |
| Offline mode | Dictionary browsable from cache; community features show offline state |
| Min Android SDK | `flutter.minSdkVersion` |
| Min iOS | 12.0 |

---

## Phased Delivery

| Phase | Scope | Key endpoints |
|---|---|---|
| 1 | Auth (optional login/register), AuthState provider, login nudge UI | `/auth/*` |
| 2 | Server bookmarks + local migration for returning users | `/bookmarks/*` |
| 3 | Voting, comments, word of the day | `/words/{word}/vote`, `/words/{word}/comments`, `/comments/*`, `/words/of-the-day` |
| 4 | Word proposals (submit, edit, withdraw, my list) | `/contributions/*` |
| 5 | Admin panel (word management, proposal review, moderation, stats) | `/admin/*` |

Phases 3–5 require Phase 1. Phase 2 requires Phase 1. Phases 3, 4, 5 are independent of each other.
