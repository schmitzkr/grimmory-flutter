import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/book_grid.dart';
import '../../core/widgets/empty_state.dart';
import '../player/mini_player.dart';
import 'libraries_provider.dart';

/// A sort choice pairs a server-recognized [sort] key with a [dir]ection —
/// see `ApiClient.getLibraryBooks`'s doc comment for the full confirmed set
/// of valid `sort` keys. Kept to the ones relevant to audiobooks; the
/// server has several more (ratings, page count, etc.) this app has no use
/// for.
enum LibrarySort {
  dateAddedNewest('Date added (newest)', 'addedon', 'desc'),
  dateAddedOldest('Date added (oldest)', 'addedon', 'asc'),
  titleAZ('Title (A–Z)', 'title', 'asc'),
  titleZA('Title (Z–A)', 'title', 'desc'),
  series('Series', 'series', 'asc'),
  narrator('Narrator (A–Z)', 'narrator', 'asc');

  const LibrarySort(this.label, this.sort, this.dir);

  final String label;
  final String sort;
  final String dir;
}

/// [fileTypes] values match `Library.allowedFormats`'s enum. `null` (All)
/// omits the filter entirely; Ebooks lists every non-audiobook format so
/// it still surfaces PDF/CBX/etc. content this app can't read yet —
/// useful for seeing what's *in* the library, not just what's playable.
enum LibraryTypeFilter {
  all('All', null),
  audiobooks('Audiobooks', ['AUDIOBOOK']),
  ebooks('Ebooks', ['EPUB', 'PDF', 'CBX', 'FB2', 'MOBI', 'AZW3']);

  const LibraryTypeFilter(this.label, this.fileTypes);

  final String label;
  final List<String>? fileTypes;
}

/// How many books each [LibraryTypeFilter] would show, from the library's
/// `/app/filter-options` `fileTypes` facet (one entry per primary file
/// type with a count). Lets the type menu label each choice with its count
/// and hide a group the library simply doesn't contain, instead of the
/// fixed three-way list that used to offer "Audiobooks" on an all-EPUB
/// library.
Map<LibraryTypeFilter, int> libraryTypeCounts(List<CountedOption> fileTypes) {
  var total = 0;
  final byFilter = <LibraryTypeFilter, int>{
    LibraryTypeFilter.audiobooks: 0,
    LibraryTypeFilter.ebooks: 0,
  };
  for (final option in fileTypes) {
    total += option.count;
    for (final filter in byFilter.keys) {
      if (filter.fileTypes!.contains(option.name)) {
        byFilter[filter] = byFilter[filter]! + option.count;
      }
    }
  }
  return {LibraryTypeFilter.all: total, ...byFilter};
}

/// Query key for [libraryBooksProvider] — a record, so it gets Riverpod
/// family caching's required value equality for free.
typedef LibraryBooksQuery = ({
  int libraryId,
  LibrarySort sort,
  String? author,
  LibraryTypeFilter type,
});

/// The server's `BookListRequest` rejects any list filter longer than this
/// (`@Size(max = 20)`) with a 400.
const _maxListFilterValues = 20;

final libraryBooksProvider = FutureProvider.autoDispose
    .family<List<Book>, LibraryBooksQuery>((ref, query) async {
      return ref
          .read(apiClientProvider)
          .getLibraryBooks(
            query.libraryId,
            sort: query.sort.sort,
            dir: query.sort.dir,
            authors: query.author != null
                ? [query.author!].take(_maxListFilterValues).toList()
                : null,
            fileType: query.type.fileTypes?.take(_maxListFilterValues).toList(),
          );
    });

final filterOptionsProvider = FutureProvider.autoDispose
    .family<FilterOptions, int>((ref, libraryId) async {
      return ref.read(apiClientProvider).getFilterOptions(libraryId: libraryId);
    });

/// A library's full contents as a pushed route: the library's name in the
/// app bar (looked up from the already-loaded library list, so it appears
/// with the screen rather than after a fetch) over [LibraryBooksView].
class LibraryDetailScreen extends ConsumerWidget {
  const LibraryDetailScreen({required this.libraryId, super.key});

  final int libraryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref
        .watch(librariesProvider)
        .value
        ?.where((l) => l.id == libraryId)
        .map((l) => l.name)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(name ?? 'Library')),
      body: LibraryBooksView(libraryId: libraryId),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}

/// A library's books with their sort, format and author controls in a
/// toolbar above the grid. Used both by [LibraryDetailScreen] and directly
/// inside the Libraries tab when the account has exactly one library, so
/// the controls cannot live in an app bar the widget does not own.
class LibraryBooksView extends ConsumerStatefulWidget {
  const LibraryBooksView({required this.libraryId, this.header, super.key});

  final int libraryId;

  /// Shown above the toolbar — the tab uses it for the library's name,
  /// since there the app bar belongs to the Home shell.
  final Widget? header;

