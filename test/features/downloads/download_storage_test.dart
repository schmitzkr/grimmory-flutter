import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/api/models.dart';
import 'package:grimmory/features/downloads/download_models.dart';
import 'package:grimmory/features/downloads/download_storage.dart';

void main() {
  late Directory temp;
  late DownloadStorage storage;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('grimreader_storage_');
    storage = DownloadStorage(documentsDirectory: () async => temp);
  });

  tearDown(() => temp.delete(recursive: true));

  test('writeRecord is atomic: no temp file left, record readable', () async {
    const record = DownloadRecord(
      bookId: 5,
      title: 'Five',
      status: DownloadStatus.complete,
      totalBytes: 42,
    );
    await storage.writeRecord(record);

    final dir = await storage.bookDir(5);
    expect(File('${dir.path}/record.json.tmp').existsSync(), isFalse);
    expect(await storage.isDownloaded(5), isTrue);
    expect(await storage.readRecord(5), record);
  });

  test('sweepOrphans removes directories without a record only', () async {
    await storage.writeRecord(
      const DownloadRecord(
        bookId: 1,
        title: 'Kept',
        status: DownloadStatus.complete,
      ),
    );
    final orphan = await storage.bookDir(2);
    await File('${orphan.path}/track_0.mp3').writeAsBytes([1, 2, 3]);

    expect(await storage.sweepOrphans(), 1);
    expect(await storage.isDownloaded(1), isTrue);
    expect(orphan.existsSync(), isFalse);
  });

  test(
    'localTrackPath matches exact index, with or without extension',
    () async {
      final dir = await storage.bookDir(3);
      await File('${dir.path}/track_1.mp3').writeAsBytes([1]);
      await File('${dir.path}/track_10.mp3').writeAsBytes([1]);
      await File('${dir.path}/track_2').writeAsBytes([1]);

      expect(await storage.localTrackPath(3, 1), endsWith('/track_1.mp3'));
      expect(await storage.localTrackPath(3, 10), endsWith('/track_10.mp3'));
      expect(await storage.localTrackPath(3, 2), endsWith('/track_2'));
      expect(await storage.localTrackPath(3, 0), isNull);
    },
  );

  test('trackFilePath keeps the source extension, none when absent', () async {
    final dir = await storage.bookDir(4);
    expect(
      storage.trackFilePath(dir, 0, 'part 1.m4b'),
      '${dir.path}/track_0.m4b',
    );
    expect(storage.trackFilePath(dir, 1, 'noext'), '${dir.path}/track_1');
    expect(storage.trackFilePath(dir, 2, null), '${dir.path}/track_2');
  });

  test('local progress round-trips', () async {
    const progress = AudiobookProgress(positionMs: 1234, percentage: 5.5);
    await storage.writeLocalProgress(6, progress);
    expect(await storage.readLocalProgress(6), progress);
    expect(await storage.readLocalProgress(7), isNull);
  });
}
