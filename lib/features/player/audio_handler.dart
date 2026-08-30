import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/api/api_client.dart';
import '../../core/api/models.dart';

/// Wraps a single [AudioPlayer] with Grimmory's streaming endpoints and
/// exposes it as an [AudioHandler] — this is what turns playback into a
/// proper Android foreground service with a media-style notification (and,
/// later, the Android Auto browse surface — see the project plan's M3).
///
/// One book plays at a time; there's no general music-library queue here
/// (no shuffle, no reordering, no adding arbitrary items) — audiobooks are
/// linear by nature, so [queue] just holds the current book's tracks in
/// order and skip-next/previous means "next/previous track", not a
/// user-editable playlist.
class GrimmoryAudioHandler extends BaseAudioHandler with SeekHandler {
  GrimmoryAudioHandler(this._apiClient) {
    _init();
  }

  final ApiClient _apiClient;
  final AudioPlayer _player = AudioPlayer();

  String? _currentBookId;
  String? get currentBookId => _currentBookId;

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

  @override
  Future<void> playFromMediaId(String mediaId, [Map<String, dynamic>? extras]) async {
    await loadBook(mediaId);
    await play();
  }

  /// Loads [bookId]'s audio source and resumes from the server's saved
  /// progress (if any). Called directly by the book detail screen's Play
  /// button (via [playFromMediaId]), not just from Android Auto's browse
  /// tree — this is the one entry point for starting playback on a book.
  Future<void> loadBook(String bookId) async {
    _stopProgressTimer();
    await _saveProgressNow();

    final results = await Future.wait([
      _apiClient.getBook(bookId),
      _apiClient.getAudiobookInfo(bookId),
    ]);
    final book = results[0] as Book;
    final info = results[1] as AudiobookInfo;

    _currentBookId = bookId;
    _retriedAfterRefresh = false;

    Progress? progress;
    try {
      progress = await _apiClient.getProgress(bookId);
    } catch (_) {
      // Best-effort — don't block playback on a progress-fetch failure.
    }

    await _loadSource(
      book,
      info,
      initialIndex: progress?.trackIndex,
      initialPosition: progress != null
          ? Duration(seconds: progress.positionSeconds.round())
          : null,
    );

    _startProgressTimer();
  }

  Future<void> _loadSource(
    Book book,
    AudiobookInfo info, {
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    final items = info.tracks.isEmpty
        ? [_mediaItemFor(book, info, trackIndex: null)]
        : List.generate(
            info.tracks.length,
            (i) => _mediaItemFor(book, info, trackIndex: i),
          );
    queue.add(items);

    final source = _buildAudioSource(book, info);
    await _player.setAudioSource(
      source,
      initialIndex: initialIndex,
      initialPosition: initialPosition,
    );

    final startIndex = (initialIndex ?? 0).clamp(0, items.length - 1);
    mediaItem.add(items[startIndex]);
  }

  AudioSource _buildAudioSource(Book book, AudiobookInfo info) {
    final headers = _apiClient.authHeaders;
    if (info.tracks.length <= 1) {
      return AudioSource.uri(
        Uri.parse(_apiClient.streamUrl(book.id)),
        headers: headers,
      );
    }
    return ConcatenatingAudioSource(
      children: [
        for (var i = 0; i < info.tracks.length; i++)
          AudioSource.uri(
            Uri.parse(_apiClient.trackStreamUrl(book.id, i)),
            headers: headers,
          ),
      ],
    );
  }

  MediaItem _mediaItemFor(Book book, AudiobookInfo info, {int? trackIndex}) {
    final track =
        trackIndex != null && trackIndex < info.tracks.length
        ? info.tracks[trackIndex]
        : null;
    return MediaItem(
      id: trackIndex != null ? '${book.id}#$trackIndex' : book.id,
      title: book.title,
      artist: book.author,
      album: info.narrator,
      duration: track != null
          ? Duration(seconds: track.durationSeconds.round())
          : (info.totalDurationSeconds != null
                ? Duration(seconds: info.totalDurationSeconds!.round())
                : null),
      // audio_service fetches art itself for the system notification —
      // artHeaders lets it do that with the same bearer auth Grimmory's
      // cover endpoint requires everywhere else.
      artUri: Uri.parse(_apiClient.coverUrl(book.id)),
      artHeaders: _apiClient.authHeaders,
      displaySubtitle: track?.title,
      extras: {'bookId': book.id, 'trackIndex': ?trackIndex},
    );
  }

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
      await _apiClient.saveProgress(
        Progress(
          bookId: bookId,
          positionSeconds: _player.position.inMilliseconds / 1000,
          trackIndex: _player.currentIndex,
        ),
      );
    } catch (_) {
      // Best-effort — a dropped progress save shouldn't interrupt playback.
      // The next periodic tick (or the final save on pause/stop) will
      // usually catch up.
    }
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

  /// Jumps to a specific track (chapter navigation) — distinct from
  /// [skipToNext]/[skipToPrevious], which move by one track relative to
  /// the current one. Used by the player screen's track list.
  Future<void> seekToTrack(int index) => _player.seek(Duration.zero, index: index);

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
    await super.stop();
  }
}
