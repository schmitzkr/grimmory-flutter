import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import 'audio_handler.dart';

final audioHandlerProvider = Provider<GrimmoryAudioHandler>(
  (ref) => throw UnimplementedError('audioHandlerProvider not overridden'),
);

final playbackStateProvider = StreamProvider<PlaybackState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.playbackState;
});

final currentMediaItemProvider = StreamProvider<MediaItem?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.mediaItem;
});

final queueProvider = StreamProvider<List<MediaItem>>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.queue;
});

final chaptersProvider = StreamProvider<List<AudiobookChapter>>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.chaptersSubject;
});

/// The loaded book as every "now playing" surface needs it, derived once:
/// [bookId] from the media item's extras, [playing] from the playback
/// state (false while nothing has reported yet), plus the raw pieces for
/// the few places that need more.
typedef NowPlaying = ({
  int? bookId,
  MediaItem mediaItem,
  bool playing,
  PlaybackState? state,
});

/// Null until a book is loaded — the mini player renders nothing, the
/// player screen shows its empty state.
final nowPlayingProvider = Provider<NowPlaying?>((ref) {
  final mediaItem = ref.watch(currentMediaItemProvider).value;
  if (mediaItem == null) return null;
  final state = ref.watch(playbackStateProvider).value;
  return (
    bookId: mediaItem.extras?['bookId'] as int?,
    mediaItem: mediaItem,
    playing: state?.playing ?? false,
    state: state,
  );
});
