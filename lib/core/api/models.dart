import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

// Every model here is checked against Grimmory's Java source (github.com/
// grimmory-tools/grimmory, package org.booklore — Grimmory is a rebrand of
// BookLore), most recently v3.3.3 on 2026-09-04: entity IDs are numeric
// (`Long`); the `/api/v1/app/*` controller namespace is the mobile-facing
// surface (paginated summary DTOs, continue-reading/listening endpoints)
// and is used wherever it covers a need; JSON keys follow Jackson's view of
// the Lombok DTOs, so a `boolean isX` field arrives as `x`. See ApiClient's
// doc comment for the endpoint-by-endpoint notes.

/// From `AccessTokenDto`. [expires] is the access token's expiry as epoch
/// milliseconds — lets the client refresh just ahead of it instead of only
/// after a 401 round-trip.
@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
    int? expires,
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
/// `AppBookDetail` (single-book fetch). The detail adds [description],
/// [files] and the per-type progress objects; everything the summary lacks
/// is nullable or defaulted here, so either shape parses.
///
/// [coverUpdatedOn]/[audiobookCoverUpdatedOn] are what the cover endpoints
/// should be cache-busted on (see [BookCoverX.coverVersion]) — the URL
/// itself never changes when a cover is regenerated. [primaryFileId] is
/// the id of the file the library's format priority picks, available on
/// the summary too (unlike [files]).
@freezed
abstract class Book with _$Book {
  const factory Book({
    required int id,
    required String title,
    String? thumbnailUrl,
    DateTime? coverUpdatedOn,
    DateTime? audiobookCoverUpdatedOn,
    int? primaryFileId,
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
    // all return them) — confirmed against the real DTOs. [readProgress] is
    // on a 0-100 scale (Grimmory's `ReadingProgressService` thresholds are
    // READING > 0.1 and READ >= 99.5 on that scale, and its own web client
    // sends every type, audiobooks included, as 0-100). It's only ever
    // populated from the per-book legacy columns (`mapReadProgress` reads
    // koreader/kobo/epub/pdf/cbx percent, never the file-level audiobook
    // row), so it's null for audiobooks. Use [normalizedReadProgress] for
    // display. [readStatus] is one of Grimmory's `ReadStatus` enum values
    // (UNREAD, READING, RE_READING, READ, PARTIALLY_READ, PAUSED,
    // WONT_READ, ABANDONED, UNSET) — 'READ' is the only one this app
    // currently acts on (a finished-book badge).
    double? readProgress,
    String? readStatus,
    // When this user last read/listened to the book (any format) — the
    // ordering key of the Continue Reading/Listening carousels, exactly as
    // the web dashboard sorts its own.
    DateTime? lastReadTime,
    // `AppBookDetail.files` only (absent on `AppBookSummary`) — every
    // book-format file attached to this book, with the id the file-level
    // progress API (`UpdateProgressRequest.fileProgress.bookFileId`) is
    // keyed on.
    @Default([]) List<BookFile> files,
  }) = _Book;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
}

const _ebookFileTypes = {'EPUB', 'FB2', 'MOBI', 'AZW3'};

extension BookCoverX on Book {
  /// Cache-busting token for this book's cover URLs — the newer of the two
  /// cover timestamps, as epoch millis — or null when the server sent
  /// neither (then the URL is used bare and the image cache decides).
  String? get coverVersion {
    final stamps = [coverUpdatedOn, audiobookCoverUpdatedOn].nonNulls;
    if (stamps.isEmpty) return null;
    return stamps
        .reduce((a, b) => a.isAfter(b) ? a : b)
        .millisecondsSinceEpoch
        .toString();
  }
}

extension BookProgressX on Book {
  /// [readProgress] as a real 0.0-1.0 fraction — safe to feed straight into
  /// a `LinearProgressIndicator` or a percentage display for any book type.
  double? get normalizedReadProgress {
    final raw = readProgress;
    if (raw == null) return null;
    return raw / 100;
  }

