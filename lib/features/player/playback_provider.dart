import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import 'audio_handler.dart';

/// Overridden in main() with the instance returned by AudioService.init() —
/// there's exactly one audio handler for the app's lifetime, created before
/// runApp() the same way apiClientProvider is.
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

/// Chapter markers for the currently loaded book — see
/// GrimmoryAudioHandler's doc comment for why this isn't folded into
/// [queueProvider] (tracks and chapters are distinct concepts; a
/// folder-based book has both, a single-stream book only has chapters).
final chaptersProvider = StreamProvider<List<AudiobookChapter>>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.chaptersSubject;
});
