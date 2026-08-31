# grimmory-flutter — Audiobook client for Grimmory, with Android Auto

## Context

You're replacing Audiobookshelf with **Grimmory** (https://grimmory.org, self-hosted, Spring Boot + MariaDB, AGPL-3.0, a community fork of BookLore). Grimmory has no official mobile app and no Android Auto support today, and Audiobookshelf's mobile app is the feature you'd otherwise lose by switching. This plan scaffolds a new, standalone Flutter app — **audiobooks only** (no ebook/comic reader) — that talks to a self-hosted Grimmory instance, with Android Auto as the headline feature.

This is a brand-new repo, **`grimmory-flutter` on your public GitHub account (`github.com/schmitzkr`)** — deliberately not on the self-hosted Gitea like your other `schm*` apps, so it gets its own self-contained CI with no dependency on the org's shared Gitea reusable workflows, OpenBao, or Komodo. Nothing in this workspace has ever built background audio streaming or an Android Auto (MediaBrowserService) surface before, so that part is genuinely new ground here, not a pattern to copy from an existing repo — everything else (auth storage, API client shape, Riverpod/go_router structure, CI skeleton) can and should borrow directly from `schmlist-flutter`, which is the most current, actively-maintained Flutter app in this workspace.

**Confirmed decisions**: audiobooks only, stream-only for v1 (no offline downloads), support both local-JWT and OIDC login, Android-only for v1 (no iOS/CarPlay), MIT license.

## 1. Grimmory API (confirmed via research against grimmory.org / github.com/grimmory-tools/grimmory)

REST API under `/api/v1`, docs at `https://grimmory.org/api/` (and `/api/openapi.json` on a live instance if `API_DOCS_ENABLED=true`). **Explicitly marked unstable** — verify exact request/response shapes against a live instance or the OpenAPI spec before hardcoding field names; treat this plan's field-name assumptions (e.g. `access_token`/`refresh_token`, borrowed from schmlist's response shape) as unconfirmed until checked. **Not Audiobookshelf-wire-compatible** — different data model, don't borrow ABS client assumptions.

- Auth: `POST /auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/register` (local JWT); `/auth/oidc/*` (OIDC — exact contract to be confirmed, see §3.3)
- Libraries: `GET /libraries`, `/libraries/{id}`, `/libraries/{id}/book`
- Items/metadata: `GET /books`, `/books/{bookId}`, `/file-metadata`; audiobook-specific `GET /audiobooks/{bookId}/info`, `/audiobooks/{bookId}/cover`
- Streaming: `GET /audiobooks/{bookId}/stream` (single-file), `/audiobooks/{bookId}/track/{trackIndex}/stream` (multi-file)
- Progress: `POST /books/progress`, `/books/reset-progress` — shared across ebooks/audiobooks, Grimmory's own client autosaves every ~5s (per https://grimmory.org/docs/reader/audiobook-player/)
- Series: `GET /app/series`, `/app/series/{seriesName}/books`
- Search/browse: `GET /books/page`, `/books/facets`
- Bookmarks: full CRUD under `/bookmarks`

## 2. Reference patterns from `schmlist-flutter` (read directly, confirmed current)

