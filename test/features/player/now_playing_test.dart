import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';

import 'package:grimmory/features/player/audio_handler.dart';
import 'package:grimmory/features/player/playback_provider.dart';

class _FakeHandler implements GrimmoryAudioHandler {
  @override
  final mediaItem = BehaviorSubject<MediaItem?>.seeded(null);

  @override
  final playbackState = BehaviorSubject<PlaybackState>.seeded(PlaybackState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeHandler handler;
  late ProviderContainer container;

  setUp(() {
    handler = _FakeHandler();
    container = ProviderContainer.test(
      overrides: [audioHandlerProvider.overrideWithValue(handler)],
    );
    container.listen(nowPlayingProvider, (_, _) {});
  });

  Future<void> settle() async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  test('is null until a book is loaded', () async {
    await settle();
    expect(container.read(nowPlayingProvider), isNull);
  });

  test('derives bookId and playing from the two streams', () async {
    handler.mediaItem.add(
      const MediaItem(id: '7', title: 'Seven', extras: {'bookId': 7}),
    );
    await settle();
    var now = container.read(nowPlayingProvider);
    expect(now?.bookId, 7);
    expect(now?.mediaItem.title, 'Seven');
    expect(now?.playing, isFalse);

    handler.playbackState.add(PlaybackState(playing: true));
    await settle();
    now = container.read(nowPlayingProvider);
    expect(now?.playing, isTrue);
    expect(now?.state?.playing, isTrue);
  });

  test('a media item without a bookId still surfaces', () async {
    handler.mediaItem.add(const MediaItem(id: 'x', title: 'Untagged'));
    await settle();
    expect(container.read(nowPlayingProvider)?.bookId, isNull);
  });
}
