# grimmory-flutter

An unofficial Android audiobook client for [Grimmory](https://grimmory.org), a
self-hosted digital library server. Built to fill the mobile-app gap left by
switching away from Audiobookshelf, with **Android Auto** support as the
headline feature — something no Grimmory client offers today.

Scope is deliberately narrow: **audiobooks only** (no ebook/comic reading),
**streaming only** for now (no offline downloads), **Android only** for now
(no iOS/CarPlay).

## Status

Early scaffolding. See `docs/plan.md` for the full design and milestone
breakdown (M0 spike → M1 auth/browsing → M2 playback → M3 Android Auto → M4
release). Grimmory's REST API is explicitly marked unstable, and several
request/response shapes used here are best-guess placeholders pending
verification against a live instance (M0) — see inline `NOTE:` comments in
`lib/core/api/`.

## Development

```
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs  # regenerate freezed/json_serializable models
flutter analyze
flutter test
flutter build apk --release  # signed builds go through .github/workflows/release.yml
```

## License

MIT — see [LICENSE](LICENSE).
