import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_grid.dart';
import '../auth/current_user_provider.dart';
import 'continue_listening_section.dart';
import 'continue_reading_section.dart';
import 'recently_added_section.dart';

/// The web dashboard's `DEFAULT_MAX_ITEMS` / `MAX_ITEMS`: the most books a
/// row shows, and what a row with no `maxItems` of its own gets.
const dashboardMaxItems = 20;

/// The web's `DEFAULT_DASHBOARD_CONFIG` — what a user who has never touched
/// the dashboard editor sees, in this order.
const dashboardDefaultScrollers = [
  DashboardScroller(
    id: '1',
    type: 'lastListened',
    title: 'dashboard.scroller.continueListening',
    order: 1,
    maxItems: dashboardMaxItems,
  ),
  DashboardScroller(
    id: '2',
    type: 'lastRead',
    title: 'dashboard.scroller.continueReading',
    order: 2,
    maxItems: dashboardMaxItems,
  ),
  DashboardScroller(
    id: '3',
    type: 'latestAdded',
    title: 'dashboard.scroller.recentlyAdded',
    order: 3,
    maxItems: dashboardMaxItems,
  ),
  DashboardScroller(
    id: '4',
    type: 'random',
    title: 'dashboard.scroller.discoverNew',
    order: 4,
    maxItems: dashboardMaxItems,
  ),
];

/// The rows to render, in order: the web's `normalizeConfig` (defaults when
/// the user has no config or an empty one) plus the render-time filtering
/// its template does (`enabled` only), with two app-side guards — a type
/// this build cannot render is dropped instead of breaking the page, and a
/// magic-shelf row that lost its shelf id has nothing to show.
List<DashboardScroller> normalizeDashboard(DashboardConfig? config) {
  final source = (config == null || config.scrollers.isEmpty)
      ? dashboardDefaultScrollers
      : config.scrollers;
  final rows =
      source
          .where((s) => s.enabled)
          .where((s) => s.kind != null)
          .where(
            (s) => s.kind != ScrollerType.magicShelf || s.magicShelfId != null,
          )
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
  return rows;
}

/// The web stores its stock titles as translation keys and only custom
/// titles as plain text; magic-shelf rows carry the shelf's name.
const _titleKeys = {
  'dashboard.scroller.continueListening': 'Continue Listening',
  'dashboard.scroller.continueReading': 'Continue Reading',
  'dashboard.scroller.recentlyAdded': 'Recently Added',
  'dashboard.scroller.discoverNew': 'Discover Something New',
  'dashboard.scroller.magicShelf': 'Magic Shelf',
};

String scrollerTitle(DashboardScroller scroller) {
  final raw = scroller.title?.trim();
  if (raw == null || raw.isEmpty) {
    return switch (scroller.kind) {
      ScrollerType.lastListened => 'Continue Listening',
      ScrollerType.lastRead => 'Continue Reading',
      ScrollerType.latestAdded => 'Recently Added',
      ScrollerType.random => 'Discover Something New',
      ScrollerType.magicShelf || null => 'Magic Shelf',
    };
  }
  return _titleKeys[raw] ?? raw;
}

/// Statuses the web's "Discover Something New" leaves out: anything the
/// user has already started, finished, or set aside.
const _discoverExcludedStatuses = {
  'READ',
  'PARTIALLY_READ',
  'READING',
  'PAUSED',
  'WONT_READ',
  'ABANDONED',
};

/// The web's `getRandomBooks`: drop started/finished/set-aside books, then
/// a shuffled cut of [max]. The server already hands back a random window
/// (see `ApiClient.getRandomBooks`); the shuffle keeps that window from
/// reading as a slice of the library in added order.
List<Book> discoverPick(
  Iterable<Book> books, {
  required int max,
  Random? random,
}) {
  final candidates =
      books
          .where((b) => !_discoverExcludedStatuses.contains(b.readStatus))
          .toList()
        ..shuffle(random);
  return candidates.take(max).toList();
}

/// Read off the signed-in account ([currentUserProvider] — one request
/// serves this and the Settings header). A failure falls back to the
/// defaults rather than an error page: the rows themselves surface a dead
/// server, and a home screen that only differs in row order is better
/// than no home screen.
final dashboardConfigProvider = FutureProvider<List<DashboardScroller>>((
  ref,
) async {
  DashboardConfig? config;
  try {
    final user = await ref.watch(currentUserProvider.future);
    config = user.userSettings?.dashboardConfig;
  } catch (_) {
    config = null;
  }
  return normalizeDashboard(config);
});

/// "Discover Something New" across every library (the family key is kept
/// for a per-library variant). Twice the row length is requested so the
/// status exclusion in [discoverPick] still leaves a full row.
final discoverBooksProvider = FutureProvider.family<List<Book>, int?>((
  ref,
  libraryId,
) async {
  final books = await ref
      .read(apiClientProvider)
      .getRandomBooks(size: dashboardMaxItems * 2, libraryId: libraryId);
  return discoverPick(books, max: dashboardMaxItems);
});

