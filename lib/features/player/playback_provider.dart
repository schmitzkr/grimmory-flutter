import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