  /// Whether the file Grimmory treats as this book's primary one is an
  /// ebook — what the primary-only `GET /books/{id}/download` would hand
  /// back. Only consulted as a last resort now: with the book detail in
  /// hand the readers fetch a specific file by id ([ebookFileId],
  /// [fileIdFor]) through `ApiClient.downloadBookFile`, so a dual-format
  /// book whose library format priority puts the audiobook first still
  /// opens.
  bool get primaryFileIsEbook => _ebookFileTypes.contains(primaryFileType);

  /// The `bookFileId` to save EPUB reading progress against: the primary
  /// file if it's an ebook, else the first ebook-format file. Null when the
  /// server response carried no `files` (a summary DTO) or the book has no
  /// ebook file at all. Mirrors the web reader's `altFile?.id ??
  /// book.primaryFile?.id` resolution.
  int? get ebookFileId {
    final ebooks = files.where((f) => _ebookFileTypes.contains(f.bookType));
    if (ebooks.isEmpty) return null;
    return ebooks.firstWhere((f) => f.isPrimary, orElse: () => ebooks.first).id;
  }

  /// The `bookFileId` to save page-based (comic/PDF) progress against —
  /// the file of that exact type, preferring the primary one. Same
  /// resolution as [ebookFileId], narrowed to the one `bookType` the
  /// `/cbx` and `/pdf` reader endpoints serve for that format.
  int? fileIdFor(PageFormat format) {
    final matches = files.where((f) => f.bookType == format.bookType);
    if (matches.isEmpty) return null;
    return matches
        .firstWhere((f) => f.isPrimary, orElse: () => matches.first)
        .id;
  }
}

/// From `AppBookFile` (`AppBookDetail.files`). [bookType] matches
/// `BookFileType` (AUDIOBOOK/EPUB/PDF/CBX/FB2/MOBI/AZW3); [isPrimary] is
/// whichever file the library's format priority picks — serialised as
/// `primary`, not `isPrimary`: the DTO is a Lombok `@Data` class, whose
/// `boolean isPrimary` field gets an `isPrimary()` getter that Jackson maps
/// to the property name `primary` (same for its `isBook` → `book`).
@freezed
abstract class BookFile with _$BookFile {
  const factory BookFile({
    required int id,
    String? bookType,
    @JsonKey(name: 'primary') @Default(false) bool isPrimary,
    @Default(false) bool folderBased,
  }) = _BookFile;

  factory BookFile.fromJson(Map<String, dynamic> json) =>
      _$BookFileFromJson(json);
}

