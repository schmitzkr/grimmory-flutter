// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DownloadRecord _$DownloadRecordFromJson(Map<String, dynamic> json) =>
    _DownloadRecord(
      bookId: (json['bookId'] as num).toInt(),
      title: json['title'] as String,
      authors:
          (json['authors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      status: $enumDecode(_$DownloadStatusEnumMap, json['status']),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      totalBytes: (json['totalBytes'] as num?)?.toInt() ?? 0,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$DownloadRecordToJson(_DownloadRecord instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'title': instance.title,
      'authors': instance.authors,
      'status': _$DownloadStatusEnumMap[instance.status]!,
      'progress': instance.progress,
      'totalBytes': instance.totalBytes,
      'error': instance.error,
    };

const _$DownloadStatusEnumMap = {
  DownloadStatus.queued: 'queued',
  DownloadStatus.downloading: 'downloading',
  DownloadStatus.complete: 'complete',
  DownloadStatus.failed: 'failed',
};