- **Stack**: Dart SDK `^3.11.1`, Flutter pinned `3.41.9` in CI, `flutter_riverpod ^3.3.2` (no codegen — plain `Provider`/`AsyncNotifier`), `go_router ^17.3.0`, `dio ^5.8.0+1`, `flutter_secure_storage ^10.3.1`, `shared_preferences ^2.5.2`, `oidc ^0.13.0` + `oidc_default_store ^0.5.0` + `app_links ^6.4.1` + `url_launcher`, `freezed`/`json_serializable`, `flutter_lints ^6.0.0`, `flutter_launcher_icons ^0.14.3`.
- **`lib/core/api/api_client.dart`** (`~/code/schmlist-flutter/lib/core/api/api_client.dart`): single `Dio` instance, bearer-token interceptor with in-memory token cache, single-flight `_refreshFuture` to dedupe concurrent 401 refreshes, explicit skip-refresh path list (`/auth/refresh`, `/auth/login`, `/auth/register`, `/auth/logout`, oidc callback), one-time GET-only retry on transient connection errors. **Copy this shape directly** for Grimmory's `Dio` client.
- **OIDC**: `~/code/schmlist-flutter/lib/features/auth/deep_link_oidc_user_manager.dart` — confirmed by direct read: the **app itself runs the full PKCE flow** against the IdP (via `url_launcher`'s `LaunchMode.externalApplication`, not an in-app AppAuth activity, because AppAuth's redirect handling breaks with non-Chrome default browsers), captured via `app_links`' redirect stream, then hands the resulting **ID token to the server's own `/auth/oidc/callback`** endpoint, which verifies it and returns the same response shape as `/auth/login`. This is a proven, working pattern — port it fairly directly. The one real difference: schmlist has one fixed Authentik tenant hardcoded (`clientId`, discovery URL, `https://lists.mael.is/oauthredirect` App Link redirect). Grimmory has no fixed domain — every user points the app at their own instance with their own IdP — so:
  - Redirect target must be a **custom URI scheme** (`is.schmitzkr.grimmory://oidc-callback`), not a domain-verified App Link (no fixed domain to verify `assetlinks.json` against).
  - OIDC issuer/discovery URL and client ID become **user-entered settings** (a small "SSO settings" screen), not hardcoded constants — since each self-hosted Grimmory instance may point at a different IdP.
- **Router**: `~/code/schmlist-flutter/lib/app/router.dart` — `go_router` + a single `routerProvider`, `redirect:` gated on an `authProvider` `AsyncNotifier<User?>`, with a `ValueNotifier<bool>` "initial redirect done" guard so it doesn't redirect mid-auth-load or mid-cold-start-deep-link. Reuse this structure — it already solves the exact "don't redirect while auth state or an OIDC deep link is still resolving" problem this app will hit too.
- **CI**: `.gitea/workflows/cut-release.yml`'s `build` job (the one job not hidden behind a Gitea reusable-workflow call) has the concrete, reusable Android build steps: Java 17 temurin, Android SDK 35 / build-tools 35.0.0, Flutter `3.41.9` via `subosito/flutter-action@v2`, pub-cache + Gradle caches, `KEYSTORE_BASE64` secret decoded to `.jks`, `flutter build apk --release --split-per-abi --target-platform android-arm64 --obfuscate --split-debug-info=...`. Port these steps into plain GitHub Actions YAML (everything else in that repo's workflows calls Gitea-org-specific reusable workflows — do not copy those, only this job's raw steps).
- **No precedent anywhere in this workspace** for `audio_service`, `just_audio`, `media_kit`, or any MediaBrowserService/Android Auto integration — this app is the first, treat it as a research spike, not a pattern to port.

## 3. Design

### 3.1 Repo scaffolding
- `flutter create --org is.schmitzkr --project-name grimmory --platforms android grimmory-flutter` (Android only per confirmed scope — omit `ios` from `--platforms`).
- MIT `LICENSE` file.
- `pubspec.yaml`: same core deps as schmlist (Riverpod v3, go_router, dio, flutter_secure_storage, shared_preferences, oidc/oidc_default_store/app_links/url_launcher, freezed/json_serializable, flutter_lints, flutter_launcher_icons) plus audio-specific additions:
  - `audio_service` — background playback service + Android MediaBrowserService surface (this is what makes Android Auto possible at all)
  - `just_audio` — playback engine (HTTP streaming with auth headers, gapless multi-track, seek, speed control)
  - `audio_session` — audio focus / interruption handling (phone calls, other media)
  - `cached_network_image` — cover art, new dep with no workspace precedent but the standard choice
