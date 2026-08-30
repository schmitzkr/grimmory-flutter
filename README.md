# grimmory-flutter

An unofficial Android audiobook client for [Grimmory](https://grimmory.org), a
self-hosted digital library server. Built to fill the mobile-app gap left by
switching away from Audiobookshelf, with **Android Auto** support as the
headline feature — something no Grimmory client offers today.

Scope is deliberately narrow: **audiobooks only** (no ebook/comic reading),
**streaming only** for now (no offline downloads), **Android only** for now
(no iOS/CarPlay).

## Features

- Onboarding for any self-hosted Grimmory server URL (no fixed domain/tenant)
- Local email/password login, or SSO via any OIDC provider your Grimmory
  instance is configured with
- Browse libraries, series, and search
- Full playback: single- and multi-file audiobooks, resume-from-progress,
  autosaved progress, adjustable speed, sleep timer, chapter/track navigation
- Android Auto: browse your libraries and series and start playback from the
  car's head unit

## Status

Functional end-to-end, but **not yet verified against a live Grimmory
instance** — Grimmory's REST API is explicitly marked unstable, and several
request/response shapes used here (the OIDC callback contract, the
per-book progress endpoint, chapter-vs-track metadata shape) are
best-guess placeholders pending that verification. See inline `NOTE:`/
unconfirmed-endpoint comments in `lib/core/api/` and `docs/plan.md`'s M0
section for specifics.

See `docs/plan.md` for the full design and milestone breakdown (M0 spike →
M1 auth/browsing → M2 playback → M3 Android Auto → M4 polish/release).

**Known gaps**: no bookmarks UI yet (API support exists in `ApiClient`, no
screen built), no "continue listening" entry in the Android Auto browse
tree (no confirmed API for it), no offline downloads (by design, see
above), Android Auto browse tree hasn't been tested against a real head
unit or the Desktop Head Unit emulator yet.

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
