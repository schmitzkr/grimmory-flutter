import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../player/playback_provider.dart';
import 'download_models.dart';
import 'download_storage.dart';

/// Overridden in main() with the single instance the audio handler also
/// uses, so both sides agree on what's on disk.
final downloadStorageProvider = Provider<DownloadStorage>(
  (ref) => throw UnimplementedError('downloadStorageProvider not overridden'),
);

final downloadManagerProvider =
    AsyncNotifierProvider<DownloadManager, Map<int, DownloadRecord>>(
      DownloadManager.new,
    );

/// Keyed by [Book.id]. Completed downloads are rebuilt from disk at
/// startup (see [DownloadStorage.scanCompletedDownloads]); in-progress
/// state (queued/downloading/failed) lives only in memory for the current
/// session.
///
/// One download runs at a time; the rest wait in a FIFO queue as
/// [DownloadStatus.queued]. A failed download keeps the files it finished
/// and a retry in the same session skips any track already on disk at its
/// expected size, so a token expiring or a network drop three hours into a
/// book doesn't restart it from zero. Files go through [ApiClient]'s own
/// authenticated client, which also refreshes the token on a 401.
class DownloadManager extends AsyncNotifier<Map<int, DownloadRecord>> {
  final Map<int, CancelToken> _cancelTokens = {};
  final Queue<Book> _queue = Queue();
  int? _activeBookId;

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

  void _removeRecord(int bookId) {
    final current = Map<int, DownloadRecord>.from(state.value ?? const {});
    current.remove(bookId);
    state = AsyncData(current);
  }

  /// Queues [book]; a no-op if it's already downloaded, queued, or active.
  /// Returns once this book's own download has finished (or failed), not
  /// when it was merely queued.
  Future<void> download(Book book) async {
    if (isDownloaded(book.id) ||
        _activeBookId == book.id ||
        _queue.any((b) => b.id == book.id)) {
      return;
    }
    _setRecord(
      DownloadRecord(
        bookId: book.id,
        title: book.title,
        authors: book.authors,
        status: DownloadStatus.queued,
      ),
    );
    _queue.add(book);
    await _pump();
  }

  Future<void> _pump() async {
    while (_activeBookId == null && _queue.isNotEmpty) {
      final book = _queue.removeFirst();
      // Cancelled while still queued.
      if (recordFor(book.id)?.status != DownloadStatus.queued) continue;
      _activeBookId = book.id;
      try {
        await _run(book);
      } finally {
        _activeBookId = null;
      }
    }
  }

  Future<void> _run(Book book) async {
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

    try {
      final info = await apiClient.getAudiobookInfo(book.id);
      final dir = await _storage.bookDir(book.id);
      await _storage.writeCachedInfo(book.id, info);

      if (info.folderBased && info.tracks.isNotEmpty) {
        final trackCount = info.tracks.length;
        for (final (i, track) in info.tracks.indexed) {
          final path = _storage.trackFilePath(dir, track.index, track.fileName);
          if (await _alreadyComplete(path, track.fileSizeBytes)) {
            _updateProgress(book.id, (i + 1) / trackCount);
            continue;
          }
          await apiClient.downloadFile(
            apiClient.trackStreamUrl(book.id, track.index),
            path,
            cancelToken: cancelToken,
            onReceiveProgress: (received, total) {
              final trackFraction = total > 0 ? received / total : 0.0;
              _updateProgress(book.id, (i + trackFraction) / trackCount);
            },
          );
        }
      } else {
        await apiClient.downloadFile(
          apiClient.streamUrl(book.id),
          _storage.singleFilePath(dir),
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
      if (e is DioException && CancelToken.isCancel(e)) {
        await _storage.delete(book.id);
        _removeRecord(book.id);
      } else {
        // Finished tracks stay on disk for a retry; without a record.json
        // they're invisible to isDownloaded() and swept at the next start.
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

  /// A track is only trusted when its size is known and matches — a file
  /// cut off mid-write is the same name at the wrong length.
  Future<bool> _alreadyComplete(String path, int? expectedBytes) async {
    if (expectedBytes == null) return false;
    final file = File(path);
    return await file.exists() && await file.length() == expectedBytes;
  }

  void _updateProgress(int bookId, double progress) {
    final record = state.value?[bookId];
    if (record == null) return;
    _setRecord(record.copyWith(progress: progress.clamp(0.0, 1.0)));
  }

  /// Cancels an active download (its files are removed) or drops a queued
  /// one before it starts.
  Future<void> cancel(int bookId) async {
    final token = _cancelTokens[bookId];
    if (token != null) {
      token.cancel();
      return;
    }
    if (_queue.any((b) => b.id == bookId)) {
      _queue.removeWhere((b) => b.id == bookId);
      _removeRecord(bookId);
    }
  }

  /// Removes a completed download. If that book is the one loaded in the
  /// player, playback is stopped first — deleting the files out from under
  /// a running local source would otherwise break it mid-track.
  Future<void> delete(int bookId) async {
    final handler = ref.read(audioHandlerProvider);
    if (handler.currentBookId == bookId) await handler.stop();
    await _storage.delete(bookId);
    _removeRecord(bookId);
  }
}
