import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

// Confirmed against Grimmory's real Java source (github.com/grimmory-tools/
// grimmory, package org.booklore — Grimmory is a rebrand/fork of BookLore)
// on 2026-08-31, after the app's original field-name guesses (based on the
// documented-but-unstable API surface alone) turned out wrong in several
// ways: entity IDs are numeric (Java `Long`), not strings; a dedicated
// `/api/v1/app/*` controller namespace exists purpose-built for mobile
// clients (paginated summary DTOs, continue-listening/recently-added
// endpoints) that this app now uses in preference to the general
// `/books`/`/libraries` endpoints the original guesses were based on. See
// ApiClient's doc comment and docs/plan.md for the fuller writeup.

@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}

/// From the general `Library` DTO (`GET /api/v1/libraries`) — see
/// `ApiClient.getLibraries()` for why this app uses that endpoint instead of
/// the purpose-built-but-broken `AppLibrarySummary`/`/app/libraries`.
/// [bookCount] isn't present on this DTO, so it's always the `@Default(0)`
/// fallback for now.
@freezed
abstract class Library with _$Library {
  const factory Library({
    required int id,
    required String name,
    String? icon,
    @Default(0) int bookCount,
  }) = _Library;

  factory Library.fromJson(Map<String, dynamic> json) =>
      _$LibraryFromJson(json);
}

/// Covers both `AppBookSummary` (library/series/search lists) and
/// `AppBookDetail` (single-book fetch) — the latter just has a few extra
/// optional fields (`description`) the former omits, which parses fine
/// either way since json_serializable treats an absent key on a nullable
/// field as null rather than an error.
@freezed
abstract class Book with _$Book {
  const factory Book({
    required int id,
    required String title,
    @Default([]) List<String> authors,
    String? seriesName,
    double? seriesNumber,
    int? libraryId,
    String? narrator,
    String? description,
    // From `AppBookSummary`/`AppBookDetail.primaryFileType` — one of
    // AUDIOBOOK/EPUB/PDF/CBX/FB2/MOBI/AZW3 (matches Library.allowedFormats'
    // enum). Drives which action the book detail screen shows (Play vs.
    // Read vs. "not supported yet") and the library screen's type filter.
    String? primaryFileType,
    // Both already present on every `AppBookSummary`/`AppBookDetail`
    // response (library/series/search/continue-reading/continue-listening
    // all return them) — confirmed against the real DTOs — but never
    // parsed or displayed until now. [readProgress] is 0.0-1.0;
    // [readStatus] is one of Grimmory's `ReadStatus` enum values (UNREAD,
    // READING, RE_READING, READ, PARTIALLY_READ, PAUSED, WONT_READ,
    // ABANDONED, UNSET) — 'READ' is the only one this app currently acts
    // on (a finished-book badge).
    double? readProgress,
    String? readStatus,
  }) = _Book;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
}

/// From `GET /api/v1/audiobooks/{bookId}/info` — a separate endpoint from
/// the general book detail, not under `/app/*` (the mobile-app namespace
/// doesn't cover audiobook-specific playback structure).
@freezed
abstract class AudiobookInfo with _$AudiobookInfo {
  const factory AudiobookInfo({
    required int bookId,
    String? narrator,
    required int durationMs,
    // Whether this audiobook is stored as multiple files (one AudioSource
    // per track) vs. a single file — determines which stream endpoint(s) to
    // use. There's no separate "track count" field; folderBased plus
    // tracks.length is the only way to know.
    @Default(false) bool folderBased,
    @Default([]) List<AudiobookChapter> chapters,
    @Default([]) List<AudiobookTrack> tracks,
  }) = _AudiobookInfo;

  factory AudiobookInfo.fromJson(Map<String, dynamic> json) =>
      _$AudiobookInfoFromJson(json);
}

/// A logical chapter marker — distinct from [AudiobookTrack] (a physical
/// file). Timestamps are relative to the whole book's cumulative timeline,
/// the same as [AudiobookTrack.cumulativeStartMs], regardless of how many
/// underlying files there are.
@freezed
abstract class AudiobookChapter with _$AudiobookChapter {
  const factory AudiobookChapter({
    required int index,
    required String title,
    required int startTimeMs,
    required int endTimeMs,
    required int durationMs,
  }) = _AudiobookChapter;

  factory AudiobookChapter.fromJson(Map<String, dynamic> json) =>
      _$AudiobookChapterFromJson(json);
}

/// A physical audio file within a folder-based (multi-file) audiobook.
/// [cumulativeStartMs] is this track's offset in the book's overall
/// timeline — needed to convert an absolute saved position into a
/// (trackIndex, position-within-track) pair for seeking.
@freezed
abstract class AudiobookTrack with _$AudiobookTrack {
  const factory AudiobookTrack({
    required int index,
    required String fileName,
    required String title,
    required int durationMs,
    int? fileSizeBytes,
    required int cumulativeStartMs,
  }) = _AudiobookTrack;

  factory AudiobookTrack.fromJson(Map<String, dynamic> json) =>
      _$AudiobookTrackFromJson(json);
}

