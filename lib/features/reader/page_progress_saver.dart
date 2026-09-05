import 'dart:async';

import '../../core/api/models.dart';
import 'page_progress.dart';

/// Debounced, serialised page-progress saving shared by the comic and PDF
/// readers. Flipping through several pages collapses into one save of the
/// newest page; at most one save is on the wire at a time, and a page
/// change during a save is saved right after it; the exit path's
/// [saveNow] waits for any in-flight save so it cannot be overtaken by a
/// stale one.
///
/// Page indices are 0-based; [pageNumberAt] maps one to the page number
/// the server stores (the comic reader's server-listed page ids, or simply
/// `index + 1` for a PDF).
class PageProgressSaver {
  PageProgressSaver({
    required this.persist,
    required this.pageCount,
    required this.pageNumberAt,
    this.debounce = const Duration(milliseconds: 1500),
    this.onError,
  });

  /// Sends one progress record to the server; throws on failure.
  final Future<void> Function(PageProgress progress) persist;
  final int pageCount;
  final int Function(int index) pageNumberAt;
  final Duration debounce;

  /// Called once per failed save with the error, for the caller's snackbar.
  final void Function(Object error)? onError;

  int? _pendingIndex;
  Timer? _timer;
  Future<void>? _inFlight;
  bool _disposed = false;

  /// What [persist] receives for page [index].
  PageProgress progressAt(int index) => PageProgress(
    page: pageNumberAt(index),
    percentage: pagePercentage(pageIndex: index, pageCount: pageCount),
  );

  /// The reader moved to page [index]; a save follows after [debounce].
  void pageChanged(int index) {
    if (_disposed) return;
    _pendingIndex = index;
    _timer?.cancel();
    _timer = Timer(debounce, flush);
  }

  /// Starts the pending save now (no-op if none, or one is in flight — that
  /// one's completion flushes again).
  void flush() {
    if (_disposed || _inFlight != null) return;
    final index = _pendingIndex;
    if (index == null) return;
    _pendingIndex = null;
    _inFlight = _save(index).whenComplete(() {
      _inFlight = null;
      if (_pendingIndex != null) flush();
    });
  }

  /// The final save on exit: drops any passive save still pending, waits
  /// for one already in flight, then saves [index]. True on success.
  Future<bool> saveNow(int index) async {
    _timer?.cancel();
    _pendingIndex = null;
    await _inFlight;
    return _save(index);
  }

  Future<bool> _save(int index) async {
    try {
      await persist(progressAt(index));
      return true;
    } catch (e) {
      onError?.call(e);
      return false;
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _pendingIndex = null;
  }
}
