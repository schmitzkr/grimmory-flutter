import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/api/models.dart';
import 'download_models.dart';

/// Plain filesystem I/O for offline downloads — no Riverpod dependency, so
/// [GrimmoryAudioHandler] (constructed outside the widget tree, before
/// `runApp()`) can check for a local copy of a book without needing access
/// to provider state. [DownloadManager] uses this same instance for the
/// UI-facing download/cancel/delete flow (see `main()`).
///
/// Layout per book, under `<app documents>/downloads/<bookId>/`:
/// - `record.json` — [DownloadRecord] (title/authors/status/size), written
///   only once a download fully completes, and atomically (temp + rename)
///   so it can never be half-written. Its presence is the source of truth
///   for "is this book downloaded" — scanned at startup to rebuild
///   [DownloadManager]'s state; a directory without one is a download that
///   never finished and is removed by [sweepOrphans] at the next start.
/// - `info.json` — the cached `AudiobookInfo` response, so offline playback
///   needs zero network calls to load a book.
/// - `track_<index><ext>` (folder-based) or `book` (single-stream) — the
///   actual audio file(s). [ext] is taken from `AudiobookTrack.fileName`
///   where available; a file with no extension is stored as a bare
///   `track_<index>`. ExoPlayer/just_audio sniff the container format from
///   the file's contents for local playback, not the extension.
class DownloadStorage {
  /// [documentsDirectory] exists for tests, which have no path_provider
  /// plugin; the app uses the platform documents directory.
  DownloadStorage({Future<Directory> Function()? documentsDirectory})
    : _documentsDirectory =
          documentsDirectory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _documentsDirectory;

  Future<Directory> _root() async =>
      Directory('${(await _documentsDirectory()).path}/downloads');

  Future<Directory> bookDir(int bookId) async {
    final dir = Directory('${(await _root()).path}/$bookId');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<bool> isDownloaded(int bookId) async {
    final dir = await bookDir(bookId);
    return File('${dir.path}/record.json').exists();
  }

  Future<DownloadRecord?> readRecord(int bookId) async {
    final dir = await bookDir(bookId);
    final file = File('${dir.path}/record.json');
    if (!await file.exists()) return null;
    return DownloadRecord.fromJson(
      jsonDecode(await file.readAsString()) as Map<String, dynamic>,
    );
  }

  Future<void> writeRecord(DownloadRecord record) async {
    final dir = await bookDir(record.bookId);
    final temp = File('${dir.path}/record.json.tmp');
    await temp.writeAsString(jsonEncode(record.toJson()), flush: true);
    await temp.rename('${dir.path}/record.json');
  }

  Future<AudiobookInfo?> readCachedInfo(int bookId) async {
    final dir = await bookDir(bookId);
    final file = File('${dir.path}/info.json');
    if (!await file.exists()) return null;
    return AudiobookInfo.fromJson(
      jsonDecode(await file.readAsString()) as Map<String, dynamic>,
    );
  }

  Future<void> writeCachedInfo(int bookId, AudiobookInfo info) async {
    final dir = await bookDir(bookId);
    await File(
      '${dir.path}/info.json',
    ).writeAsString(jsonEncode(info.toJson()));
  }

  /// All completed downloads' [DownloadRecord]s, found by scanning the
  /// downloads directory — the source [DownloadManager] rebuilds its state
  /// from at startup.
  Future<List<DownloadRecord>> scanCompletedDownloads() async {
    final root = await _root();
    if (!await root.exists()) return [];

    final records = <DownloadRecord>[];
    await for (final entry in root.list()) {
      if (entry is! Directory) continue;
      final recordFile = File('${entry.path}/record.json');
      if (!await recordFile.exists()) continue;
      try {
        records.add(
          DownloadRecord.fromJson(
            jsonDecode(await recordFile.readAsString()) as Map<String, dynamic>,
          ),
        );
      } catch (_) {
        // A corrupt/partial record.json shouldn't take down the whole scan.
      }
    }
    return records;
  }

  /// Removes every book directory that has no `record.json` — a download
  /// the app was killed in the middle of. Partial files are only reused by
  /// a retry within the same session; across restarts they'd otherwise sit
  /// invisible and uncounted forever. Returns the number of directories
  /// removed.
  Future<int> sweepOrphans() async {
    final root = await _root();
    if (!await root.exists()) return 0;
    var removed = 0;
    await for (final entry in root.list()) {
      if (entry is! Directory) continue;
      if (await File('${entry.path}/record.json').exists()) continue;
      try {
        await entry.delete(recursive: true);
        removed++;
      } catch (_) {
        // Best-effort; a directory that won't delete is left for next time.
      }
    }
    return removed;
  }

  String trackFilePath(Directory dir, int trackIndex, String? fileName) {
    final ext = fileName != null && fileName.contains('.')
        ? fileName.substring(fileName.lastIndexOf('.'))
        : '';
    return '${dir.path}/track_$trackIndex$ext';
  }

  String singleFilePath(Directory dir) => '${dir.path}/book';

  /// The local audio file for a track index, or null if not present —
  /// exactly `track_<index>` or `track_<index>.<ext>` (not a bare prefix
  /// check, which would wrongly match track 1 against track 10, 11, etc.).
  Future<String?> localTrackPath(int bookId, int trackIndex) async {
    final dir = await bookDir(bookId);
    if (!await dir.exists()) return null;
    final pattern = RegExp('^track_$trackIndex(\\..+)?\$');
    await for (final entry in dir.list()) {
      if (entry is File && pattern.hasMatch(entry.uri.pathSegments.last)) {
        return entry.path;
      }
    }
    return null;
  }

  Future<String?> localSingleFilePath(int bookId) async {
    final dir = await bookDir(bookId);
    final file = File(singleFilePath(dir));
    return await file.exists() ? file.path : null;
  }

  Future<void> delete(int bookId) async {
    final dir = await bookDir(bookId);
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  /// The last known playback position for a downloaded book, cached locally
  /// so resuming works offline even when the server's own progress record
  /// can't be fetched. Overwritten on every successful [writeLocalProgress]
  /// call, mirroring the server's "only the latest position matters"
  /// semantics — there's no history kept, just the most recent snapshot.
  Future<void> writeLocalProgress(
    int bookId,
    AudiobookProgress progress,
  ) async {
    final dir = await bookDir(bookId);
    await File(
      '${dir.path}/progress.json',
    ).writeAsString(jsonEncode(progress.toJson()));
  }

  Future<AudiobookProgress?> readLocalProgress(int bookId) async {
    final dir = await bookDir(bookId);
    final file = File('${dir.path}/progress.json');
    if (!await file.exists()) return null;
    return AudiobookProgress.fromJson(
      jsonDecode(await file.readAsString()) as Map<String, dynamic>,
    );
  }

  Future<int> directorySize(int bookId) async {
    final dir = await bookDir(bookId);
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entry in dir.list(recursive: true)) {
      if (entry is File) total += await entry.length();
    }
    return total;
  }
}
