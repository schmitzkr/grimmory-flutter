import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderBase;

import '../book/book_detail_screen.dart' show bookProvider;
import 'continue_listening_section.dart' show continueListeningProvider;
import 'continue_reading_section.dart' show continueReadingProvider;
import 'libraries_screen.dart' show selectedLibraryFilterProvider;
import 'library_detail_screen.dart' show libraryBooksProvider;
import 'recently_added_section.dart' show recentlyAddedProvider;

/// Refetches every provider that shows [bookId]'s progress, from wherever a
/// reading/listening session leaves it — the book detail, the Continue
/// Reading/Listening rows, the Recently Added grid, and any open library
/// grid.
///
/// `invalidate` alone is not enough here, and it's why progress kept
/// showing up only after re-entering a screen: the screens in question are
/// always *underneath* the reader/player when the save happens, and
/// Riverpod 3 pauses a widget's subscriptions while its route is off-stage
/// (`TickerMode`). Invalidating a provider whose listeners are all paused
/// only marks it dirty (`invalidateSelf` deliberately skips scheduling a
/// refresh for a non-active element), resuming does nothing but reactivate
/// subscriptions, and a route coming back on top does not rebuild its
/// widgets — so the dirty provider sat there until the screen was built
/// afresh. Reading the provider right after invalidating it forces the
/// recompute now; the paused subscription records the resulting data event
/// as missed and delivers it the moment the screen is shown again.
///
/// Only providers that are actually alive are read, so this never
/// instantiates a screen's provider the user hasn't opened. `libraryBooks`
/// is a family keyed on a query object with no way to enumerate the live
/// instances, so it is just invalidated — a library grid is always a
/// pushed route the user comes back to via a fresh build anyway.
void refreshProgressConsumers(
  ProviderContainer container, {
  required int bookId,
}) {
  void recompute(ProviderBase<Object?> provider) {
    container.invalidate(provider);
    if (container.exists(provider)) container.read(provider);
  }

  recompute(bookProvider(bookId));
  recompute(continueReadingProvider);
  recompute(continueListeningProvider);
  recompute(
    recentlyAddedProvider(container.read(selectedLibraryFilterProvider)),
  );
  container.invalidate(libraryBooksProvider);
}
