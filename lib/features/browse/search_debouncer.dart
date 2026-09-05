import 'dart:async';

/// Coalesces a burst of calls into one: each [run] supersedes the previous
/// pending one, which resolves to `null` immediately, and only the last call
/// in a quiet [delay] window actually executes [action]. A result that
/// arrives after a newer call has started is also dropped (`null`), so a
/// slow early response can't overwrite a fast later one.
class SearchDebouncer {
  SearchDebouncer({this.delay = const Duration(milliseconds: 300)});

  final Duration delay;
  Timer? _timer;
  int _sequence = 0;
  Completer<Object?>? _pending;

  Future<T?> run<T>(Future<T> Function() action) {
    final sequence = ++_sequence;
    _timer?.cancel();
    _pending?.complete(null);

    final completer = Completer<Object?>();
    _pending = completer;
    _timer = Timer(delay, () async {
      if (sequence != _sequence) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }
      T? result;
      Object? error;
      StackTrace? stackTrace;
      try {
        result = await action();
      } catch (e, s) {
        error = e;
        stackTrace = s;
      }
      if (completer.isCompleted) return;
      if (sequence != _sequence) {
        completer.complete(null);
      } else if (error != null) {
        completer.completeError(error, stackTrace);
      } else {
        completer.complete(result);
      }
    });
    return completer.future.then((value) => value as T?);
  }

  void dispose() {
    _timer?.cancel();
    _pending?.complete(null);
    _pending = null;
  }
}
