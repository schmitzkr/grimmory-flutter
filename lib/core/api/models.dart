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

/// From `AppLibrarySummary` (`GET /api/v1/app/libraries`).
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

/// From `AppSeriesSummary` (`GET /api/v1/app/series`).
@freezed
abstract class Series with _$Series {
  const factory Series({
    required String seriesName,
    required int bookCount,
    @Default([]) List<String> authors,
  }) = _Series;

  factory Series.fromJson(Map<String, dynamic> json) =>
      _$SeriesFromJson(json);
}

/// From `BookMark` (Java class name, capital M — same JSON field names
/// regardless) at `/api/v1/bookmarks`. Note `notes`, not `note`.
@freezed
abstract class Bookmark with _$Bookmark {
  const factory Bookmark({
    required int id,
    required int bookId,
    int? positionMs,
    int? trackIndex,
    String? title,
    String? notes,
    DateTime? createdAt,
  }) = _Bookmark;

  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);
}
