# Changelog

## [2.0.0] - 2026-04-18

### Added
- User authentication: optional register/login, profile screen, secure token storage
- Server-side bookmarks for logged-in users with automatic migration from local storage
- Community voting (upvote/downvote) on dictionary entries
- Threaded comments per word entry
- Word of the Day featured card on the dictionary home screen
- Word proposals: authenticated users can submit, edit, and withdraw new word contributions
- My Proposals screen with status tracking (pending, approved, rejected, revised)
- Admin panel: word management, contribution review, comment moderation, user management, WOTD scheduler, stats dashboard
- Source badge ("Komunitas") on community-contributed word entries
- Login nudge for guests attempting community actions

### Changed
- Word model updated to API v2 structure (`meanings`, `syllables`, `votes`, `source`)
- `SavedWordsPage` shows flat word list for authenticated users, category view for guests
- Navigation expanded with Akun tab; Admin tab visible to admin role only

## [1.2.0] - 2025-03-30

### Added
- Added dark mode support for a more comfortable viewing experience in low light 🌙
- Introduced a new navigation menu (bottom navigation on phone, navigation rail on tablet) for easier access to sections 🧭

### Changed
- Improved search functionality with more accurate and faster results 🔍
- Redesigned the UI to instantly show vocabulary entries without requiring users to select an initial letter 🆕
