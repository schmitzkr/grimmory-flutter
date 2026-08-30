import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

// NOTE: Grimmory's REST API (https://grimmory.org/api/) is explicitly marked
// unstable. Every field name below is a best-guess placeholder pending M0 —
// verification against a live instance or its OpenAPI spec
// (`/api/openapi.json`) — not a confirmed contract. Expect to adjust these
// once a real instance is available.

@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}

@freezed
abstract class Library with _$Library {
  const factory Library({
    required String id,
    required String name,
    String? type,
  }) = _Library;

  factory Library.fromJson(Map<String, dynamic> json) =>
      _$LibraryFromJson(json);
}

/// Base metadata shared by every item in a library — audiobook-specific
/// fields (tracks, chapters, narrator) live on [AudiobookInfo], fetched
/// separately per the API's own split between `/books/{id}` and
/// `/audiobooks/{id}/info`.
@freezed
abstract class Book with _$Book {
  const factory Book({
    required String id,
    required String title,
    String? author,
    String? seriesName,
    String? coverUrl,
  }) = _Book;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
}

@freezed
abstract class Track with _$Track {
  const factory Track({
    required int index,
    required String title,
    required double durationSeconds,
  }) = _Track;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);
}

/// A logical chapter marker, distinct from a physical [Track]/file — a
/// multi-file audiobook has one [Track] per file but may have chapter
/// markers that don't align to file boundaries. Confirm in M0 whether
/// Grimmory's `/audiobooks/{id}/info` actually distinguishes the two.
@freezed
abstract class Chapter with _$Chapter {
  const factory Chapter({
    required String title,
    required double startSeconds,
    double? endSeconds,
    int? trackIndex,
  }) = _Chapter;

  factory Chapter.fromJson(Map<String, dynamic> json) =>
      _$ChapterFromJson(json);
}

@freezed
abstract class AudiobookInfo with _$AudiobookInfo {
  const factory AudiobookInfo({
    required String bookId,
    String? narrator,
    @Default([]) List<Track> tracks,
    @Default([]) List<Chapter> chapters,
    double? totalDurationSeconds,
  }) = _AudiobookInfo;

  factory AudiobookInfo.fromJson(Map<String, dynamic> json) =>
      _$AudiobookInfoFromJson(json);
}

@freezed
abstract class Series with _$Series {
  const factory Series({required String name, required int bookCount}) =
      _Series;

  factory Series.fromJson(Map<String, dynamic> json) =>
      _$SeriesFromJson(json);
}

@freezed
abstract class Progress with _$Progress {
  const factory Progress({
    required String bookId,
    required double positionSeconds,
    int? trackIndex,
    DateTime? updatedAt,
  }) = _Progress;

  factory Progress.fromJson(Map<String, dynamic> json) =>
      _$ProgressFromJson(json);
}

@freezed
abstract class Bookmark with _$Bookmark {
  const factory Bookmark({
    required String id,
    required String bookId,
    required double positionSeconds,
    String? note,
    DateTime? createdAt,
  }) = _Bookmark;

  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);
}
