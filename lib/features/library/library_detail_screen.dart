import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_grid.dart';

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

/// Query key for [libraryBooksProvider] — a record, so it gets Riverpod
/// family caching's required value equality for free.
typedef LibraryBooksQuery = ({
  int libraryId,
  LibrarySort sort,
  String? author,
  LibraryTypeFilter type,
});

final libraryBooksProvider =
    FutureProvider.family<List<Book>, LibraryBooksQuery>((ref, query) async {
      return ref
          .read(apiClientProvider)
          .getLibraryBooks(
            query.libraryId,
            sort: query.sort.sort,
            dir: query.sort.dir,
            authors: query.author != null ? [query.author!] : null,
            fileType: query.type.fileTypes,
          );
    });

final filterOptionsProvider = FutureProvider.family<FilterOptions, int>((
  ref,
  libraryId,
) async {
  return ref.read(apiClientProvider).getFilterOptions(libraryId: libraryId);
});

class LibraryDetailScreen extends ConsumerStatefulWidget {
  const LibraryDetailScreen({required this.libraryId, super.key});

  final int libraryId;

  @override
  ConsumerState<LibraryDetailScreen> createState() =>
      _LibraryDetailScreenState();
}

class _LibraryDetailScreenState extends ConsumerState<LibraryDetailScreen> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          PopupMenuButton<LibraryTypeFilter>(
            tooltip: 'Show',
            icon: Icon(
              _type == LibraryTypeFilter.all
                  ? Icons.category_outlined
                  : Icons.category,
            ),
            initialValue: _type,
            onSelected: (value) => setState(() => _type = value),
            itemBuilder: (context) => [
              for (final option in LibraryTypeFilter.values)
                PopupMenuItem(value: option, child: Text(option.label)),
            ],
          ),
          if (_author != null)
            IconButton(
              tooltip: 'Clear filter',
              icon: const Icon(Icons.filter_alt_off_outlined),
              onPressed: () => setState(() => _author = null),
            ),
          IconButton(
            tooltip: 'Filter by author',
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final selected = await _showAuthorFilterSheet(context);
              if (selected != _author) setState(() => _author = selected);
            },
          ),
          PopupMenuButton<LibrarySort>(
            tooltip: 'Sort',
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (context) => [
              for (final option in LibrarySort.values)
                PopupMenuItem(value: option, child: Text(option.label)),
            ],
          ),
        ],
      ),
      body: books.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                _author != null
                    ? 'No audiobooks by "$_author" in this library.'
                    : 'No audiobooks in this library.',
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(libraryBooksProvider(query).future),
            child: BookGrid(books: items),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(friendlyApiError(error)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(libraryBooksProvider(query)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
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
              child: options.when(
                data: (data) {
                  final authors = data.authors;
                  if (authors.isEmpty) {
                    return const Center(child: Text('No authors found.'));
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    const Center(child: Text('Could not load authors.')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
