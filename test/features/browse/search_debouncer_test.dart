import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/features/browse/search_debouncer.dart';

void main() {
  test('only the last call in a burst runs, earlier ones resolve null', () {
    fakeAsync((async) {
      final debouncer = SearchDebouncer(
        delay: const Duration(milliseconds: 300),
      );
      final calls = <String>[];
      final results = <String?>[];

      for (final query in ['t', 'th', 'the']) {
        debouncer
            .run(() async {
              calls.add(query);
              return 'result:$query';
            })
            .then(results.add);
      }

      async.elapse(const Duration(milliseconds: 299));
      expect(calls, isEmpty);
      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();

      expect(calls, ['the']);
      expect(results, [null, null, 'result:the']);
    });
  });

  test('a slow response is dropped once a newer call has started', () {
    fakeAsync((async) {
      final debouncer = SearchDebouncer(
        delay: const Duration(milliseconds: 100),
      );
      final results = <String?>[];

      debouncer
          .run(() => Future.delayed(const Duration(seconds: 2), () => 'slow'))
          .then(results.add);
      async.elapse(const Duration(milliseconds: 500));

      debouncer.run(() async => 'fast').then(results.add);
      async.elapse(const Duration(seconds: 3));
      async.flushMicrotasks();

      expect(results, [null, 'fast']);
    });
  });

  test('errors from the action surface to the caller', () {
    fakeAsync((async) {
      final debouncer = SearchDebouncer(delay: Duration.zero);
      Object? caught;
      debouncer.run<String>(() async => throw StateError('nope')).catchError((
        Object e,
      ) {
        caught = e;
        return null;
      });
      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();
      expect(caught, isA<StateError>());
    });
  });

  test('dispose resolves a pending call and stops the timer', () {
    fakeAsync((async) {
      final debouncer = SearchDebouncer(delay: const Duration(seconds: 1));
      var ran = false;
      String? result = 'unset';
      debouncer
          .run(() async {
            ran = true;
            return 'x';
          })
          .then((value) => result = value);
      debouncer.dispose();
      async.elapse(const Duration(seconds: 5));
      async.flushMicrotasks();
      expect(ran, isFalse);
      expect(result, isNull);
    });
  });
}
