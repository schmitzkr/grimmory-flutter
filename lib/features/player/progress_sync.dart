import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../book/book_detail_screen.dart' show bookProvider;
import '../library/continue_listening_section.dart'
    show continueListeningProvider;
import '../library/library_detail_screen.dart' show libraryBooksProvider;
import 'playback_provider.dart';

/// Keeps the screens that show an audiobook's progress (Continue Listening,
/// the book detail, library grids) current while playback runs in the
/// background — the audiobook counterpart to the EPUB reader's exit-time
/// invalidation, which has no equivalent single moment here because
/// playback outlives every screen.
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
    ref.invalidate(continueListeningProvider);
    ref.invalidate(bookProvider(event.bookId));
    ref.invalidate(libraryBooksProvider);
  });
  ref.onDispose(subscription.cancel);
});