/// From `AppBookProgressResponse.audiobookProgress` (`GET
/// /api/v1/app/books/{bookId}/progress`) and sent back via
/// `UpdateProgressRequest.audiobookProgress` (`PUT` on the same path).
/// [trackPositionMs] only appears on the request/save side in Grimmory's
/// own DTOs (not the read side) — treated as optional here for both
/// directions rather than modeling that asymmetry.
@freezed
abstract class AudiobookProgress with _$AudiobookProgress {
  const factory AudiobookProgress({
    required int positionMs,
    int? trackIndex,
    int? trackPositionMs,
    required double percentage,
  }) = _AudiobookProgress;

  factory AudiobookProgress.fromJson(Map<String, dynamic> json) =>
      _$AudiobookProgressFromJson(json);
}

/// From `model.dto.progress.EpubProgress`, read via
/// `AppBookProgressResponse.epubProgress` and saved via the same
/// (`@Deprecated` but still functional) `epubProgress` field on
/// `UpdateProgressRequest` — mirrors how [AudiobookProgress] already uses
/// its own deprecated sibling field rather than the newer unified
/// `BookFileProgress`, for consistency with the existing pattern here.
/// [cfi] (a standard EPUB Canonical Fragment Identifier) is what actually
/// resumes reading at the right spot; [percentage] is 0.0-1.0.
@freezed
abstract class EpubProgress with _$EpubProgress {
  const factory EpubProgress({
    String? cfi,
    String? href,
    required double percentage,
  }) = _EpubProgress;

  factory EpubProgress.fromJson(Map<String, dynamic> json) =>
      _$EpubProgressFromJson(json);
}

/// From `AppSeriesSummary` (`GET /api/v1/app/series`).
@freezed
abstract class Series with _$Series {
  const factory Series({
    required String seriesName,
    required int bookCount,
    @Default([]) List<String> authors,
  }) = _Series;

  factory Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);
}

/// From `BookMark` (Java class name, capital M — same JSON field names
/// regardless) at `/api/v1/bookmarks`. Note `notes`, not `note`. One entity
/// backs bookmarks for every format: [cfi] for EPUB, [positionMs]/
/// [trackIndex] for audiobooks, `pageNumber` for PDF (not modeled here,
/// since this app doesn't read PDFs yet) — confirmed against the real
/// `BookMarkEntity`/`CreateBookMarkRequest` source, which comment each
/// field with exactly which format it's "for".
@freezed
abstract class Bookmark with _$Bookmark {
  const factory Bookmark({
    required int id,
    required int bookId,
    String? cfi,
    int? positionMs,
    int? trackIndex,
    String? title,
    String? notes,
    DateTime? createdAt,
  }) = _Bookmark;

  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);
}

/// From `AppAuthorSummary` (`GET /api/v1/app/authors`) and `AppAuthorDetail`
/// (`GET /api/v1/app/authors/{id}`) — [description] is only present on the
/// detail response, null on the list. Neither carries the author's actual
/// books; that needs a separate `/app/books?authors=<name>` filter query
/// (`ApiClient.getBooksByAuthor`), same author-name filter the library
/// screen's author filter uses.
@freezed
abstract class Author with _$Author {
  const factory Author({
    required int id,
    required String name,
    @Default(0) int bookCount,
    String? description,
  }) = _Author;

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);
}

/// From `AppShelfSummary` (`GET /api/v1/app/shelves`) — a regular,
/// user-curated shelf. Display-only in this app: unlike magic shelves,
/// there's no `/app/shelves/{id}/books` endpoint to drill into one, only
/// the summary (name + count).
@freezed
abstract class Shelf with _$Shelf {
  const factory Shelf({
    required int id,
    required String name,
    @Default(0) int bookCount,
  }) = _Shelf;

  factory Shelf.fromJson(Map<String, dynamic> json) => _$ShelfFromJson(json);
}

/// From `AppMagicShelfSummary` (`GET /api/v1/app/shelves/magic`) — a
/// dynamic/query-based shelf. Unlike [Shelf], its books are browsable via
/// `GET /api/v1/app/shelves/magic/{id}/books` (`ApiClient.getMagicShelfBooks`).
@freezed
abstract class MagicShelf with _$MagicShelf {
  const factory MagicShelf({required int id, required String name}) =
      _MagicShelf;

  factory MagicShelf.fromJson(Map<String, dynamic> json) =>
      _$MagicShelfFromJson(json);
}

/// A single facet value with a book count, e.g. one entry in
/// [FilterOptions.authors] — from `AppFilterOptions.CountedOption`
/// (`GET /api/v1/app/filter-options`).
@freezed
abstract class CountedOption with _$CountedOption {
  const factory CountedOption({required String name, @Default(0) int count}) =
      _CountedOption;

  factory CountedOption.fromJson(Map<String, dynamic> json) =>
      _$CountedOptionFromJson(json);
}

/// Only the facets this app's library filter UI actually uses — the real
/// `AppFilterOptions` response has ~30 fields (categories, comic-specific
/// facets, half a dozen rating-source breakdowns, etc.) built for a general
/// ebook/comic manager, most of which don't apply to audiobooks. Unknown
/// JSON fields are simply ignored by the generated `fromJson`.
@freezed
abstract class FilterOptions with _$FilterOptions {
  const factory FilterOptions({@Default([]) List<CountedOption> authors}) =
      _FilterOptions;

  factory FilterOptions.fromJson(Map<String, dynamic> json) =>
      _$FilterOptionsFromJson(json);
}
