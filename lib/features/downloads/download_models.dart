import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_models.freezed.dart';
part 'download_models.g.dart';

enum DownloadStatus { queued, downloading, complete, failed }

/// Persisted metadata for one book's offline download — enough to render
/// the Downloads screen and library badges without any network call.
/// [progress] is 0.0-1.0 across all tracks combined; [totalBytes] is only
/// meaningful once [status] is [DownloadStatus.complete].
@freezed
abstract class DownloadRecord with _$DownloadRecord {
  const factory DownloadRecord({
    required int bookId,
    required String title,
    @Default([]) List<String> authors,
    required DownloadStatus status,
    @Default(0.0) double progress,
    @Default(0) int totalBytes,
    String? error,
  }) = _DownloadRecord;

  factory DownloadRecord.fromJson(Map<String, dynamic> json) =>
      _$DownloadRecordFromJson(json);
}
