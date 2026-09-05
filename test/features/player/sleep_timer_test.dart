import 'package:audio_service/audio_service.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';

import 'package:grimmory/features/player/audio_handler.dart';
import 'package:grimmory/features/player/playback_provider.dart';
import 'package:grimmory/features/player/sleep_timer.dart';

/// Only [pause] and the media-item stream matter to the timer; everything
/// else on the real handler touches just_audio/audio_service platform
/// channels, so it's left to noSuchMethod (and would throw if the timer
/// ever reached for it).
class _FakeHandler implements GrimmoryAudioHandler {
  int pauses = 0;

  @override
  final mediaItem = BehaviorSubject<MediaItem?>.seeded(
    const MediaItem(id: '1', title: 'One', extras: {'bookId': 1}),
  );

  @override
  Future<void> pause() async {
    pauses++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeHandler handler;

  setUp(() {
    handler = _FakeHandler();
  });

  // Built inside each fakeAsync zone so the provider's stream subscriptions
  // and the timer share one controllable clock.
  ProviderContainer buildContainer() => ProviderContainer.test(
    overrides: [audioHandlerProvider.overrideWithValue(handler)],
  );

  test('counts down once a second and pauses playback at zero', () {
    fakeAsync((async) {
      final container = buildContainer();
      final notifier = container.read(sleepTimerProvider.notifier);
      async.flushMicrotasks();
      expect(container.read(sleepTimerProvider), isNull);

      notifier.start(const Duration(seconds: 3));
      expect(container.read(sleepTimerProvider), const Duration(seconds: 3));

      async.elapse(const Duration(seconds: 1));
      expect(container.read(sleepTimerProvider), const Duration(seconds: 2));
      expect(handler.pauses, 0);

      async.elapse(const Duration(seconds: 2));
      expect(container.read(sleepTimerProvider), isNull);
      expect(handler.pauses, 1);

      // Nothing keeps ticking after it fired.
      async.elapse(const Duration(seconds: 5));
      expect(handler.pauses, 1);
    });
  });

  test('cancel stops the countdown without pausing', () {
    fakeAsync((async) {
      final container = buildContainer();
      final notifier = container.read(sleepTimerProvider.notifier);
      async.flushMicrotasks();
      notifier.start(const Duration(seconds: 2));
      async.elapse(const Duration(seconds: 1));
      notifier.cancel();
      expect(container.read(sleepTimerProvider), isNull);

      async.elapse(const Duration(seconds: 5));
      expect(handler.pauses, 0);
    });
  });

  test('restarting replaces the previous countdown', () {
    fakeAsync((async) {
      final container = buildContainer();
      final notifier = container.read(sleepTimerProvider.notifier);
      async.flushMicrotasks();
      notifier.start(const Duration(seconds: 1));
      notifier.start(const Duration(seconds: 10));

      async.elapse(const Duration(seconds: 2));
      expect(container.read(sleepTimerProvider), const Duration(seconds: 8));
      expect(handler.pauses, 0);
    });
  });

  test('switching to another book cancels the timer', () {
    fakeAsync((async) {
      final container = buildContainer();
      final notifier = container.read(sleepTimerProvider.notifier);
      async.flushMicrotasks();
      notifier.start(const Duration(seconds: 5));

      handler.mediaItem.add(
        const MediaItem(id: '2', title: 'Two', extras: {'bookId': 2}),
      );
      // Noticed on the next tick, not instantly — see SleepTimerNotifier.
      async.elapse(const Duration(seconds: 1));

      expect(container.read(sleepTimerProvider), isNull);
      async.elapse(const Duration(seconds: 10));
      expect(handler.pauses, 0);
    });
  });

  test('stopping playback cancels the timer', () {
    fakeAsync((async) {
      final container = buildContainer();
      final notifier = container.read(sleepTimerProvider.notifier);
      async.flushMicrotasks();
      notifier.start(const Duration(seconds: 5));

      handler.mediaItem.add(null);
      async.elapse(const Duration(seconds: 1));

      expect(container.read(sleepTimerProvider), isNull);
      async.elapse(const Duration(seconds: 10));
      expect(handler.pauses, 0);
    });
  });

  test('a track change within the same book keeps the timer', () {
    fakeAsync((async) {
      final container = buildContainer();
      final notifier = container.read(sleepTimerProvider.notifier);
      async.flushMicrotasks();
      notifier.start(const Duration(seconds: 5));

      handler.mediaItem.add(
        const MediaItem(id: '1#3', title: 'One', extras: {'bookId': 1}),
      );
      async.elapse(const Duration(seconds: 1));

      expect(container.read(sleepTimerProvider), const Duration(seconds: 4));
    });
  });
}