/// From `GET /api/v1/audiobooks/{bookId}/info` — a separate endpoint from
/// the general book detail, not under `/app/*` (the mobile-app namespace
/// doesn't cover audiobook-specific playback structure).
@freezed
abstract class AudiobookInfo with _$AudiobookInfo {
  const factory AudiobookInfo({
    required int bookId,
    // The audiobook `BookFileEntity` id — what file-level progress saves
    // are keyed on (Grimmory's own player passes `audiobookInfo.bookFileId`
    // into every progress save). Nullable only so an `info.json` cached by
    // an older build of this app (which didn't parse it) still loads.
    int? bookFileId,
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
/// directions rather than modeling that asymmetry. [percentage] is 0-100,
/// the same scale Grimmory's web player sends and its read-status
/// thresholds are defined on.
///
/// Since Grimmory moved progress to a per-file table, the deprecated
/// `audiobookProgress` request field alone stores *nothing* for audiobooks
/// (`ReadingProgressService`'s legacy path has an empty `case AUDIOBOOK`
/// in every branch) — the position only persists via the `fileProgress`
/// block `ApiClient.updateAudiobookProgress` also sends.
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

/// From `AppBookProgressResponse.epubProgress` (read side). On the save side
/// `ApiClient.updateEpubProgress` sends this as the deprecated `epubProgress`
/// field *and* as the file-level `fileProgress` block that actually
/// persists — see the progress section of `ApiClient`. [cfi] (a standard
/// EPUB Canonical Fragment Identifier) is what resumes reading at the right
/// spot; [percentage] is 0-100.
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

/// The two page-based formats Grimmory tracks the same way — `PdfProgress`
/// and `CbxProgress` are both `{page, percentage}` — differing only in the
/// key they sit under in the progress response/request and the `bookType`
/// the reader endpoints take.
enum PageFormat {
  cbx('cbxProgress', 'CBX'),
  pdf('pdfProgress', 'PDF');

  const PageFormat(this.jsonKey, this.bookType);

  /// Field name on `AppBookProgressResponse` / `UpdateProgressRequest`.
  final String jsonKey;

  /// `BookFileType` value the `/cbx` and `/pdf` reader endpoints filter on.
  final String bookType;
}

/// From `AppBookProgressResponse.cbxProgress` / `.pdfProgress`. [page] is
/// **1-based** (the web reader stores `index + 1`); [percentage] is 0-100,
/// `(page / pageCount) * 100` rounded to one decimal, as the web reader
/// computes it. On the save side `ApiClient.updatePageProgress` sends this
/// as the deprecated per-type field *and* as the file-level `fileProgress`
/// block (whose `positionData` is the page number as a string — what the
/// server's own migration writes for these formats).
@freezed
abstract class PageProgress with _$PageProgress {
  const factory PageProgress({
    required int page,
    required double percentage,
    DateTime? updatedAt,
  }) = _PageProgress;

  factory PageProgress.fromJson(Map<String, dynamic> json) =>
      _$PageProgressFromJson(json);
}

/// From `AppSeriesSummary` (`GET /api/v1/app/series`). [bookCount] is how
/// many of the series' books this library holds; [seriesTotal] is the
/// series' full length per metadata (null when unknown); [booksRead] is
/// how many of the held books the user has finished. [coverBooks] is the
/// server's own pick of up to a few books whose covers represent the
/// series, in series order.
@freezed
abstract class Series with _$Series {
  const factory Series({
    required String seriesName,
    required int bookCount,
    @Default([]) List<String> authors,
    int? seriesTotal,
    @Default(0) int booksRead,
    DateTime? latestAddedOn,
    @Default([]) List<SeriesCoverBook> coverBooks,
  }) = _Series;

  factory Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);
}

/// From `SeriesCoverBook` on [Series.coverBooks] — just enough to render a
/// cover through the normal book cover endpoint, with the same cache-bust
/// token a full [Book] would carry.
@freezed
abstract class SeriesCoverBook with _$SeriesCoverBook {
  const factory SeriesCoverBook({
    required int bookId,
    DateTime? coverUpdatedOn,
    double? seriesNumber,
    String? primaryFileType,
  }) = _SeriesCoverBook;

  factory SeriesCoverBook.fromJson(Map<String, dynamic> json) =>
      _$SeriesCoverBookFromJson(json);
}

extension SeriesCoverBookX on SeriesCoverBook {
  String? get coverVersion => coverUpdatedOn?.millisecondsSinceEpoch.toString();
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
/// screen's author filter uses. [hasPhoto] says whether
/// `ApiClient.authorPhotoUrl` will return an image (the endpoint 404s
/// otherwise).
@freezed
abstract class Author with _$Author {
  const factory Author({
    required int id,
    required String name,
    @Default(0) int bookCount,
    String? description,
    @Default(false) bool hasPhoto,
  }) = _Author;

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);
}

/// From `AppShelfSummary` (`GET /api/v1/app/shelves`) — a regular,
/// user-curated shelf. Display-only in this app: unlike magic shelves,
/// there's no `/app/shelves/{id}/books` endpoint to drill into one, only
/// the summary (name + count).
///
/// [icon] is the web UI's icon name (a PrimeIcons class, e.g. `pi-heart`)
/// and isn't mapped to Material icons here; [publicShelf] means the shelf
/// is shared with every user on the server, not just its owner.
@freezed
abstract class Shelf with _$Shelf {
  const factory Shelf({
    required int id,
    required String name,
    @Default(0) int bookCount,
    String? icon,
    @Default(false) bool publicShelf,
  }) = _Shelf;

  factory Shelf.fromJson(Map<String, dynamic> json) => _$ShelfFromJson(json);
}

/// From `AppMagicShelfSummary` (`GET /api/v1/app/shelves/magic`) — a
/// dynamic/query-based shelf. Unlike [Shelf], its books are browsable via
/// `GET /api/v1/app/shelves/magic/{id}/books` (`ApiClient.getMagicShelfBooks`).
/// [icon]/[iconType] are the web UI's icon reference (not mapped here);
/// [publicShelf] as on [Shelf].
/// One row of the web dashboard, from `userSettings.dashboardConfig.scrollers`
/// on `GET /users/me` (`BookLoreUser.UserSettings.ScrollerConfig`). [type]
/// is kept as the wire string so an unknown value (a scroller type added
/// upstream later) parses and is skipped, rather than failing the whole
/// config — see [DashboardScrollerX.kind]. [title] is either a translation
/// key the web ships (`dashboard.scroller.continueReading`) or the user's
/// own text. [order] is the display position; [maxItems] the per-row cap
/// (the web's DEFAULT_MAX_ITEMS is 20 when null).
@freezed
abstract class DashboardScroller with _$DashboardScroller {
  const factory DashboardScroller({
    String? id,
    required String type,
    String? title,
    @Default(true) bool enabled,
    @Default(0) int order,
    int? maxItems,
    int? magicShelfId,
  }) = _DashboardScroller;

  factory DashboardScroller.fromJson(Map<String, dynamic> json) =>
      _$DashboardScrollerFromJson(json);
}

/// `userSettings.dashboardConfig` — absent until the user has customised
/// the web dashboard at least once, in which case the web's defaults apply
/// (see `dashboardDefaultScrollers`).
@freezed
abstract class DashboardConfig with _$DashboardConfig {
  const factory DashboardConfig({
    @Default([]) List<DashboardScroller> scrollers,
  }) = _DashboardConfig;

  factory DashboardConfig.fromJson(Map<String, dynamic> json) =>
      _$DashboardConfigFromJson(json);
}

/// The web dashboard's `ScrollerType` values.
enum ScrollerType {
  lastRead('lastRead'),
  lastListened('lastListened'),
  latestAdded('latestAdded'),
  random('random'),
  magicShelf('magicShelf');

  const ScrollerType(this.wire);

  /// The string stored in the user's settings.
  final String wire;

  static ScrollerType? fromWire(String value) {
    for (final t in values) {
      if (t.wire == value) return t;
    }
    return null;
  }
}

extension DashboardScrollerX on DashboardScroller {
  /// Null for a type this build doesn't know how to render.
  ScrollerType? get kind => ScrollerType.fromWire(type);
}

@freezed
abstract class MagicShelf with _$MagicShelf {
  const factory MagicShelf({
    required int id,
    required String name,
    String? icon,
    String? iconType,
    @Default(false) bool publicShelf,
  }) = _MagicShelf;

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
/// JSON fields are simply ignored by the generated `fromJson`. [fileTypes]
/// names are `BookFileType` values (AUDIOBOOK, EPUB, …) with how many books
/// in the library have that primary type — what drives the type filter's
/// counts and hides groups the library doesn't contain.
@freezed
abstract class FilterOptions with _$FilterOptions {
  const factory FilterOptions({
    @Default([]) List<CountedOption> authors,
    @Default([]) List<CountedOption> fileTypes,
    @Default([]) List<CountedOption> readStatuses,
    @Default([]) List<CountedOption> series,
    @Default([]) List<CountedOption> narrators,
  }) = _FilterOptions;

  factory FilterOptions.fromJson(Map<String, dynamic> json) =>
      _$FilterOptionsFromJson(json);
}
