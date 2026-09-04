<img src="assets/icon/icon.png" alt="GrimReader app icon" width="120" align="left" />

### GrimReader

An unofficial Android client for [Grimmory](https://grimmory.org), a
self-hosted digital library server. Built to fill the mobile-app gap left by
switching away from Audiobookshelf.

Scope: **audiobooks** (streaming or offline download) and **EPUB** ebook
reading. Other ebook/comic formats your library holds (PDF, CBX, FB2, MOBI,
AZW3) show up in the library grid so you can see what's there, but aren't
readable in-app yet — tracked in [#46](../../issues/46). **Android only** for
now (no iOS/CarPlay).

<br clear="left" />

## Features

- Onboarding for any self-hosted Grimmory server URL (no fixed domain/tenant)
- Local email/password login, or SSO via any OIDC provider your Grimmory
  instance is configured with
- Browse libraries, series, authors, and shelves; full-text search
- Filter a library down to just Audiobooks or just Ebooks
- Full audiobook playback: single- and multi-file books, resume-from-progress,
  autosaved progress, adjustable speed, sleep timer, chapter/track navigation,
  bookmarks
- A persistent mini-player shows what's currently playing (and lets you
  pause/resume) from anywhere in the app, and the book detail screen shows a
  "Now playing"/"Paused" indicator so it's always clear which book you're
  hearing
- EPUB reading with a chapter list, tap-to-turn-page and swipe navigation,
  swipe-down to open bookmarks, light/dark reader themes, and synced reading
  progress
- Reading progress is tracked the same way Audiobookshelf shows it: a
  progress bar on in-progress book covers, a finished checkmark badge once
  you're done, and a "Continue Reading" row alongside "Continue Listening" on
  the Libraries tab
- Offline downloads for audiobooks
- Android Auto: browse Continue Listening, libraries, and series, and start
  playback from the car's head unit
- In-app "What's New" release notes and an update banner that downloads and
  installs the latest release APK directly (no browser hand-off)

## Status

Functional and tested against a live Grimmory instance — Grimmory's REST API
is explicitly marked unstable and undocumented for its actual response
shapes, so several real bugs (wrong field names, wrong ID types, a
server-side lazy-loading crash on one endpoint) were found and fixed this
way rather than by guessing. See `docs/plan.md` (§5–§7) for the specifics of
what was wrong and how it was confirmed/fixed.

See `docs/plan.md` for the original design and milestone breakdown (M0 spike
→ M1 auth/browsing → M2 playback → M3 Android Auto → M4 polish/release);
it's a historical design journal rather than a live status page, so treat
dated sections as a record of decisions made at the time, not a current
TODO list.

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

The local Flutter/Dart toolchain in this dev environment can lag behind
`pubspec.yaml`'s SDK requirements, so `pub get`/`build_runner`/launcher-icon
generation may not be runnable locally at any given time — two
`workflow_dispatch`-only workflows exist so this isn't a blocker:
`.github/workflows/regen-codegen.yml` regenerates and commits
`*.freezed.dart`/`*.g.dart` output, and
`.github/workflows/regen-launcher-icons.yml` regenerates and commits the
Android launcher icon set. Both run against whichever branch they're
dispatched against and push the result back to it.

Every PR runs `.github/workflows/pr-check.yml`: format/analyze/test, a debug
Android build, and an [OSV-Scanner](https://google.github.io/osv-scanner/)
dependency vulnerability check (findings also upload to the repo's Security
tab, now that the repo is public and GitHub Advanced Security is free).
`main` is protected — every change goes through a PR and passing checks.

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
