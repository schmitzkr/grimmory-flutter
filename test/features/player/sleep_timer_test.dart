import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/features/player/audio_handler.dart';
import 'package:grimmory/features/player/playback_provider.dart';
import 'package:grimmory/features/player/sleep_timer.dart';

/// Only [pause] matters to the timer; everything else on the real handler
/// touches just_audio/audio_service platform channels, so it's left to
/// noSuchMethod (and would throw if the timer ever reached for it).
class _FakeHandler implements GrimmoryAudioHandler {
  int pauses = 0;

  @override
  Future<void> pause() async {
    pauses++;
  }

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
  });

  test('counts down once a second and pauses playback at zero', () {
    fakeAsync((async) {
      final notifier = container.read(sleepTimerProvider.notifier);
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
      final notifier = container.read(sleepTimerProvider.notifier);
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
      final notifier = container.read(sleepTimerProvider.notifier);
      notifier.start(const Duration(seconds: 1));
      notifier.start(const Duration(seconds: 10));

      async.elapse(const Duration(seconds: 2));
      expect(container.read(sleepTimerProvider), const Duration(seconds: 8));
      expect(handler.pauses, 0);
    });
  });
}