- `analysis_options.yaml`: `include: package:flutter_lints/flutter.yaml`, no extra rules, matching schmlist's minimal config.
- `.gitignore`: standard Flutter, with `*.jks`/`*.keystore` explicitly excluded.
- **lib/ layout** (mirrors schmlist):
  ```
  lib/
    app/router.dart
    core/
      api/{api_client.dart, models.dart, errors.dart}
      providers.dart
      server_config.dart          # NEW: server URL validation/normalization
    features/
      onboarding/                 # NEW: "connect to your server" first-run flow
      auth/{auth_provider.dart, login_screen.dart, oidc_login.dart, deep_link_oidc_user_manager.dart, sso_settings_screen.dart}
      library/
      browse/                     # series, search
      book/
      player/{audio_handler.dart, playback_provider.dart, player_screen.dart, sleep_timer.dart}
      bookmarks/
      settings/
    main.dart
  ```

### 3.2 First-run onboarding (new — no fixed server domain like schmlist has)
1. **Server URL screen**: text field for the Grimmory base URL, normalize (strip trailing slash, default `https://`), probe reachability before continuing (verify exact unauthenticated health/version endpoint against a live instance in M0 — fall back to treating a 401 on `/libraries` as "reachable, needs login" vs. a connection error as "bad URL"). Store confirmed URL in `shared_preferences` (`server_url`), wire into `ApiClient.updateBaseUrl()`.
2. **Login screen**: email/password form (local JWT) plus a "Sign in with SSO" option. If SSO is chosen and no issuer/client-id is configured yet for this server, route to the SSO settings screen first.
3. **Settings → change server**: logout + clear `server_url`/tokens + return to onboarding, for anyone who switches instances.

### 3.3 Auth — dual local-JWT / OIDC
- Local JWT: port `ApiClient`'s `login()`/`_doRefresh()`/interceptor pattern directly (§2), targeting Grimmory's actual `/auth/login`/`/auth/refresh`/`/auth/logout` — **confirm exact response field names against a live instance or the OpenAPI spec in M0**, don't assume they match schmlist's.
- OIDC: port `DeepLinkOidcUserManager` with the two adjustments in §2 (custom-scheme redirect, per-server issuer/client-id settings), then call whatever Grimmory's `/auth/oidc/*` callback endpoint actually expects. **This is the single biggest unknown in the plan** — resolve in M0 against a real Grimmory instance with OIDC configured (or its source at github.com/grimmory-tools/grimmory) before writing the deep-link manager for real.
- Token storage: `flutter_secure_storage` for `access_token`/`refresh_token` (non-negotiable — same as schmlist). `shared_preferences` for `server_url`, `server_version`, `auth_method`.

