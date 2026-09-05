import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../../core/api/api_client.dart';
import '../../core/api/models.dart';
import '../downloads/download_storage.dart';
import 'browse_tree.dart';
import 'track_timeline.dart';

/// Wraps a single [AudioPlayer] with Grimmory's streaming endpoints and
/// exposes it as an [AudioHandler] — this is what turns playback into a
/// proper Android foreground service with a media-style notification, and
/// the Android Auto browse surface via [getChildren] (see [BrowseTree]).
///
/// One book plays at a time; there's no general music-library queue here
/// (no shuffle, no reordering, no adding arbitrary items) — audiobooks are
/// linear by nature.
///
/// Grimmory audiobooks come in two shapes, per [AudiobookInfo.folderBased]
/// (confirmed against Grimmory's real source, 2026-08-31 — see
/// ApiClient's doc comment): a **single continuous stream** with chapter
/// markers (`chapters`, timestamps relative to the one stream), or a
/// **folder-based** book split into multiple physical files (`tracks`,
/// each independently streamable), where `chapters` (if present) still use
/// a book-wide cumulative timeline spanning all tracks. Track navigation
/// (skip next/previous, tap-to-play a track) only applies to folder-based
/// books; chapter navigation (seek within the current stream) applies to
/// both, using [AudiobookTrack.cumulativeStartMs] to convert between a
/// track-relative player position and the book-wide position Grimmory's
/// progress API expects.
///
/// Loads are serialised and stamped with a generation: a second Play
/// (Android Auto tap, double-tap) used to interleave two loads, leaving the
/// handler's fields describing one book while the player held another, so
/// the next progress save wrote book A's position under book B's id.
class GrimmoryAudioHandler extends BaseAudioHandler with SeekHandler {
  GrimmoryAudioHandler(this._apiClient, {DownloadStorage? downloadStorage})
    : _downloadStorage = downloadStorage ?? DownloadStorage() {
    _init();
  }

  final ApiClient _apiClient;
  final AudioPlayer _player = AudioPlayer();
  final DownloadStorage _downloadStorage;
  late final BrowseTree _browseTree = BrowseTree(_apiClient);

  int? _currentBookId;
  int? get currentBookId => _currentBookId;

  Book? _currentBook;
  AudiobookInfo? _currentInfo;
  bool _folderBased = false;
  List<AudiobookTrack> _tracks = [];
  int _totalDurationMs = 0;
  int? _bookFileId;
  // Whether the currently loaded book is playing from local files rather
  // than streaming — set once per loadBook() call from DownloadStorage, not
  // re-checked per request, so a download started mid-playback doesn't
  // switch sources out from under an active stream.
  bool _isDownloaded = false;

  // Bumped by every load; anything async that outlives a load compares its
  // captured value against this before touching state or emitting.
  int _loadGeneration = 0;
  Future<void> _loadChain = Future.value();
  int? _pendingBookId;
  bool _loadInFlight = false;

  /// Chapter markers for the currently loaded book — not part of the base
  /// [AudioHandler] interface (audio_service has no chapter concept), so
  /// exposed as a plain extra subject the player screen watches directly.
  final BehaviorSubject<List<AudiobookChapter>> chaptersSubject =
      BehaviorSubject.seeded([]);

  /// Fires after each progress save the server actually accepted.
  /// [sessionEnded] marks the saves made on pause/stop/completion/switching
  /// books, as opposed to the periodic tick while playing — the signal
  /// `audiobookProgressSyncProvider` uses to refresh the screens showing
  /// this book's progress without refetching every five seconds.
  final PublishSubject<({int bookId, bool sessionEnded})> progressSaved =
      PublishSubject();

