// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => _AuthTokens(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  expires: (json['expires'] as num?)?.toInt(),
);

Map<String, dynamic> _$AuthTokensToJson(_AuthTokens instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expires': instance.expires,
    };

_Library _$LibraryFromJson(Map<String, dynamic> json) => _Library(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  icon: json['icon'] as String?,
  bookCount: (json['bookCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$LibraryToJson(_Library instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': instance.icon,
  'bookCount': instance.bookCount,
};

_Book _$BookFromJson(Map<String, dynamic> json) => _Book(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  coverUpdatedOn: json['coverUpdatedOn'] == null
      ? null
      : DateTime.parse(json['coverUpdatedOn'] as String),
  audiobookCoverUpdatedOn: json['audiobookCoverUpdatedOn'] == null
      ? null
      : DateTime.parse(json['audiobookCoverUpdatedOn'] as String),
  primaryFileId: (json['primaryFileId'] as num?)?.toInt(),
  authors:
      (json['authors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  seriesName: json['seriesName'] as String?,
  seriesNumber: (json['seriesNumber'] as num?)?.toDouble(),
  libraryId: (json['libraryId'] as num?)?.toInt(),
  narrator: json['narrator'] as String?,
  description: json['description'] as String?,
  primaryFileType: json['primaryFileType'] as String?,
  readProgress: (json['readProgress'] as num?)?.toDouble(),
  readStatus: json['readStatus'] as String?,
  lastReadTime: json['lastReadTime'] == null
      ? null
      : DateTime.parse(json['lastReadTime'] as String),
  files:
      (json['files'] as List<dynamic>?)
          ?.map((e) => BookFile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$BookToJson(_Book instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'thumbnailUrl': instance.thumbnailUrl,
  'coverUpdatedOn': instance.coverUpdatedOn?.toIso8601String(),
  'audiobookCoverUpdatedOn': instance.audiobookCoverUpdatedOn
      ?.toIso8601String(),
  'primaryFileId': instance.primaryFileId,
  'authors': instance.authors,
  'seriesName': instance.seriesName,
  'seriesNumber': instance.seriesNumber,
  'libraryId': instance.libraryId,
  'narrator': instance.narrator,
  'description': instance.description,
  'primaryFileType': instance.primaryFileType,
  'readProgress': instance.readProgress,
  'readStatus': instance.readStatus,
  'lastReadTime': instance.lastReadTime?.toIso8601String(),
  'files': instance.files,
};

_BookFile _$BookFileFromJson(Map<String, dynamic> json) => _BookFile(
  id: (json['id'] as num).toInt(),
  bookType: json['bookType'] as String?,
  isPrimary: json['primary'] as bool? ?? false,
  folderBased: json['folderBased'] as bool? ?? false,
);

Map<String, dynamic> _$BookFileToJson(_BookFile instance) => <String, dynamic>{
  'id': instance.id,
  'bookType': instance.bookType,
  'primary': instance.isPrimary,
  'folderBased': instance.folderBased,
};

_AudiobookInfo _$AudiobookInfoFromJson(Map<String, dynamic> json) =>
    _AudiobookInfo(
      bookId: (json['bookId'] as num).toInt(),
      bookFileId: (json['bookFileId'] as num?)?.toInt(),
      narrator: json['narrator'] as String?,
      durationMs: (json['durationMs'] as num).toInt(),
      folderBased: json['folderBased'] as bool? ?? false,
      chapters:
          (json['chapters'] as List<dynamic>?)
              ?.map((e) => AudiobookChapter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tracks:
          (json['tracks'] as List<dynamic>?)
              ?.map((e) => AudiobookTrack.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AudiobookInfoToJson(_AudiobookInfo instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'bookFileId': instance.bookFileId,
      'narrator': instance.narrator,
      'durationMs': instance.durationMs,
      'folderBased': instance.folderBased,
      'chapters': instance.chapters,
      'tracks': instance.tracks,
    };

_AudiobookChapter _$AudiobookChapterFromJson(Map<String, dynamic> json) =>
    _AudiobookChapter(
      index: (json['index'] as num).toInt(),
      title: json['title'] as String,
      startTimeMs: (json['startTimeMs'] as num).toInt(),
      endTimeMs: (json['endTimeMs'] as num).toInt(),
      durationMs: (json['durationMs'] as num).toInt(),
    );

Map<String, dynamic> _$AudiobookChapterToJson(_AudiobookChapter instance) =>
    <String, dynamic>{
      'index': instance.index,
      'title': instance.title,
      'startTimeMs': instance.startTimeMs,
      'endTimeMs': instance.endTimeMs,
      'durationMs': instance.durationMs,
    };

_AudiobookTrack _$AudiobookTrackFromJson(Map<String, dynamic> json) =>
    _AudiobookTrack(
      index: (json['index'] as num).toInt(),
      fileName: json['fileName'] as String,
      title: json['title'] as String,
      durationMs: (json['durationMs'] as num).toInt(),
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt(),
      cumulativeStartMs: (json['cumulativeStartMs'] as num).toInt(),
    );

Map<String, dynamic> _$AudiobookTrackToJson(_AudiobookTrack instance) =>
    <String, dynamic>{
      'index': instance.index,
      'fileName': instance.fileName,
      'title': instance.title,
      'durationMs': instance.durationMs,
      'fileSizeBytes': instance.fileSizeBytes,
      'cumulativeStartMs': instance.cumulativeStartMs,
    };

_AudiobookProgress _$AudiobookProgressFromJson(Map<String, dynamic> json) =>
    _AudiobookProgress(
      positionMs: (json['positionMs'] as num).toInt(),
      trackIndex: (json['trackIndex'] as num?)?.toInt(),
      trackPositionMs: (json['trackPositionMs'] as num?)?.toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$AudiobookProgressToJson(_AudiobookProgress instance) =>
    <String, dynamic>{
      'positionMs': instance.positionMs,
      'trackIndex': instance.trackIndex,
      'trackPositionMs': instance.trackPositionMs,
      'percentage': instance.percentage,
    };

_EpubProgress _$EpubProgressFromJson(Map<String, dynamic> json) =>
    _EpubProgress(
      cfi: json['cfi'] as String?,
      href: json['href'] as String?,
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$EpubProgressToJson(_EpubProgress instance) =>
    <String, dynamic>{
      'cfi': instance.cfi,
      'href': instance.href,
      'percentage': instance.percentage,
    };

_Series _$SeriesFromJson(Map<String, dynamic> json) => _Series(
  seriesName: json['seriesName'] as String,
  bookCount: (json['bookCount'] as num).toInt(),
  authors:
      (json['authors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  seriesTotal: (json['seriesTotal'] as num?)?.toInt(),
  booksRead: (json['booksRead'] as num?)?.toInt() ?? 0,
  latestAddedOn: json['latestAddedOn'] == null
      ? null
      : DateTime.parse(json['latestAddedOn'] as String),
  coverBooks:
      (json['coverBooks'] as List<dynamic>?)
          ?.map((e) => SeriesCoverBook.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SeriesToJson(_Series instance) => <String, dynamic>{
  'seriesName': instance.seriesName,
  'bookCount': instance.bookCount,
  'authors': instance.authors,
  'seriesTotal': instance.seriesTotal,
  'booksRead': instance.booksRead,
  'latestAddedOn': instance.latestAddedOn?.toIso8601String(),
  'coverBooks': instance.coverBooks,
};

_SeriesCoverBook _$SeriesCoverBookFromJson(Map<String, dynamic> json) =>
    _SeriesCoverBook(
      bookId: (json['bookId'] as num).toInt(),
      coverUpdatedOn: json['coverUpdatedOn'] == null
          ? null
          : DateTime.parse(json['coverUpdatedOn'] as String),
      seriesNumber: (json['seriesNumber'] as num?)?.toDouble(),
      primaryFileType: json['primaryFileType'] as String?,
    );

Map<String, dynamic> _$SeriesCoverBookToJson(_SeriesCoverBook instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'coverUpdatedOn': instance.coverUpdatedOn?.toIso8601String(),
      'seriesNumber': instance.seriesNumber,
      'primaryFileType': instance.primaryFileType,
    };

_Bookmark _$BookmarkFromJson(Map<String, dynamic> json) => _Bookmark(
  id: (json['id'] as num).toInt(),
  bookId: (json['bookId'] as num).toInt(),
  cfi: json['cfi'] as String?,
  positionMs: (json['positionMs'] as num?)?.toInt(),
  trackIndex: (json['trackIndex'] as num?)?.toInt(),
  title: json['title'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BookmarkToJson(_Bookmark instance) => <String, dynamic>{
  'id': instance.id,
  'bookId': instance.bookId,
  'cfi': instance.cfi,
  'positionMs': instance.positionMs,
  'trackIndex': instance.trackIndex,
  'title': instance.title,
  'notes': instance.notes,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_Author _$AuthorFromJson(Map<String, dynamic> json) => _Author(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  bookCount: (json['bookCount'] as num?)?.toInt() ?? 0,
  description: json['description'] as String?,
  hasPhoto: json['hasPhoto'] as bool? ?? false,
);

Map<String, dynamic> _$AuthorToJson(_Author instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'bookCount': instance.bookCount,
  'description': instance.description,
  'hasPhoto': instance.hasPhoto,
};

_Shelf _$ShelfFromJson(Map<String, dynamic> json) => _Shelf(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  bookCount: (json['bookCount'] as num?)?.toInt() ?? 0,
  icon: json['icon'] as String?,
  publicShelf: json['publicShelf'] as bool? ?? false,
);

Map<String, dynamic> _$ShelfToJson(_Shelf instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'bookCount': instance.bookCount,
  'icon': instance.icon,
  'publicShelf': instance.publicShelf,
};

_MagicShelf _$MagicShelfFromJson(Map<String, dynamic> json) => _MagicShelf(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  icon: json['icon'] as String?,
  iconType: json['iconType'] as String?,
  publicShelf: json['publicShelf'] as bool? ?? false,
);

Map<String, dynamic> _$MagicShelfToJson(_MagicShelf instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'iconType': instance.iconType,
      'publicShelf': instance.publicShelf,
    };

_CountedOption _$CountedOptionFromJson(Map<String, dynamic> json) =>
    _CountedOption(
      name: json['name'] as String,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CountedOptionToJson(_CountedOption instance) =>
    <String, dynamic>{'name': instance.name, 'count': instance.count};

_FilterOptions _$FilterOptionsFromJson(Map<String, dynamic> json) =>
    _FilterOptions(
      authors:
          (json['authors'] as List<dynamic>?)
              ?.map((e) => CountedOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fileTypes:
          (json['fileTypes'] as List<dynamic>?)
              ?.map((e) => CountedOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      readStatuses:
          (json['readStatuses'] as List<dynamic>?)
              ?.map((e) => CountedOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      series:
          (json['series'] as List<dynamic>?)
              ?.map((e) => CountedOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      narrators:
          (json['narrators'] as List<dynamic>?)
              ?.map((e) => CountedOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$FilterOptionsToJson(_FilterOptions instance) =>
    <String, dynamic>{
      'authors': instance.authors,
      'fileTypes': instance.fileTypes,
      'readStatuses': instance.readStatuses,
      'series': instance.series,
      'narrators': instance.narrators,
    };
