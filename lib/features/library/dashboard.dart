import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_grid.dart';
import 'continue_listening_section.dart';
import 'continue_reading_section.dart';
import 'libraries_screen.dart' show selectedLibraryFilterProvider;
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

/// Loaded once per session (and on pull-to-refresh). A failure falls back
/// to the defaults rather than an error page: the rows themselves surface
/// a dead server, and a home screen that only differs in row order is
/// better than no home screen.
final dashboardConfigProvider = FutureProvider<List<DashboardScroller>>((
  ref,
) async {
  DashboardConfig? config;
  try {
    config = await ref.read(apiClientProvider).getDashboardConfig();
  } catch (_) {
    config = null;
  }
  return normalizeDashboard(config);
});

/// "Discover Something New", scoped like Recently Added to the Home tab's
/// library filter. Twice the row length is requested so the status
/// exclusion in [discoverPick] still leaves a full row.
final discoverBooksProvider = FutureProvider.family<List<Book>, int?>((
  ref,
  libraryId,
) async {
  final books = await ref
      .read(apiClientProvider)
      .getRandomBooks(size: dashboardMaxItems * 2, libraryId: libraryId);
  return discoverPick(books, max: dashboardMaxItems);
});

/// A magic shelf pinned to the dashboard. The web applies the row's own
/// `sortField`/`sortDirection` after evaluating the shelf's rules locally;
/// the app-namespaced shelf endpoint takes no sort, so rows come in the
/// shelf's natural order.
final magicShelfScrollerProvider = FutureProvider.family<List<Book>, int>((
  ref,
  magicShelfId,
) async {
  return ref
      .read(apiClientProvider)
      .getMagicShelfBooks(magicShelfId, size: dashboardMaxItems);
});

/// The height every row body takes in all states, so a row loading or
/// coming back empty never shifts the rows below it.
const _rowHeight = 210.0;

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
    final libraryId = ref.watch(selectedLibraryFilterProvider);
    final kind = scroller.kind!;
    final max = scroller.maxItems ?? dashboardMaxItems;
    final AsyncValue<List<Book>> raw = switch (kind) {
      ScrollerType.lastListened => ref.watch(continueListeningProvider),
      ScrollerType.lastRead => ref.watch(continueReadingProvider),
      ScrollerType.latestAdded => ref.watch(recentlyAddedProvider(libraryId)),
      ScrollerType.random => ref.watch(discoverBooksProvider(libraryId)),
      ScrollerType.magicShelf => ref.watch(
        magicShelfScrollerProvider(scroller.magicShelfId!),
      ),
    };
    final books = raw.whenData((list) => list.take(max).toList());

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
              // Recently Added caps out at one row, so a Home tab scoped to
              // one library still needs a way into that library's full,
              // paginated, filterable contents.
              if (kind == ScrollerType.latestAdded && libraryId != null)
                TextButton.icon(
                  onPressed: () => context.push('/libraries/$libraryId'),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View full library'),
                ),
            ],
          ),
        ),
        SizedBox(
          height: _rowHeight,
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
