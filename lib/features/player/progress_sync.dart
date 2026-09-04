import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../library/progress_refresh.dart';
import 'playback_provider.dart';

/// Keeps the screens that show an audiobook's progress (Continue Listening,
/// the book detail, library grids) current while playback runs in the
/// background — the audiobook counterpart to the EPUB reader's exit-time
/// refresh, which has no equivalent single moment here because playback
/// outlives every screen. Both go through [refreshProgressConsumers].
///
/// Refreshes on the first accepted save after a book is loaded (so a book
/// shows up in Continue Listening within one save interval of pressing
/// Play — that first save is what flips the server's `readStatus` to
/// READING, the gate Continue Listening is built on) and on every
/// session-boundary save (pause/stop/finished/switching books), but not on
/// the periodic tick in between: audiobook percentage is never part of the
/// list DTOs anyway, so refetching those every five seconds would buy
/// nothing.
///
/// Must be watched from a widget that lives for the whole app (see
/// `GrimmoryApp`) — a `Provider` only stays alive while something listens.
final audiobookProgressSyncProvider = Provider<void>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  int? lastSyncedBookId;
  final subscription = handler.progressSaved.listen((event) {
    if (!event.sessionEnded && event.bookId == lastSyncedBookId) return;
    lastSyncedBookId = event.bookId;
    refreshProgressConsumers(ref.container, bookId: event.bookId);
  });
  ref.onDispose(subscription.cancel);
});
