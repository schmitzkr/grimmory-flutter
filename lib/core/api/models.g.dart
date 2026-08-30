// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => _AuthTokens(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$AuthTokensToJson(_AuthTokens instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };

_Library _$LibraryFromJson(Map<String, dynamic> json) => _Library(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String?,
);

Map<String, dynamic> _$LibraryToJson(_Library instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
};

_Book _$BookFromJson(Map<String, dynamic> json) => _Book(
  id: json['id'] as String,
  title: json['title'] as String,
  author: json['author'] as String?,
  seriesName: json['seriesName'] as String?,
  coverUrl: json['coverUrl'] as String?,
);

Map<String, dynamic> _$BookToJson(_Book instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'author': instance.author,
  'seriesName': instance.seriesName,
  'coverUrl': instance.coverUrl,
};

_Track _$TrackFromJson(Map<String, dynamic> json) => _Track(
  index: (json['index'] as num).toInt(),
  title: json['title'] as String,
  durationSeconds: (json['durationSeconds'] as num).toDouble(),
);

Map<String, dynamic> _$TrackToJson(_Track instance) => <String, dynamic>{
  'index': instance.index,
  'title': instance.title,
  'durationSeconds': instance.durationSeconds,
};

_Chapter _$ChapterFromJson(Map<String, dynamic> json) => _Chapter(
  title: json['title'] as String,
  startSeconds: (json['startSeconds'] as num).toDouble(),
  endSeconds: (json['endSeconds'] as num?)?.toDouble(),
  trackIndex: (json['trackIndex'] as num?)?.toInt(),
);

Map<String, dynamic> _$ChapterToJson(_Chapter instance) => <String, dynamic>{
  'title': instance.title,
  'startSeconds': instance.startSeconds,
  'endSeconds': instance.endSeconds,
  'trackIndex': instance.trackIndex,
};

_AudiobookInfo _$AudiobookInfoFromJson(Map<String, dynamic> json) =>
    _AudiobookInfo(
      bookId: json['bookId'] as String,
      narrator: json['narrator'] as String?,
      tracks:
          (json['tracks'] as List<dynamic>?)
              ?.map((e) => Track.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      chapters:
          (json['chapters'] as List<dynamic>?)
              ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalDurationSeconds: (json['totalDurationSeconds'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AudiobookInfoToJson(_AudiobookInfo instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'narrator': instance.narrator,
      'tracks': instance.tracks,
      'chapters': instance.chapters,
      'totalDurationSeconds': instance.totalDurationSeconds,
    };

_Series _$SeriesFromJson(Map<String, dynamic> json) => _Series(
  name: json['name'] as String,
  bookCount: (json['bookCount'] as num).toInt(),
);

Map<String, dynamic> _$SeriesToJson(_Series instance) => <String, dynamic>{
  'name': instance.name,
  'bookCount': instance.bookCount,
};

_Progress _$ProgressFromJson(Map<String, dynamic> json) => _Progress(
  bookId: json['bookId'] as String,
  positionSeconds: (json['positionSeconds'] as num).toDouble(),
  trackIndex: (json['trackIndex'] as num?)?.toInt(),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProgressToJson(_Progress instance) => <String, dynamic>{
  'bookId': instance.bookId,
  'positionSeconds': instance.positionSeconds,
  'trackIndex': instance.trackIndex,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_Bookmark _$BookmarkFromJson(Map<String, dynamic> json) => _Bookmark(
  id: json['id'] as String,
  bookId: json['bookId'] as String,
  positionSeconds: (json['positionSeconds'] as num).toDouble(),
  note: json['note'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BookmarkToJson(_Bookmark instance) => <String, dynamic>{
  'id': instance.id,
  'bookId': instance.bookId,
  'positionSeconds': instance.positionSeconds,
  'note': instance.note,
  'createdAt': instance.createdAt?.toIso8601String(),
};
