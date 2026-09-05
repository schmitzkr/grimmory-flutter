import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/api/models.dart';
import 'package:grimmory/features/reader/page_progress_saver.dart';

void main() {
  const debounce = Duration(seconds: 1);

  test('maps an index to the server page number and web percentage', () {
    final saver = PageProgressSaver(
      persist: (_) async {},
      pageCount: 4,
      pageNumberAt: (i) => [10, 20, 30, 40][i],
    );
    expect(saver.progressAt(1), const PageProgress(page: 20, percentage: 50));
    expect(saver.progressAt(3).percentage, 100);
  });

  test('collapses a burst of page changes into one save of the last page', () {
    fakeAsync((async) {
      final saved = <int>[];
      final saver = PageProgressSaver(
        persist: (p) async => saved.add(p.page),
        pageCount: 10,
        pageNumberAt: (i) => i + 1,
        debounce: debounce,
      );
      saver
        ..pageChanged(0)
        ..pageChanged(1)
        ..pageChanged(2);
      async.elapse(const Duration(milliseconds: 900));
      expect(saved, isEmpty);
      async.elapse(const Duration(milliseconds: 200));
      expect(saved, [3]);
    });
  });

  // One save on the wire at a time: a page change during a save is saved
  // right after it, not dropped and not sent concurrently.
  test('queues a change made while a save is in flight', () {
    fakeAsync((async) {
      final saved = <int>[];
      final gate = Completer<void>();
      var calls = 0;
      final saver = PageProgressSaver(
        persist: (p) async {
          calls++;
          if (calls == 1) await gate.future;
          saved.add(p.page);
        },
        pageCount: 10,
        pageNumberAt: (i) => i + 1,
        debounce: debounce,
      );
      saver.pageChanged(0);
      async.elapse(debounce);
      expect(calls, 1);

      saver.pageChanged(4);
      async.elapse(debounce);
      expect(calls, 1, reason: 'must wait for the in-flight save');

      gate.complete();
      async.flushMicrotasks();
      expect(saved, [1, 5]);
      expect(calls, 2);
    });
  });

  test('saveNow drops the pending passive save, waits, then saves', () {
    fakeAsync((async) {
      final saved = <int>[];
      final gate = Completer<void>();
      var calls = 0;
      final saver = PageProgressSaver(
        persist: (p) async {
          calls++;
          if (calls == 1) await gate.future;
          saved.add(p.page);
        },
        pageCount: 10,
        pageNumberAt: (i) => i + 1,
        debounce: debounce,
      );
      saver.pageChanged(0);
      async.elapse(debounce); // first save in flight, blocked on the gate
      saver.pageChanged(2); // pending passive save that must be dropped

      bool? result;
      saver.saveNow(7).then((ok) => result = ok);
      async.elapse(debounce * 2);
      expect(result, isNull, reason: 'still waiting on the in-flight save');

      gate.complete();
      async.flushMicrotasks();
      expect(result, isTrue);
      expect(saved, [1, 8], reason: 'page 3 was superseded by the exit save');
    });
  });

  test('reports failures through onError and returns false', () {
    fakeAsync((async) {
      final errors = <Object>[];
      final saver = PageProgressSaver(
        persist: (_) async => throw StateError('offline'),
        pageCount: 3,
        pageNumberAt: (i) => i + 1,
        debounce: debounce,
        onError: errors.add,
      );
      saver.pageChanged(1);
      async.elapse(debounce);
      expect(errors, hasLength(1));

      bool? result;
      saver.saveNow(2).then((ok) => result = ok);
      async.flushMicrotasks();
      expect(result, isFalse);
      expect(errors, hasLength(2));
    });
  });

  test('does nothing after dispose', () {
    fakeAsync((async) {
      var calls = 0;
      final saver = PageProgressSaver(
        persist: (_) async => calls++,
        pageCount: 3,
        pageNumberAt: (i) => i + 1,
        debounce: debounce,
      );
      saver.pageChanged(1);
      saver.dispose();
      async.elapse(debounce * 2);
      expect(calls, 0);
    });
  });
}