/// A magic shelf pinned to the dashboard. The row's own
/// `sortField`/`sortDirection` is applied by [sortBooks] at render time,
/// as the web does after evaluating the shelf's rules locally — the
/// app-namespaced shelf endpoint takes no sort. The fetch is wider than a
/// row so the sort has the shelf's whole first page to order, not just
/// the first twenty in natural order.
final magicShelfScrollerProvider = FutureProvider.family<List<Book>, int>((
  ref,
  magicShelfId,
) async {
  return ref
      .read(apiClientProvider)
      .getMagicShelfBooks(magicShelfId, size: dashboardMaxItems * 5);
});

/// What the web's `SortService.fieldExtractors` read for each field, for
/// the fields an `AppBookSummary` carries. A field it doesn't (file name,
/// publisher, ratings, page count, …) returns null for every book, which
/// [sortBooks] treats as "leave the order alone" — the web logs a warning
/// and does the same.
Comparable<Object>? _sortKey(Book book, String field) => switch (field) {
  'title' => book.title,
  'addedOn' => book.addedOn,
  'author' => book.authors.isEmpty ? null : book.authors.first,
  'seriesName' => book.seriesName,
  'seriesNumber' => book.seriesNumber,
  'lastReadTime' => book.lastReadTime,
  'readStatus' => book.readStatus,
  'readingProgress' => book.readProgress,
  'bookType' => book.primaryFileType,
  _ => null,
};

/// The web's `SortService.applySort` for one criterion: strings compare
/// naturally (digit runs by value, so "Book 2" sorts before "Book 10",
/// case-insensitively), everything else by its own ordering, and a missing
/// value sorts after a present one before the direction is applied — so
/// `desc` puts the blanks first, exactly as the web does. A blank or
/// unknown [field], or one no book has a value for, returns [books]
/// unchanged.
List<Book> sortBooks(List<Book> books, String? field, String? direction) {
  if (field == null || field.isEmpty) return books;
  final keys = {for (final b in books) b.id: _sortKey(b, field)};
  if (keys.values.every((k) => k == null)) return books;
  final sign = direction == 'desc' ? -1 : 1;
  final sorted = [...books]
    ..sort((a, b) => sign * _compareKeys(keys[a.id], keys[b.id]));
  return sorted;
}

int _compareKeys(Comparable<Object>? a, Comparable<Object>? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  if (a is String && b is String) return naturalCompare(a, b);
  return a.compareTo(b);
}

final _chunk = RegExp(r'\d+|\D+');

/// Case-insensitive comparison that orders digit runs by numeric value.
int naturalCompare(String a, String b) {
  final ac = _chunk.allMatches(a.toLowerCase()).map((m) => m[0]!).toList();
  final bc = _chunk.allMatches(b.toLowerCase()).map((m) => m[0]!).toList();
  for (var i = 0; i < ac.length && i < bc.length; i++) {
    final x = ac[i], y = bc[i];
    final xn = int.tryParse(x), yn = int.tryParse(y);
    final c = (xn != null && yn != null) ? xn.compareTo(yn) : x.compareTo(y);
    if (c != 0) return c;
  }
  return ac.length.compareTo(bc.length);
}

/// The height a row body takes in all states (so a row loading or coming
/// back empty never shifts the rows below it): a 130-wide tile with a 2:3
/// cover and two lines of text, or the shorter square-cover version for
/// Continue Listening, whose books are all audiobooks — the web's
/// `useSquareCovers` for the `lastListened` scroller.
double _rowHeight(ScrollerType kind) =>
    kind == ScrollerType.lastListened ? 190 : 250;

/// One dashboard row — the web's `DashboardScroller`: a title, then a
/// horizontal strip of covers, or the web's per-row empty/error text in its
/// place. The Continue and Recently Added rows read the same providers the
/// reader/player exit paths already refresh (`refreshProgressConsumers`), so
/// progress made a moment ago shows up here without any extra plumbing.
class DashboardScrollerView extends ConsumerWidget {
  const DashboardScrollerView({required this.scroller, super.key});

  final DashboardScroller scroller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kind = scroller.kind!;
    final max = scroller.maxItems ?? dashboardMaxItems;
    final AsyncValue<List<Book>> raw = switch (kind) {
      ScrollerType.lastListened => ref.watch(continueListeningProvider),
      ScrollerType.lastRead => ref.watch(continueReadingProvider),
      ScrollerType.latestAdded => ref.watch(recentlyAddedProvider(null)),
      ScrollerType.random => ref.watch(discoverBooksProvider(null)),
      ScrollerType.magicShelf => ref.watch(
        magicShelfScrollerProvider(scroller.magicShelfId!),
      ),
    };
    final books = raw.whenData(
      (list) =>
          (kind == ScrollerType.magicShelf
                  ? sortBooks(list, scroller.sortField, scroller.sortDirection)
                  : list)
              .take(max)
              .toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        scrollerTitle(scroller),
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (kind == ScrollerType.magicShelf) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _rowHeight(kind),
          child: books.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _RowMessage(
              icon: Icons.error_outline,
              text: friendlyApiError(error),
            ),
            data: (list) => list.isEmpty
                ? const _RowMessage(
                    icon: Icons.menu_book_outlined,
                    text: 'No books found for this scroller.',
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 130,
                        child: BookGridTile(book: list[index]),
                      ),
                    ),
                  ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _RowMessage extends StatelessWidget {
  const _RowMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: muted),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
