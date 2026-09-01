import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import 'download_models.dart';
import 'download_storage.dart';

final downloadStorageProvider = Provider<DownloadStorage>(
  (ref) => DownloadStorage(),
);

final downloadManagerProvider =
    AsyncNotifierProvider<DownloadManager, Map<int, DownloadRecord>>(
      DownloadManager.new,
    );

/// Keyed by [Book.id]. Completed downloads are rebuilt from disk at
/// startup (see [DownloadStorage.scanCompletedDownloads]); in-progress
/// state (queued/downloading/failed) lives only in memory for the current
/// session — an interrupted download is just abandoned rather than resumed,
/// which is the simplest correct behavior for a personal-scale app.
class DownloadManager extends AsyncNotifier<Map<int, DownloadRecord>> {
  final Map<int, CancelToken> _cancelTokens = {};

  DownloadStorage get _storage => ref.read(downloadStorageProvider);

  @override
  Future<Map<int, DownloadRecord>> build() async {
    final completed = await _storage.scanCompletedDownloads();
    return {for (final record in completed) record.bookId: record};
  }

  bool isDownloaded(int bookId) =>
      state.value?[bookId]?.status == DownloadStatus.complete;

  DownloadRecord? recordFor(int bookId) => state.value?[bookId];

  int totalStorageBytes() => (state.value ?? const {}).values
      .where((r) => r.status == DownloadStatus.complete)
      .fold(0, (sum, r) => sum + r.totalBytes);

  void _setRecord(DownloadRecord record) {
    final current = Map<int, DownloadRecord>.from(state.value ?? const {});
    current[record.bookId] = record;
    state = AsyncData(current);
  }

  Future<void> download(Book book) async {
    if (isDownloaded(book.id) || _cancelTokens.containsKey(book.id)) return;

    _setRecord(
      DownloadRecord(
        bookId: book.id,
        title: book.title,
        authors: book.authors,
        status: DownloadStatus.downloading,
      ),
    );

    final apiClient = ref.read(apiClientProvider);
    final cancelToken = CancelToken();
    _cancelTokens[book.id] = cancelToken;
    final dio = Dio();

    try {
      final info = await apiClient.getAudiobookInfo(book.id);
      final dir = await _storage.bookDir(book.id);
      await _storage.writeCachedInfo(book.id, info);

      if (info.folderBased && info.tracks.isNotEmpty) {
        final trackCount = info.tracks.length;
        for (final (i, track) in info.tracks.indexed) {
          final path = _storage.trackFilePath(dir, track.index, track.fileName);
          await dio.download(
            apiClient.trackStreamUrl(book.id, track.index),
            path,
            options: Options(headers: apiClient.authHeaders),
            cancelToken: cancelToken,
            onReceiveProgress: (received, total) {
              final trackFraction = total > 0 ? received / total : 0.0;
              _updateProgress(book.id, (i + trackFraction) / trackCount);
            },
          );
        }
      } else {
        final path = _storage.singleFilePath(dir);
        await dio.download(
          apiClient.streamUrl(book.id),
          path,
          options: Options(headers: apiClient.authHeaders),
          cancelToken: cancelToken,
          onReceiveProgress: (received, total) {
            if (total > 0) _updateProgress(book.id, received / total);
          },
        );
      }

      final totalBytes = await _storage.directorySize(book.id);
      final record = DownloadRecord(
        bookId: book.id,
        title: book.title,
        authors: book.authors,
        status: DownloadStatus.complete,
        progress: 1.0,
        totalBytes: totalBytes,
      );
      await _storage.writeRecord(record);
      _setRecord(record);
    } catch (e) {
      final wasCancelled = e is DioException && CancelToken.isCancel(e);
      await _storage.delete(book.id);
      if (wasCancelled) {
        final current = Map<int, DownloadRecord>.from(state.value ?? const {});
        current.remove(book.id);
        state = AsyncData(current);
      } else {
        _setRecord(
          DownloadRecord(
            bookId: book.id,
            title: book.title,
            authors: book.authors,
            status: DownloadStatus.failed,
            error: e.toString(),
          ),
        );
      }
    } finally {
      _cancelTokens.remove(book.id);
    }
  }

  void _updateProgress(int bookId, double progress) {
    final record = state.value?[bookId];
    if (record == null) return;
    _setRecord(record.copyWith(progress: progress.clamp(0.0, 1.0)));
  }

  Future<void> cancel(int bookId) async {
    _cancelTokens[bookId]?.cancel();
  }

  Future<void> delete(int bookId) async {
    await _storage.delete(bookId);
    final current = Map<int, DownloadRecord>.from(state.value ?? const {});
    current.remove(bookId);
    state = AsyncData(current);
  }
}