### 3.4 API client & models
- `lib/core/api/api_client.dart`: one `Dio`-backed class covering every endpoint in §1, same interceptor/refresh shape as schmlist's.
- Models (`freezed`/`json_serializable`, split per-domain given audiobook metadata is heavier than schmlist's flat `models.dart`): `Library`, `Book` (base) + `AudiobookInfo` (tracks, chapters, duration, narrator — fetched separately via `/audiobooks/{id}/info` and merged in the detail screen, matching the API's actual split), `Track`, `Chapter` (confirm in M0 whether Grimmory's audiobook info distinguishes chapter markers from tracks/files), `Series`, `Progress`, `Bookmark`.
- `errors.dart`: re-derive Grimmory's actual status codes/messages in M0/M1 — don't copy schmlist's app-specific error branches (e.g. its CalDAV/AI-billing cases) verbatim.

### 3.5 Library browsing UI
- Libraries list (post-login landing, via router `redirect`) → library detail (`/libraries/{id}/book` grid, cover art via `/audiobooks/{bookId}/cover` — needs auth headers, so use a `Dio`-backed image provider or `cached_network_image`'s custom headers, not a bare network image).
- Series tab (`/app/series`, `/app/series/{name}/books`).
- Search (`/books/page` + `/books/facets` for filter chips).
- Book detail: cover, metadata (merged `Book` + `AudiobookInfo`), track/chapter list, resume-from-progress, bookmarks, Play CTA.

### 3.6 Playback
- `GrimmoryAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler` wrapping a `just_audio.AudioPlayer`.
- Single-file book → one `AudioSource.uri(streamUrl, headers: {Authorization: bearer})`. Multi-file book → `ConcatenatingAudioSource` of per-track authed sources (gapless, and doubles as Android Auto's skip-next/prev = next/prev track).
- **Auth header caveat**: a long book can outlive its access token. Handle via proactive refresh before building the source when near expiry, or catching a mid-stream 401 via `just_audio`'s error stream and rebuilding the source at the last known position after a silent refresh (the audio engine's HTTP client is separate from `Dio`, so the existing interceptor doesn't cover this path).
- Progress autosave: `Timer.periodic(5s)` while playing → `POST /books/progress`; also fire immediately on pause/stop/app-backgrounded so short sessions aren't lost. Guard against overlapping saves the same way `_refreshFuture` guards concurrent refreshes.
- Chapter navigation: in-app UI list calling `player.seek()` directly (not exposed as OS-level skip, which should mean track/file, not fine-grained chapter).
- Playback speed: `just_audio.setSpeed()`, 0.75x–3.0x cycling control, persisted globally in `shared_preferences`.
- Sleep timer: **flagged assumption, not explicitly requested but standard for audiobook apps and cheap to add** — simple countdown or end-of-chapter trigger pausing playback, no server interaction. Deprioritize first if time is tight.
- Cover art for the OS notification / Android Auto `artUri`: Android's media UI fetches `artUri` without the app's auth headers, so cache covers locally (e.g. via `cached_network_image`'s disk cache) and hand Auto a `file://` URI, not the raw authed HTTPS one — confirm in M0 whether `/audiobooks/{bookId}/cover` even requires auth at all, which simplifies this if not.

### 3.7 Android Auto
`audio_service`'s Android backend already implements `MediaBrowserServiceCompat` — implement `getChildren(parentMediaId)` in `GrimmoryAudioHandler`, no custom Kotlin needed for the base case.
- Browse tree: `root` → `Libraries` → per-library → per-book (playable); `Series` → per-series → per-book; `Continue Listening` → in-progress books, most recent first.
- Manifest: confirm `audio_service`'s auto-merged `<service>`/`<receiver>` entries land correctly; add `<meta-data android:name="com.google.android.gms.car.application" android:resource="@xml/automotive_app_desc" />` + `android/app/src/main/res/xml/automotive_app_desc.xml` (`<uses name="media" />`); `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK` (Android 14+), `WAKE_LOCK` permissions; notification icon resource.
- Testing: **Desktop Head Unit (DHU)** via `sdkmanager "extras;google;auto"`, Developer Mode in the Android Auto app (tap version number repeatedly), `adb forward tcp:5277 tcp:5277`, then `desktop-head-unit` from the SDK. Verify browse tree at every level, playback start/metadata/art, transport controls, resume-from-progress, and survival through screen-off/backgrounding (battery-optimization exemption may be needed — known pain point for background-audio Flutter apps). Follow up with a real head unit or car before considering this milestone done, since DHU sometimes diverges from real hardware rendering.

### 3.8 CI/CD — self-contained GitHub Actions
- `.github/workflows/pr-check.yml`: checkout, `subosito/flutter-action@v2` (Flutter `3.41.9`), `flutter pub get`, `flutter analyze`, `flutter test`. Add a `cmake`/`ninja-build` apt step if `oidc_default_store`'s native-asset build needs it here too (confirm at scaffold time, same reasoning schmlist documented for the same dependency).
- `.github/workflows/release.yml`: manual `workflow_dispatch` (version input) → analyze/test → bump `pubspec.yaml` version → Android SDK 35/build-tools 35.0.0 setup + Gradle/pub caches → decode `KEYSTORE_BASE64` repo secret → `flutter build apk --release --split-per-abi --target-platform android-arm64 --obfuscate --split-debug-info=...` → git tag → `softprops/action-gh-release@v2` attaching the APK. Repo secrets: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` (generate the keystore once locally via `keytool`, upload manually — this is the direct replacement for OpenBao here since this repo has no access to it).
- Optional `.github/workflows/dev-build.yml`: same signed-build steps minus tagging/release, `actions/upload-artifact@v4` for sideload testing — schmlist's own equivalent proves this loop is worth having.
- No ntfy/Komodo/OpenBao/`/api/app-release` integration — this repo has no backend of its own; updates ship via the GitHub Releases page.

## 3.9 UX/terminology parity with Grimmory
The goal is for this app to feel like a native extension of Grimmory, not a generic third-party client — match its own terminology, browse structure, and metadata presentation rather than inventing our own vocabulary (e.g. whatever Grimmory's web UI calls a "library" vs. "shelf," how it groups/orders series, which metadata fields it surfaces and in what order). Concrete matching only becomes possible once there's a live instance to click through (M0+) — until then, screens use best-guess generic terms and should be revisited against the real web UI as soon as one is available, rather than treated as final. Revisit at the start of M1's UI work and again during M3 testing.

## 3.10 Commit workflow
Commit regularly and incrementally as work progresses (e.g. per logical chunk within a milestone), not just once per milestone — using **Conventional Commits** format (`feat:`, `fix:`, `chore:`, `docs:`, etc.), same convention as the rest of this workspace. Every commit gets a trailer crediting Claude Code as assisting author:
```
Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
```
No `Claude-Session` link in commits for this repo (user preference, 2026-08-29 — differs from this workspace's other repos).

Since this repo lives on GitHub (not Gitea), still follow this workspace's default branch → PR → merge flow rather than pushing straight to `main` (per global git-command preferences) — batch each milestone's commits onto one branch and open a PR at natural checkpoints, asking before merging. **No exceptions going forward (2026-08-30)**: treat `main` as if branch protection were enforced even though it isn't (private repo, no GitHub Pro) — every change, however small, goes through a PR. The very first scaffold commit was bootstrapped directly on `main` before this was tightened; that's a one-time historical exception, not a standing one.

## 4. Milestones (for later GitHub issue seeding)

- **M0 — Spike**: get access to a live/test Grimmory instance with OIDC configured; confirm exact `/api/v1/auth/*` JSON shapes; **resolve the OIDC redirect/callback contract** (blocks all of §3.3's OIDC work); confirm chapter-vs-track shape in `/audiobooks/{bookId}/info`; confirm whether `/audiobooks/{bookId}/cover` requires auth.
- **M1 — Auth + library browsing**: scaffold, CI `pr-check.yml`, `ApiClient` (auth/libraries/books/series), onboarding (server URL, local login, OIDC per M0), libraries/series/search/book-detail screens (no playback yet), settings (logout, change server).
- **M2 — Playback core**: `audio_service`/`just_audio` integration, single/multi-file streaming, player screen (play/pause/seek/skip/speed), progress autosave, sleep timer, bookmarks CRUD.
- **M3 — Android Auto**: browse tree, manifest entries, local cover-art caching for `artUri`, DHU testing then real head-unit verification.
- **M4 — Polish/release**: `release.yml`/`dev-build.yml` finalized, keystore generated + repo secrets set, app icon, error-message pass grounded in Grimmory's real responses, battery-optimization/foreground-service reliability check, README, first tagged `v0.1.0`.

## 5. M0 findings (confirmed 2026-08-30 against a live instance, grimmory.mael.is)

The user provided a real, running Grimmory server. Probed read-only/unauthenticated (no login credentials available or used) — every path this project's `ApiClient` calls returns a genuine `401` (`application/json`, Spring Security's real filter chain), not the Angular SPA's catch-all HTML fallback, confirming **every guessed endpoint path is correct**. Response *body* shapes for authenticated endpoints remain unconfirmed (Spring Security rejects before `@Valid` body validation runs), but the public auth endpoints yielded real validation errors that fixed several real bugs:

- **Login field is `username`, not `email`** — the app's local-JWT login was built assuming an email address; Grimmory's own validation error says `"username: Username must not be blank"`. Fixed in `ApiClient.login`, `AuthNotifier.login`, and `LoginScreen` (field relabeled, `_emailController`→`_usernameController`, dropped `TextInputType.emailAddress`).
- **The whole API uses camelCase JSON, not snake_case** — confirmed via `/auth/refresh`'s validation error (`refreshToken`, not `refresh_token`) and the OIDC callback's five fields (all camelCase). Every hand-written snake_case request body/query key in `ApiClient` was wrong: `resetProgress`, `getBookmarks`, `createBookmark`, `_doRefresh`, `logout`. Fixed to camelCase throughout. (The freezed model classes were already camelCase Dart fields with no `@JsonKey` renaming, so their generated `toJson()`/`fromJson()` — e.g. `Progress`, `Bookmark` — were already correct; only the hand-written `Map` literals in `ApiClient` were bugged.)
- **The OIDC callback contract is a third shape, different from both options this plan originally considered.** It's neither "app exchanges the code itself and hands over a completed ID token" (schmlist's pattern, what was originally built) nor "server hosts its own login/authorize redirect" (`/auth/oidc/login`, `/authorize`, `/providers` all resolve to the SPA fallback — those routes don't exist). It's: **the app runs the authorize-request half of PKCE itself (open the IdP's authorization endpoint, get back `code`+`state`), then hands the *raw, unexchanged* result to Grimmory's server** — confirmed via a live validation error listing the exact required fields: `code`, `state`, `codeVerifier`, `nonce`, `redirectUri`. Grimmory's own backend performs the code-for-token exchange against the IdP. This eliminated the need for the `oidc` package's `OidcUserManager`/`oidc_default_store` entirely (that class always performs its own token exchange) — replaced with a much smaller hand-rolled flow using only `oidc_core`'s low-level `OidcPkcePair`/`OidcAuthorizeRequest`/`OidcEndpoints.getProviderMetadata` utilities (still reached via `package:oidc`, which re-exports `oidc_core`). See `lib/features/auth/oidc_login_controller.dart`.
  - Bonus effect: removing `oidc_default_store` also removed its transitive `webcrypto` dependency — the one thing that ever needed the `cmake`/`ninja-build` native-asset build step. That CI step (and the equivalent local requirement) is gone from all three workflows and no longer needed at all.
- **Cover art requires auth**, confirmed (`/audiobooks/{id}/cover` returns a real 401) — validates the design decision already taken (§3.6): `MediaItem.artHeaders` carries the same bearer token, no local-caching workaround was ever needed.
- **The guessed `GET /books/{id}/progress` endpoint is real** (routes to a genuine 401, not the SPA fallback) — no longer just a guess, though its response shape is still unconfirmed.
- Error response shapes: a confirmed 400 validation error is `{"details": ["field: message", ...], "message": "Validation error", "status": 400, "timestamp": ...}`; other statuses (401 confirmed, others presumed) use plain Spring Boot's default `{"timestamp", "status", "error", "path"}` with no message to surface. `errors.dart`'s `friendlyApiError` now parses `details`/`message` for 400s.
- `/api/v1/auth/me` and `/api/v1/auth/register` both exist as real routes (`register` requires existing admin auth — not public self-service) — not currently used by the app, noted for future reference.
- **Still unconfirmed**: exact login/refresh *response* body shape (field names for the returned tokens — currently assumed `accessToken`/`refreshToken`, consistent with the camelCase pattern but not individually validated), chapter-vs-track distinction in `/audiobooks/{id}/info`, and general UX/terminology parity (§3.9) — all still need either real credentials or a browser walkthrough of the actual Grimmory web UI, neither of which this probing pass had access to.

## 6. Second live-data pass (2026-08-31) — the "Something went wrong" crash on Libraries

The user hit a real crash the moment they logged in on `grimmory.mael.is`: the Libraries screen showed the generic "Something went wrong" fallback. Server logs showed nothing (Spring doesn't log a plain 401/200, only unhandled exceptions), which pointed at a **client-side parse failure**, not a network/server problem. Since Grimmory is open source (`github.com/grimmory-tools/grimmory`, package `org.booklore` — it's a rebrand/fork of BookLore), the fix was to read the actual Java DTOs and controllers directly via `gh api`/`gh search code`, rather than keep guessing against the unstable/undocumented API.

**Root cause**: `Library.id` (and every entity ID in the system — books, bookmarks, everything) is a Java `Long`, not a String/UUID. §1's original guesses assumed string IDs throughout; the very first field access on login (`Library.fromJson`'s `id`) threw a type error.

**Much bigger finding while fixing it**: there's a dedicated `/api/v1/app/*` controller package (`AppLibraryController`, `AppBookController`, `AppSeriesController`, etc.) — a purpose-built mobile-app API surface, separate from the general endpoints §1 was built against. It has exactly what a mobile client needs and the general endpoints don't: paginated summary DTOs, a real `continue-listening` endpoint (finally fills the Android Auto browse-tree gap noted in §3.7/M3), and the actual progress read/write endpoints. This app now uses `/app/*` wherever it covers a need, falling back to the general endpoints only for audiobook streaming/info (not app-namespaced) and bookmarks (ditto).

Corrected against the real source (all confirmed by reading the actual `.java`/`.ts` files, not guessed):
- **IDs are `int` everywhere** in the Flutter models now (`Library.id`, `Book.id`, `Bookmark.id`/`bookId`), not `String`.
- **Libraries**: `GET /app/libraries` → bare array of `AppLibrarySummary` (`id, name, icon, bookCount` — there's no "type" field, that was invented).
- **Books**: `GET /app/books?libraryId=&page=&size=` (paginated, `{content: [...], ...}` wrapper — not a bare array), `GET /app/books/{id}` for detail, `GET /app/books/search?q=`, `GET /app/books/continue-listening?limit=`. A `Book`/`AppBookSummary` has `authors: List<String>` (plural!), not a single `author` string, and `seriesName`/`narrator` live directly on the summary (not nested under a separate metadata fetch, contrary to §3.4's original assumption).
- **Playback structure** (`GET /audiobooks/{id}/info`, still not app-namespaced): the real shape is `{bookId, narrator, durationMs, folderBased, chapters: [...], tracks: [...]}` — `folderBased` is the field that actually tells you whether a book is one continuous stream (with `chapters` as pure in-stream markers) or split across multiple physical files (`tracks`, each independently streamable, with `cumulativeStartMs` giving each track's offset in the book-wide timeline). Both `tracks` and `chapters` can coexist on a folder-based book. This is a real architecture correction from §3.6/M2's implementation, which treated "multi-file" and "chapters" as the same concept (they aren't) and always built a `ConcatenatingAudioSource` keyed on file count with no way to distinguish "one file with chapter markers" from "one file, no markers" — now: build a `ConcatenatingAudioSource` only when `folderBased`, and convert between "track-relative" and "book-wide absolute" position using `cumulativeStartMs` wherever the progress API and the player disagree on which frame of reference they're using.
- **Progress**: not the guessed flat `POST /books/progress` — it's `GET`/`PUT /app/books/{id}/progress`, body/response shaped as `{audiobookProgress: {positionMs, trackIndex, trackPositionMs, percentage}}` (positions in **milliseconds**, not seconds as originally guessed; `percentage` as a 0.0–1.0 fraction, computed client-side as `positionMs / durationMs` since nothing else provides it).
- **Bookmarks**: `GET /bookmarks/book/{bookId}` (path segment, not a `?bookId=` query param as guessed), `POST /bookmarks` body `{bookId, positionMs, trackIndex, title}`. The field is `notes` (plural), not `note`.
- **Auth for streaming**: confirmed via `QueryParameterJwtFilter`'s actual source that a normal `Authorization` header works fine for `/audiobooks/**` — the `?token=` query-param path some Grimmory API consumers use exists only as a fallback for browser `<audio>`/`<img>` tags that can't set custom headers, which doesn't apply to this app. No change needed to the existing header-based approach.
- **Series**: `GET /app/series` is also paginated (`AppSeriesSummary`: `seriesName`, `bookCount`, `authors`) — same `{content: [...]}` wrapper as books.

This is exactly the kind of error the original M0 pass (§5) couldn't catch: everything there was confirmed via *unauthenticated* probing (endpoint paths, public auth-endpoint validation errors), which can't see response *bodies* on authenticated endpoints at all. The lesson: once real credentials or real source access are available, re-verify response shapes specifically — path-level confirmation and body-shape confirmation are genuinely different levels of assurance, and this project had only ever done the former until now.

## 7. `/app/libraries` server bug (2026-08-29/30) — client-side workaround

While testing v0.3.0 against `grimmory.mael.is`, the Libraries screen started failing with a server-side `500`. Server logs showed `org.hibernate.LazyInitializationException` thrown from `AppLibraryController.getLibraries()` → `AppBookMapper.toLibrarySummary()`, recurring on **every single call**, across multiple separate testing sessions (12 occurrences confirmed across three timestamp clusters spanning ~6 minutes) — not transient.

Confirmed via the real Grimmory source (`github.com/grimmory-tools/grimmory`), not guessed:
- `AppLibraryController.getLibraries()` (`/api/v1/app/libraries`) has no `@Transactional`, takes no request parameters at all, and simply calls `libraryRepository.findAll()`/`findByIdIn()` then maps each result via `AppBookMapper.toLibrarySummary()`.
- That mapper accesses `library.getLibraryPaths()` — a plain field read, no conditions — and `LibraryEntity.libraryPaths` is `@OneToMany(..., fetch = FetchType.LAZY)`. Outside an active Hibernate session, that throws unconditionally.
- **This app's call is not the problem** — the endpoint has no parameters to get wrong, and the exception fires identically for every caller/user/library-count.
- Grimmory's own Angular frontend never calls `/app/libraries` at all — its Libraries page calls the separate general `GET /api/v1/libraries` (`LibraryController` → `LibraryService`, a different DTO/code path with no equivalent lazy-collection touch), which is what's actually exercised in production. `/app/libraries` looks to have never been hit by real traffic before this app started calling it.

**Workaround** (this app only — no server changes, per the "only touch the app" rule): `ApiClient.getLibraries()` now calls the general `/libraries` endpoint instead of `/app/libraries`. Confirmed working (it's the same endpoint the real web frontend depends on for the same screen) and returns the same permission-filtered library list (admin sees all, non-admin sees only assigned libraries — verified in `LibraryService.getLibraries()`). Tradeoff: the general `Library` DTO has no `bookCount` field, so `Library.bookCount` is always the `@Default(0)` fallback for now — the Libraries screen's "N books" subtitle will read "0 books" until upstream is fixed. Revert to `/app/libraries` once fixed upstream (tracked via a filed bug report — see repo issue tracker).

## Verification
- `flutter analyze` / `flutter test` clean at each milestone (wired into `pr-check.yml` from M1 onward).
- M1: manually log in against a real Grimmory instance (both local JWT and OIDC), browse libraries/series/search, confirm token refresh survives an expired access token.
- M2: manually stream and control playback for both a single-file and a multi-file audiobook, confirm progress resumes correctly after killing and reopening the app, confirm playback survives token expiry mid-stream.
- M3: DHU walkthrough of the full browse tree + transport controls, then a real Android Auto head unit (car or compatible test rig) before considering Android Auto "done".
- M4: a full signed release build via `release.yml` end-to-end, install the resulting APK, confirm the GitHub Release page has the right artifact and notes.
