# grimmory-flutter

An unofficial Android client for [Grimmory](https://grimmory.org), a
self-hosted digital library server. Built to fill the mobile-app gap left by
switching away from Audiobookshelf, with **Android Auto** support as the
headline feature — something no Grimmory client offers today.

Scope: **audiobooks** (streaming or offline download) and **EPUB** ebook
reading. Other ebook/comic formats your library holds (PDF, CBX, FB2, MOBI,
AZW3) show up in the library grid so you can see what's there, but aren't
readable in-app yet — tracked in [#46](../../issues/46). **Android only** for
now (no iOS/CarPlay).

## Features

- Onboarding for any self-hosted Grimmory server URL (no fixed domain/tenant)
- Local email/password login, or SSO via any OIDC provider your Grimmory
  instance is configured with
- Browse libraries, series, authors, and shelves; full-text search
- Filter a library down to just Audiobooks or just Ebooks
- Full audiobook playback: single- and multi-file books, resume-from-progress,
  autosaved progress, adjustable speed, sleep timer, chapter/track navigation,
  bookmarks
- EPUB reading with a chapter list and synced reading progress
- Offline downloads for audiobooks
- Android Auto: browse Continue Listening, libraries, and series, and start
  playback from the car's head unit

## Status

Functional and tested against a live Grimmory instance — Grimmory's REST API
is explicitly marked unstable and undocumented for its actual response
shapes, so several real bugs (wrong field names, wrong ID types, a
server-side lazy-loading crash on one endpoint) were found and fixed this
way rather than by guessing. See `docs/plan.md` (§5–§7) for the specifics of
what was wrong and how it was confirmed/fixed.

See `docs/plan.md` for the full design and milestone breakdown (M0 spike →
M1 auth/browsing → M2 playback → M3 Android Auto → M4 polish/release).

**Known gaps**: in-app reading is EPUB-only for now (see scope above and
[#46](../../issues/46)), and the Android Auto browse tree hasn't been
verified against a real head unit or the Desktop Head Unit emulator yet
(see Testing Android Auto below).

## Getting started

1. Install a [release APK](../../releases) on your Android device, or build
   from source (below).
2. On first launch, enter your Grimmory server's URL.
3. Sign in with your Grimmory account, or via SSO if your instance has an
   OIDC provider configured.

If playback stops unexpectedly when your phone's screen is off, see
Settings → "Background playback getting interrupted?" — some Android
manufacturers aggressively battery-optimize background audio apps by
default.

## Development

```
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs  # regenerate freezed/json_serializable models
flutter analyze
flutter test
```

Every PR runs `.github/workflows/pr-check.yml`: format/analyze/test, a debug
Android build, and an [OSV-Scanner](https://google.github.io/osv-scanner/)
dependency vulnerability check.

Signed release builds go through `.github/workflows/release.yml`
(`workflow_dispatch`, tags `vX.Y.Z`, attaches the APK to a GitHub Release) —
this dev environment doesn't run local Gradle/Android builds (verify via CI
instead). `.github/workflows/dev-build.yml` builds a signed sideload APK
without cutting a release, also via `workflow_dispatch`.

### Testing Android Auto

1. Install the Android SDK's Desktop Head Unit: `sdkmanager "extras;google;auto"`
2. On an Android phone with the app installed, open the Android Auto app,
   tap the version number repeatedly to enable Developer Mode, then enable
   "Unknown sources"
3. Connect the phone via USB debugging, run `adb forward tcp:5277 tcp:5277`
4. Launch `desktop-head-unit` from the SDK's `extras/google/auto` directory
5. Verify the browse tree (Libraries/Series → books), tapping a book starts
   playback with correct art/metadata, and transport controls work from the
   head unit

A real head unit or car is worth testing too — the DHU sometimes diverges
from real hardware rendering.

## License

MIT — see [LICENSE](LICENSE).