  Timer? _progressTimer;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  // Guards against retry-looping forever if a refreshed token still fails
  // (e.g. the server itself is down, not just the token) — one retry per
  // load, not per error.
  bool _retriedAfterRefresh = false;

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _subscriptions.add(
      _player.playbackEventStream.listen(
        _broadcastState,
        onError: _handlePlaybackError,
      ),
    );
    _subscriptions.add(
      _player.currentIndexStream.listen(_updateMediaItemForIndex),
    );
    // The periodic save only runs while audio is actually advancing — a
    // paused book has nothing new to report, and pause/stop already make
    // their own final save.
    _subscriptions.add(
      _player.playingStream.listen((playing) {
        if (playing && _currentBookId != null) {
          _startProgressTimer();
        } else {
          _stopProgressTimer();
        }
      }),
    );
    _subscriptions.add(
      _player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          _stopProgressTimer();
          _saveProgressNow(sessionEnded: true);
        }
      }),
    );
  }

  // ── Browse tree (Android Auto) ────────────────────────────────────────

  @override
  Future<List<MediaItem>> getChildren(
    String parentMediaId, [
    Map<String, dynamic>? options,
  ]) => _browseTree.children(parentMediaId);

  // ── Playback ─────────────────────────────────────────────────────────

  @override
  Future<void> playFromMediaId(
    String mediaId, [
    Map<String, dynamic>? extras,
  ]) async {
    await loadBook(int.parse(mediaId));
    await play();
  }

  /// Loads [bookId]'s audio source and resumes from the server's saved
  /// progress (if any). Called directly by the book detail screen's Play
  /// button (via [playFromMediaId]), not just from Android Auto's browse
  /// tree — this is the one entry point for starting playback on a book.
  ///
  /// Loads run one at a time; a request for the book that's already being
  /// loaded just joins that load instead of starting a second one.
  ///
  /// If [bookId] has been downloaded (`DownloadStorage.isDownloaded`), this
  /// needs zero network calls: book/track metadata comes from the cached
  /// `record.json`/`info.json` instead of `getBook`/`getAudiobookInfo`, and
  /// [_buildAudioSources] plays the local files instead of streaming.
  Future<void> loadBook(int bookId) {
    if (_pendingBookId == bookId) return _loadChain;
    _pendingBookId = bookId;
    final run = _loadChain
        .catchError((_) {})
        .then((_) => _loadBook(bookId))
        .whenComplete(() {
          if (_pendingBookId == bookId) _pendingBookId = null;
        });
    _loadChain = run;
    return run;
  }

  Future<void> _loadBook(int bookId) async {
    _stopProgressTimer();
    // Final save for whatever was playing, stamped with the old generation
    // so the sync provider sees it as that book's session ending.
    await _saveProgressNow(sessionEnded: true);

    final generation = ++_loadGeneration;
    _loadInFlight = true;
    try {
      var isDownloaded = await _downloadStorage.isDownloaded(bookId);
      final Book book;
      final AudiobookInfo info;
      DownloadRecordSnapshot? cached;
      if (isDownloaded) {
        cached = await _readDownloadSnapshot(bookId);
        // Shouldn't happen (isDownloaded() checks record.json's presence),
        // but fall back to streaming rather than crash on a corrupt download.
        if (cached == null) isDownloaded = false;
      }
      if (cached != null) {
        book = cached.book;
        info = cached.info;
      } else {
        final results = await Future.wait([
          _apiClient.getBook(bookId),
          _apiClient.getAudiobookInfo(bookId),
        ]);
        book = results[0] as Book;
        info = results[1] as AudiobookInfo;
      }
      if (generation != _loadGeneration) return;

      _currentBookId = bookId;
      _currentBook = book;
      _currentInfo = info;
      _isDownloaded = isDownloaded;
      _folderBased = info.folderBased;
      _tracks = info.tracks;
      _totalDurationMs = info.durationMs;
      _bookFileId = info.bookFileId;
      _retriedAfterRefresh = false;
      chaptersSubject.add(info.chapters);

      AudiobookProgress? progress;
      try {
        progress = await _apiClient.getAudiobookProgress(bookId);
      } catch (_) {
        // Best-effort — fall back to the locally cached position (if any)
        // for a downloaded book rather than always restarting from zero.
        if (isDownloaded) {
          progress = await _downloadStorage.readLocalProgress(bookId);
        }
      }
      if (generation != _loadGeneration) return;

      await _loadSource(
        book,
        info,
        initialIndex: progress?.trackIndex,
        initialPosition: progress != null
            ? Duration(milliseconds: _toTrackRelativeMs(progress))
            : null,
      );
    } finally {
      if (generation == _loadGeneration) _loadInFlight = false;
    }
  }

  /// The cached metadata for a downloaded book, refreshing an `info.json`
  /// written by a build that didn't parse `bookFileId` — without it,
  /// progress saves can't reach the server's file-level table. Best-effort:
  /// offline just keeps the local cache.
  Future<DownloadRecordSnapshot?> _readDownloadSnapshot(int bookId) async {
    final record = await _downloadStorage.readRecord(bookId);
    final cachedInfo = await _downloadStorage.readCachedInfo(bookId);
    if (record == null || cachedInfo == null) return null;
    var info = cachedInfo;
    if (info.bookFileId == null) {
      try {
        info = await _apiClient.getAudiobookInfo(bookId);
        await _downloadStorage.writeCachedInfo(bookId, info);
      } catch (_) {}
    }
    return (
      book: Book(
        id: bookId,
        title: record.title,
        authors: record.authors,
        narrator: info.narrator,
      ),
      info: info,
    );
  }

  /// [AudiobookProgress.positionMs] is absolute across the whole book's
  /// cumulative timeline (matching [AudiobookTrack.cumulativeStartMs]) —
  /// just_audio's `initialPosition` is relative to whichever track
  /// `initialIndex` points at, so this converts. For a non-folder-based
  /// book, positionMs is already the right absolute stream position.
  int _toTrackRelativeMs(AudiobookProgress progress) => trackRelativeMs(
    positionMs: progress.positionMs,
    trackIndex: progress.trackIndex,
    tracks: _tracks,
    folderBased: _folderBased,
  );

  Future<void> _loadSource(
    Book book,
    AudiobookInfo info, {
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    final items = info.folderBased && info.tracks.isNotEmpty
        ? [for (final t in info.tracks) _mediaItemForTrack(book, info, t)]
        : [_mediaItemForBook(book, info)];
    queue.add(items);

    await _player.setAudioSources(
      await _buildAudioSources(book, info),
      initialIndex: info.folderBased ? initialIndex : null,
      initialPosition: initialPosition,
    );

    final startIndex = (initialIndex ?? 0).clamp(0, items.length - 1);
    mediaItem.add(items[startIndex]);
  }

  /// One source per track for a folder-based book, a single-element list
  /// otherwise — the shape `AudioPlayer.setAudioSources` takes.
  Future<List<AudioSource>> _buildAudioSources(
    Book book,
    AudiobookInfo info,
  ) async {
    if (_isDownloaded) {
      final local = await _buildLocalAudioSources(book, info);
      if (local != null) return local;
      // A local file went missing despite isDownloaded() being true (e.g.
      // storage tampered with outside the app) — fall back to streaming
      // rather than fail playback outright.
      _isDownloaded = false;
    }
    return _buildStreamingAudioSources(book, info);
  }

  /// Returns null if any expected local file is missing, signaling the
  /// caller to fall back to streaming instead of failing outright.
  Future<List<AudioSource>?> _buildLocalAudioSources(
    Book book,
    AudiobookInfo info,
  ) async {
    if (info.folderBased && info.tracks.isNotEmpty) {
      final sources = <AudioSource>[];
      for (final track in info.tracks) {
        final path = await _downloadStorage.localTrackPath(
          book.id,
          track.index,
        );
        if (path == null) return null;
        sources.add(AudioSource.uri(Uri.file(path)));
      }
      return sources;
    }
    final path = await _downloadStorage.localSingleFilePath(book.id);
    return path == null ? null : [AudioSource.uri(Uri.file(path))];
  }

  List<AudioSource> _buildStreamingAudioSources(Book book, AudiobookInfo info) {
    final headers = _apiClient.authHeaders;
    if (!info.folderBased || info.tracks.isEmpty) {
      return [
        AudioSource.uri(
          Uri.parse(_apiClient.streamUrl(book.id)),
          headers: headers,
        ),
      ];
    }
    return [
      for (final track in info.tracks)
        AudioSource.uri(
          Uri.parse(_apiClient.trackStreamUrl(book.id, track.index)),
          headers: headers,
        ),
    ];
  }

  MediaItem _mediaItemForBook(Book book, AudiobookInfo info) => MediaItem(
    id: book.id.toString(),
    title: book.title,
    artist: book.authors.isNotEmpty ? book.authors.join(', ') : null,
    album: info.narrator ?? book.narrator,
    duration: Duration(milliseconds: info.durationMs),
    // audio_service fetches art itself for the system notification —
    // artHeaders lets it do that with the same bearer auth Grimmory's
    // cover endpoint requires everywhere else.
    artUri: Uri.parse(_apiClient.coverUrl(book.id, version: book.coverVersion)),
    artHeaders: _apiClient.authHeaders,
    extras: {'bookId': book.id},
  );

  MediaItem _mediaItemForTrack(
    Book book,
    AudiobookInfo info,
    AudiobookTrack track,
  ) => MediaItem(
    id: '${book.id}#${track.index}',
    title: book.title,
    artist: book.authors.isNotEmpty ? book.authors.join(', ') : null,
    album: info.narrator ?? book.narrator,
    duration: Duration(milliseconds: track.durationMs),
    displaySubtitle: track.title,
    artUri: Uri.parse(_apiClient.coverUrl(book.id, version: book.coverVersion)),
    artHeaders: _apiClient.authHeaders,
    extras: {'bookId': book.id, 'trackIndex': track.index},
  );

  void _updateMediaItemForIndex(int? index) {
    if (index == null) return;
    final items = queue.valueOrNull;
    if (items == null || index < 0 || index >= items.length) return;
    mediaItem.add(items[index]);
  }

  /// On any playback error, try once to reload at the same position —
  /// refreshing the token first for a streamed book, since just_audio's
  /// cross-platform PlayerException doesn't carry a reliable HTTP status
  /// code and can't cleanly distinguish "token expired mid-stream" from
  /// other failures. A spurious refresh is harmless; if the real cause
  /// wasn't auth, the reload just fails again and _retriedAfterRefresh
  /// stops it from looping. A downloaded book is rebuilt from its local
  /// files without touching the network, so recovery also works offline.
  Future<void> _handlePlaybackError(Object error, StackTrace stackTrace) async {
    final book = _currentBook;
    final info = _currentInfo;
    if (_retriedAfterRefresh || _loadInFlight || book == null || info == null) {
      return;
    }
    _retriedAfterRefresh = true;
    final generation = _loadGeneration;

    if (!_isDownloaded) {
      final refreshed = await _apiClient.refreshToken();
      if (!refreshed || generation != _loadGeneration) return;
    }

    final resumePosition = _player.position;
    final resumeIndex = _player.currentIndex;
    await _loadSource(
      book,
      info,
      initialIndex: resumeIndex,
      initialPosition: resumePosition,
    );
    if (generation == _loadGeneration && playbackState.value.playing) {
      await _player.play();
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _saveProgressNow(),
    );
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  Future<void> _saveProgressNow({bool sessionEnded = false}) async {
    final bookId = _currentBookId;
    if (bookId == null) return;
    final generation = _loadGeneration;

    final absolutePositionMs = _toAbsoluteMs(_player.position);
    final percentage = audiobookPercentage(
      positionMs: absolutePositionMs,
      totalDurationMs: _totalDurationMs,
    );
    final progress = AudiobookProgress(
      positionMs: absolutePositionMs,
      trackIndex: _folderBased ? _player.currentIndex : null,
      trackPositionMs: _folderBased ? _player.position.inMilliseconds : null,
      percentage: percentage,
    );
    final bookFileId = _bookFileId;

    if (_isDownloaded) {
      try {
        await _downloadStorage.writeLocalProgress(bookId, progress);
      } catch (_) {
        // Best-effort — a failed local cache write shouldn't block the
        // server save attempt below.
      }
    }

    try {
      await _apiClient.updateAudiobookProgress(
        bookId,
        progress,
        bookFileId: bookFileId,
      );
      // A periodic tick that was in flight while a different book loaded
      // still saved the right data (captured above) but must not announce
      // itself as that new book's session.
      if (sessionEnded || generation == _loadGeneration) {
        progressSaved.add((bookId: bookId, sessionEnded: sessionEnded));
      }
    } catch (_) {
      // Best-effort — a dropped progress save shouldn't interrupt playback.
      // The next periodic tick (or the final save on pause/stop) will
      // usually catch up once connectivity returns; only the latest
      // position matters, not a history of every missed update.
    }
  }

  /// Converts the player's current (track-relative, for folder-based books)
  /// position into the book-wide absolute position Grimmory's progress API
  /// expects — the reverse of [_toTrackRelativeMs].
  int _toAbsoluteMs(Duration playerPosition) => absoluteMs(
    trackPositionMs: playerPosition.inMilliseconds,
    trackIndex: _player.currentIndex,
    tracks: _tracks,
    folderBased: _folderBased,
  );

  /// [Bookmark.positionMs] isn't individually confirmed against a live
  /// instance, but `CreateBookMarkRequest`/`BookMark` (Grimmory source) only
  /// have `positionMs` + `trackIndex`, no separate track-relative field —
  /// same shape as [AudiobookProgress], whose `positionMs` is book-wide
  /// absolute, so this follows that same convention for consistency.
  Future<Bookmark> createBookmarkAtCurrentPosition({String? title}) {
    final bookId = _currentBookId;
    if (bookId == null) {
      throw StateError('No book is currently loaded');
    }
    return _apiClient.createBookmark(
      bookId,
      positionMs: _toAbsoluteMs(_player.position),
      trackIndex: _folderBased ? _player.currentIndex : null,
      title: title,
    );
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _player.currentIndex,
      ),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() async {
    await _player.pause();
    await _saveProgressNow(sessionEnded: true);
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// Jumps to a specific track — folder-based books only (see
  /// [seekToBookPosition] for the single-stream, chapter-marker case).
  Future<void> seekToTrack(int index) =>
      _player.seek(Duration.zero, index: index);

  /// Seeks to a book-wide position. For a folder-based book, [positionMs]
  /// is on the cumulative timeline (same as
  /// [AudiobookTrack.cumulativeStartMs]) and needs converting to (track
  /// index, track-relative position); for a single-stream book it's
  /// already the right absolute position. Used for chapter starts and
  /// bookmarks alike.
  Future<void> seekToBookPosition(int positionMs) async {
    if (!_folderBased || _tracks.isEmpty) {
      await _player.seek(Duration(milliseconds: positionMs));
      return;
    }
    var targetTrack = _tracks.first;
    for (final track in _tracks) {
      if (track.cumulativeStartMs <= positionMs) {
        targetTrack = track;
      }
    }
    final relativeMs = positionMs - targetTrack.cumulativeStartMs;
    await _player.seek(
      Duration(milliseconds: relativeMs < 0 ? 0 : relativeMs),
      index: targetTrack.index,
    );
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> stop() async {
    // Timer first, so no tick races the final save below.
    _stopProgressTimer();
    await _saveProgressNow(sessionEnded: true);
    await _player.stop();
    _currentBookId = null;
    _currentBook = null;
    _currentInfo = null;
    _isDownloaded = false;
    chaptersSubject.add([]);
    await super.stop();
  }

  /// Swiping the app away from recents — the last chance to record where
  /// the listener actually got to.
  @override
  Future<void> onTaskRemoved() => stop();

  /// Not called during normal operation (the handler lives as long as the
  /// process), but closes everything so tests and a future explicit
  /// teardown don't leak.
  Future<void> dispose() async {
    _stopProgressTimer();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await chaptersSubject.close();
    await progressSaved.close();
    await _player.dispose();
  }
}

/// What a completed download can rebuild a book from without the network.
typedef DownloadRecordSnapshot = ({Book book, AudiobookInfo info});
