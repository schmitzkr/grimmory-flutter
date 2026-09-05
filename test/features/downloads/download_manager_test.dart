import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/api/api_client.dart';
import 'package:grimmory/core/api/models.dart';
import 'package:grimmory/core/providers.dart';
import 'package:grimmory/features/downloads/download_manager.dart';
import 'package:grimmory/features/downloads/download_models.dart';
import 'package:grimmory/features/downloads/download_storage.dart';
import 'package:grimmory/features/player/audio_handler.dart';
import 'package:grimmory/features/player/playback_provider.dart';

const _trackBytes = 10;

AudiobookInfo _info(int bookId, {int tracks = 2}) => AudiobookInfo(
  bookId: bookId,
  bookFileId: bookId * 10,
  durationMs: tracks * 1000,
  folderBased: true,
  tracks: [
    for (var i = 0; i < tracks; i++)
      AudiobookTrack(
        index: i,
        fileName: 'part$i.mp3',
        title: 'Part $i',
        durationMs: 1000,
        fileSizeBytes: _trackBytes,
        cumulativeStartMs: i * 1000,
      ),
  ],
);

/// Only the download path is real; everything else is noSuchMethod.
class _FakeApi implements ApiClient {
  final requested = <String>[];
  Completer<void>? gate;
  Object? failWith;

  @override
  Future<AudiobookInfo> getAudiobookInfo(int bookId) async => _info(bookId);

  @override
  String streamUrl(int bookId) => 'book/$bookId';

  @override
  String trackStreamUrl(int bookId, int trackIndex) =>
      'book/$bookId/$trackIndex';

  @override
  Future<void> downloadFile(
    String url,
    String destinationPath, {
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    requested.add(url);
    final pending = gate?.future;
    if (pending != null) await pending;
    if (cancelToken?.isCancelled ?? false) {
      throw DioException.requestCancelled(
        requestOptions: RequestOptions(path: url),
        reason: 'cancelled',
      );
    }
    final error = failWith;
    if (error != null) throw error;
    await File(destinationPath).writeAsBytes(List.filled(_trackBytes, 0));
    onReceiveProgress?.call(_trackBytes, _trackBytes);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHandler implements GrimmoryAudioHandler {
  int? playingBookId;
  int stops = 0;

  @override
  int? get currentBookId => playingBookId;

  @override
  Future<void> stop() async {
    stops++;
    playingBookId = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory temp;
  late _FakeApi api;
  late _FakeHandler handler;
  late DownloadStorage storage;
  late ProviderContainer container;

  const bookA = Book(id: 1, title: 'A');
  const bookB = Book(id: 2, title: 'B');

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('grimreader_dl_');
    api = _FakeApi();
    handler = _FakeHandler();
    storage = DownloadStorage(documentsDirectory: () async => temp);
    container = ProviderContainer.test(
      overrides: [
        apiClientProvider.overrideWithValue(api),
        downloadStorageProvider.overrideWithValue(storage),
        audioHandlerProvider.overrideWithValue(handler),
      ],
    );
    await container.read(downloadManagerProvider.future);
  });

  tearDown(() => temp.delete(recursive: true));

  DownloadManager notifier() =>
      container.read(downloadManagerProvider.notifier);
  DownloadStatus? statusOf(int id) =>
      container.read(downloadManagerProvider).value?[id]?.status;

  /// The manager does real file IO (info.json, directories) before its
  /// first request, so "the download has started" is a condition to wait
  /// for, not a fixed number of event-loop turns.
  Future<void> waitFor(bool Function() condition) async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!condition()) {
      if (DateTime.now().isAfter(deadline)) {
        fail('condition not met within 5s');
      }
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  test('runs one download at a time; the next waits as queued', () async {
    api.gate = Completer<void>();
    final first = notifier().download(bookA);
    final second = notifier().download(bookB);
    await waitFor(() => api.requested.isNotEmpty);

    expect(statusOf(1), DownloadStatus.downloading);
    expect(statusOf(2), DownloadStatus.queued);
    expect(api.requested, ['book/1/0']);

    api.gate!.complete();
    api.gate = null;
    await Future.wait([first, second]);

    expect(statusOf(1), DownloadStatus.complete);
    expect(statusOf(2), DownloadStatus.complete);
    expect(await storage.isDownloaded(1), isTrue);
    expect(await storage.isDownloaded(2), isTrue);
    expect(notifier().totalStorageBytes(), greaterThan(0));
  });

  test('a repeat request for a queued or active book is a no-op', () async {
    api.gate = Completer<void>();
    final first = notifier().download(bookA);
    await notifier().download(bookA);
    api.gate!.complete();
    api.gate = null;
    await first;

    expect(api.requested.where((u) => u == 'book/1/0').length, 1);
  });

  test('a retry skips tracks already on disk at their full size', () async {
    final dir = await storage.bookDir(1);
    await File(
      '${dir.path}/track_0.mp3',
    ).writeAsBytes(List.filled(_trackBytes, 0));
    await File('${dir.path}/track_1.mp3').writeAsBytes([0, 0, 0]);

    await notifier().download(bookA);

    expect(api.requested, ['book/1/1']);
    expect(statusOf(1), DownloadStatus.complete);
  });

  test('a failure keeps finished files and marks the book failed', () async {
    api.failWith = StateError('network gone');
    await notifier().download(bookA);

    expect(statusOf(1), DownloadStatus.failed);
    expect(await storage.isDownloaded(1), isFalse);
    // info.json was written before the first track failed; the directory
    // survives for a same-session retry.
    expect((await storage.bookDir(1)).existsSync(), isTrue);
  });

  test('cancelling a queued download drops it before it starts', () async {
    api.gate = Completer<void>();
    final first = notifier().download(bookA);
    final second = notifier().download(bookB);
    await waitFor(() => api.requested.isNotEmpty);
    await notifier().cancel(2);

    api.gate!.complete();
    api.gate = null;
    await Future.wait([first, second]);

    expect(statusOf(2), isNull);
    expect(api.requested.any((u) => u.startsWith('book/2')), isFalse);
  });

  test('cancelling the active download removes its files', () async {
    api.gate = Completer<void>();
    final first = notifier().download(bookA);
    await waitFor(() => api.requested.isNotEmpty);
    await notifier().cancel(1);
    api.gate!.complete();
    api.gate = null;
    await first;

    expect(statusOf(1), isNull);
    expect((await storage.bookDir(1)).listSync(), isEmpty);
  });

  test('deleting the book that is playing stops playback first', () async {
    await notifier().download(bookA);
    handler.playingBookId = 1;

    await notifier().delete(1);

    expect(handler.stops, 1);
    expect(statusOf(1), isNull);
    expect(await storage.isDownloaded(1), isFalse);
  });

  test('deleting another book leaves playback alone', () async {
    await notifier().download(bookA);
    handler.playingBookId = 2;

    await notifier().delete(1);

    expect(handler.stops, 0);
  });
}