  @override
  ConsumerState<LibraryBooksView> createState() => _LibraryBooksViewState();
}

class _LibraryBooksViewState extends ConsumerState<LibraryBooksView> {
  LibrarySort _sort = LibrarySort.dateAddedNewest;
  String? _author;
  LibraryTypeFilter _type = LibraryTypeFilter.all;

  @override
  Widget build(BuildContext context) {
    final query = (
      libraryId: widget.libraryId,
      sort: _sort,
      author: _author,
      type: _type,
    );
    final books = ref.watch(libraryBooksProvider(query));
    // Counts are a nicety: while they're loading (or if they fail) the
    // menu just shows the plain labels.
    final fileTypes = ref
        .watch(filterOptionsProvider(widget.libraryId))
        .value
        ?.fileTypes;
    final typeCounts = fileTypes == null ? null : libraryTypeCounts(fileTypes);

    return Column(
      children: [
        if (widget.header != null) widget.header!,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              PopupMenuButton<LibraryTypeFilter>(
                tooltip: 'Show',
                initialValue: _type,
                onSelected: (value) => setState(() => _type = value),
                itemBuilder: (context) => [
                  for (final option in LibraryTypeFilter.values)
                    if (typeCounts == null ||
                        option == LibraryTypeFilter.all ||
                        option == _type ||
                        (typeCounts[option] ?? 0) > 0)
                      PopupMenuItem(
                        value: option,
                        child: Text(
                          typeCounts == null
                              ? option.label
                              : '${option.label} (${typeCounts[option] ?? 0})',
                        ),
                      ),
                ],
                child: _ToolbarChip(
                  icon: _type == LibraryTypeFilter.all
                      ? Icons.category_outlined
                      : Icons.category,
                  label: _type.label,
                  active: _type != LibraryTypeFilter.all,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  final selected = await _showAuthorFilterSheet(context);
                  if (selected != _author) setState(() => _author = selected);
                },
                child: _ToolbarChip(
                  icon: _author == null ? Icons.filter_list : Icons.filter_alt,
                  label: _author ?? 'Author',
                  active: _author != null,
                  onClear: _author == null
                      ? null
                      : () => setState(() => _author = null),
                ),
              ),
              const Spacer(),
              PopupMenuButton<LibrarySort>(
                tooltip: 'Sort',
                initialValue: _sort,
                onSelected: (value) => setState(() => _sort = value),
                itemBuilder: (context) => [
                  for (final option in LibrarySort.values)
                    PopupMenuItem(value: option, child: Text(option.label)),
                ],
                child: _ToolbarChip(icon: Icons.sort, label: _sort.label),
              ),
            ],
          ),
        ),
        Expanded(
          child: AsyncValueView(
            value: books,
            onRetry: () => ref.invalidate(libraryBooksProvider(query)),
            data: (items) {
              if (items.isEmpty) {
                return EmptyState(
                  _author != null
                      ? 'No books by "$_author" in this library.'
                      : 'No books in this library.',
                );
              }
              return RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(libraryBooksProvider(query).future),
                child: BookGrid(books: items),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<String?> _showAuthorFilterSheet(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _AuthorFilterSheet(libraryId: widget.libraryId, selected: _author),
    );
  }
}

/// One toolbar control: icon + current value, highlighted while a filter
/// is narrowing the grid, with an optional clear button.
class _ToolbarChip extends StatelessWidget {
  const _ToolbarChip({
    required this.icon,
    required this.label,
    this.active = false,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = active ? scheme.primary : scheme.onSurfaceVariant;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200, minHeight: 44),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: color),
              ),
            ),
            if (onClear != null)
              IconButton(
                tooltip: 'Clear filter',
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                icon: const Icon(Icons.close),
                onPressed: onClear,
              ),
          ],
        ),
      ),
    );
  }
}

class _AuthorFilterSheet extends ConsumerWidget {
  const _AuthorFilterSheet({required this.libraryId, required this.selected});

  final int libraryId;
  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(filterOptionsProvider(libraryId));

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Filter by author', style: TextStyle(fontSize: 18)),
            ),
            Expanded(
              child: AsyncValueView(
                value: options,
                errorMessage: 'Could not load authors.',
                onRetry: () => ref.invalidate(filterOptionsProvider(libraryId)),
                data: (data) {
                  final authors = data.authors;
                  if (authors.isEmpty) {
                    return const EmptyState('No authors found.');
                  }
                  return RadioGroup<String>(
                    groupValue: selected,
                    onChanged: (value) => Navigator.of(context).pop(value),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: authors.length,
                      itemBuilder: (context, index) {
                        final option = authors[index];
                        return RadioListTile<String>(
                          value: option.name,
                          title: Text(option.name),
                          subtitle: Text('${option.count}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
