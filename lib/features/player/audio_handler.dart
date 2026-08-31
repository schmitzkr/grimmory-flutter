import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../../core/api/api_client.dart';
import '../../core/api/models.dart';

/// Wraps a single [AudioPlayer] with Grimmory's streaming endpoints and
/// exposes it as an [AudioHandler] — this is what turns playback into a
/// proper Android foreground service with a media-style notification, and
/// the Android Auto browse surface via [getChildren].
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
class GrimmoryAudioHandler extends BaseAudioHandler with SeekHandler {
  GrimmoryAudioHandler(this._apiClient) {
    _init();
  }

  final ApiClient _apiClient;
  final AudioPlayer _player = AudioPlayer();

  int? _currentBookId;
  int? get currentBookId => _currentBookId;

  bool _folderBased = false;
  List<AudiobookTrack> _tracks = [];
  int _totalDurationMs = 0;

  /// Chapter markers for the currently loaded book — not part of the base
  /// [AudioHandler] interface (audio_service has no chapter concept), so
  /// exposed as a plain extra subject the player screen watches directly.
  final BehaviorSubject<List<AudiobookChapter>> chaptersSubject =
      BehaviorSubject.seeded([]);

  Timer? _progressTimer;
  // Guards against retry-looping forever if a refreshed token still fails
  // (e.g. the server itself is down, not just the token) — one retry per
  // load, not per error.
  bool _retriedAfterRefresh = false;

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _player.playbackEventStream.listen(
      _broadcastState,
      onError: _handlePlaybackError,
    );
    _player.currentIndexStream.listen(_updateMediaItemForIndex);
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _saveProgressNow();
        _stopProgressTimer();
      }
    });
  }

  // ── Browse tree (Android Auto) ────────────────────────────────────────
  //
  // audio_service's Android backend already implements MediaBrowserService;
  // this is the one method that surface actually needs. No custom Kotlin
  // required. Static per-call (not pushed/subscribed) — BaseAudioHandler's
  // default subscribeToChildren is fine for content that doesn't need to
  // update while the user is browsing it.
  static const _rootContinueListening = 'root:continue';
  static const _rootLibraries = 'root:libraries';
  static const _rootSeries = 'root:series';

  @override
  Future<List<MediaItem>> getChildren(
    String parentMediaId, [
    Map<String, dynamic>? options,
  ]) async {
    switch (parentMediaId) {
      case AudioService.browsableRootId:
        return const [
          MediaItem(
            id: _rootContinueListening,
            title: 'Continue Listening',
            playable: false,
          ),
          MediaItem(id: _rootLibraries, title: 'Libraries', playable: false),
          MediaItem(id: _rootSeries, title: 'Series', playable: false),
        ];
      case _rootContinueListening:
        final books = await _apiClient.getContinueListening();
        return books.map(_mediaItemForBrowse).toList();
      case _rootLibraries:
        final libraries = await _apiClient.getLibraries();
        return [
          for (final library in libraries)
            MediaItem(
              id: 'lib:${library.id}',
              title: library.name,
              playable: false,
            ),
        ];
      case _rootSeries:
        final series = await _apiClient.getSeries();
        return [
          for (final s in series)
            MediaItem(
              id: 'series:${Uri.encodeComponent(s.seriesName)}',
              title: s.seriesName,
              playable: false,
            ),
        ];
      default:
        if (parentMediaId.startsWith('lib:')) {
          final libraryId = int.parse(parentMediaId.substring(4));
          final books = await _apiClient.getLibraryBooks(libraryId);
          return books.map(_mediaItemForBrowse).toList();
        }
        if (parentMediaId.startsWith('series:')) {
          final seriesName = Uri.decodeComponent(
            parentMediaId.substring('series:'.length),
          );
          final books = await _apiClient.getSeriesBooks(seriesName);
          return books.map(_mediaItemForBrowse).toList();
        }
        return const [];
    }
  }

  /// A playable leaf in the browse tree — id is the bare book id (no track
  /// suffix), so tapping it in Android Auto calls [playFromMediaId] exactly
  /// the same way the phone UI's Play button does.
  MediaItem _mediaItemForBrowse(Book book) => MediaItem(
    id: book.id.toString(),
    title: book.title,
    artist: book.authors.isNotEmpty ? book.authors.join(', ') : null,
    artUri: Uri.parse(_apiClient.coverUrl(book.id)),
    artHeaders: _apiClient.authHeaders,
    playable: true,
    extras: {'bookId': book.id},
  );

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
  Future<void> loadBook(int bookId) async {
    _stopProgressTimer();
    await _saveProgressNow();

    final results = await Future.wait([
      _apiClient.getBook(bookId),
      _apiClient.getAudiobookInfo(bookId),
    ]);
    final book = results[0] as Book;
    final info = results[1] as AudiobookInfo;

    _currentBookId = bookId;
    _folderBased = info.folderBased;
    _tracks = info.tracks;
    _totalDurationMs = info.durationMs;
    _retriedAfterRefresh = false;
    chaptersSubject.add(info.chapters);

    AudiobookProgress? progress;
    try {
      progress = await _apiClient.getAudiobookProgress(bookId);
    } catch (_) {
      // Best-effort — don't block playback on a progress-fetch failure.
    }

    await _loadSource(
      book,
      info,
      initialIndex: progress?.trackIndex,
      initialPosition: progress != null
          ? Duration(milliseconds: _toTrackRelativeMs(progress))
          : null,
    );

    _startProgressTimer();
  }

  /// [AudiobookProgress.positionMs] is absolute across the whole book's
  /// cumulative timeline (matching [AudiobookTrack.cumulativeStartMs]) —
  /// just_audio's `initialPosition` is relative to whichever track
  /// `initialIndex` points at, so this converts. For a non-folder-based
  /// book, positionMs is already the right absolute stream position.
  int _toTrackRelativeMs(AudiobookProgress progress) {
    if (!_folderBased || progress.trackIndex == null) return progress.positionMs;
    final index = progress.trackIndex!;
    if (index < 0 || index >= _tracks.length) return progress.positionMs;
    final relative = progress.positionMs - _tracks[index].cumulativeStartMs;
    return relative < 0 ? 0 : relative;
  }

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

    final source = _buildAudioSource(book, info);
    await _player.setAudioSource(
      source,
      initialIndex: info.folderBased ? initialIndex : null,
      initialPosition: initialPosition,
    );

    final startIndex = (initialIndex ?? 0).clamp(0, items.length - 1);
    mediaItem.add(items[startIndex]);
  }

  AudioSource _buildAudioSource(Book book, AudiobookInfo info) {
    final headers = _apiClient.authHeaders;
    if (!info.folderBased || info.tracks.isEmpty) {
      return AudioSource.uri(
        Uri.parse(_apiClient.streamUrl(book.id)),
        headers: headers,
      );
    }
    return ConcatenatingAudioSource(
      children: [
        for (final track in info.tracks)
          AudioSource.uri(
            Uri.parse(_apiClient.trackStreamUrl(book.id, track.index)),
            headers: headers,
          ),
      ],
    );
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
    artUri: Uri.parse(_apiClient.coverUrl(book.id)),
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
    artUri: Uri.parse(_apiClient.coverUrl(book.id)),
    artHeaders: _apiClient.authHeaders,
    extras: {'bookId': book.id, 'trackIndex': track.index},
  );

  void _updateMediaItemForIndex(int? index) {
    if (index == null) return;
    final items = queue.valueOrNull;
    if (items == null || index < 0 || index >= items.length) return;
    mediaItem.add(items[index]);
  }

  /// On any playback error, try once to refresh the token and reload at the
  /// same position — just_audio's cross-platform PlayerException doesn't
  /// carry a reliable HTTP status code, so this can't cleanly distinguish
  /// "token expired mid-stream" from other failures. A spurious refresh is
  /// harmless; if the real cause wasn't auth, the reload just fails again
  /// and _retriedAfterRefresh stops it from looping.
  Future<void> _handlePlaybackError(Object error, StackTrace stackTrace) async {
    final bookId = _currentBookId;
    if (_retriedAfterRefresh || bookId == null) return;
    _retriedAfterRefresh = true;

    final refreshed = await _apiClient.refreshToken();
    if (!refreshed) return;

    final resumePosition = _player.position;
    final resumeIndex = _player.currentIndex;
    final results = await Future.wait([
      _apiClient.getBook(bookId),
      _apiClient.getAudiobookInfo(bookId),
    ]);
    await _loadSource(
      results[0] as Book,
      results[1] as AudiobookInfo,
      initialIndex: resumeIndex,
      initialPosition: resumePosition,
    );
    if (playbackState.value.playing) await _player.play();
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

  Future<void> _saveProgressNow() async {
    final bookId = _currentBookId;
    if (bookId == null) return;
    try {
      final absolutePositionMs = _toAbsoluteMs(_player.position);
      final percentage = _totalDurationMs > 0
          ? (absolutePositionMs / _totalDurationMs).clamp(0.0, 1.0)
          : 0.0;
      await _apiClient.updateAudiobookProgress(
        bookId,
        AudiobookProgress(
          positionMs: absolutePositionMs,
          trackIndex: _folderBased ? _player.currentIndex : null,
          trackPositionMs: _folderBased
              ? _player.position.inMilliseconds
              : null,
          percentage: percentage,
        ),
      );
    } catch (_) {
      // Best-effort — a dropped progress save shouldn't interrupt playback.
      // The next periodic tick (or the final save on pause/stop) will
      // usually catch up.
    }
  }

  /// Converts the player's current (track-relative, for folder-based books)
  /// position into the book-wide absolute position Grimmory's progress API
  /// expects — the reverse of [_toTrackRelativeMs].
  int _toAbsoluteMs(Duration playerPosition) {
    if (!_folderBased) return playerPosition.inMilliseconds;
    final index = _player.currentIndex;
    if (index == null || index < 0 || index >= _tracks.length) {
      return playerPosition.inMilliseconds;
    }
    return _tracks[index].cumulativeStartMs + playerPosition.inMilliseconds;
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
    await _saveProgressNow();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// Jumps to a specific track — folder-based books only (see
  /// [seekToChapterStart] for the single-stream, chapter-marker case).
  Future<void> seekToTrack(int index) =>
      _player.seek(Duration.zero, index: index);

  /// Seeks within the current stream to a chapter's start. For a
  /// folder-based book, [startTimeMs] is on the book-wide cumulative
  /// timeline (same as [AudiobookTrack.cumulativeStartMs]) and needs
  /// converting to (track index, track-relative position); for a
  /// single-stream book it's already the right absolute position.
  Future<void> seekToChapterStart(int startTimeMs) async {
    if (!_folderBased || _tracks.isEmpty) {
      await _player.seek(Duration(milliseconds: startTimeMs));
      return;
    }
    var targetTrack = _tracks.first;
    for (final track in _tracks) {
      if (track.cumulativeStartMs <= startTimeMs) {
        targetTrack = track;
      }
    }
    final relativeMs = startTimeMs - targetTrack.cumulativeStartMs;
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
    await _saveProgressNow();
    _stopProgressTimer();
    await _player.stop();
    _currentBookId = null;
    chaptersSubject.add([]);
    await super.stop();
  }
}
