import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_grid.dart';
import 'continue_listening_section.dart';
import 'continue_reading_section.dart';
import 'recently_added_section.dart';

final librariesProvider = FutureProvider<List<Library>>((ref) async {
  return ref.read(apiClientProvider).getLibraries();
});

/// Which library the Home tab's Recently Added grid is scoped to — `null`
/// means "All Libraries". Set via the AppBar's library action
/// ([HomeLibraryAction]). In-memory only: resets to "All" on cold start,
/// same as any other transient screen filter in this app.
final selectedLibraryFilterProvider =
    NotifierProvider<SelectedLibraryFilterNotifier, int?>(
      SelectedLibraryFilterNotifier.new,
    );

class SelectedLibraryFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? libraryId) => state = libraryId;
}

/// Body of the Home tab on [HomeScreen] — the AppBar/BottomNavigationBar
/// live on the shell, not here. Continue Listening/Continue Reading stay as
/// header carousels (each renders nothing when empty); Recently Added fills
/// the rest of the screen as a full grid rather than a small carousel row,
/// scoped to whichever library is picked from [HomeLibraryAction].
class LibrariesTab extends ConsumerWidget {
  const LibrariesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraries = ref.watch(librariesProvider);
    final selectedLibraryId = ref.watch(selectedLibraryFilterProvider);
    final recentlyAdded = ref.watch(recentlyAddedProvider(selectedLibraryId));

    return libraries.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No libraries found.'));
        }
        return RefreshIndicator(
          onRefresh: () => Future.wait([
            ref.refresh(librariesProvider.future),
            ref.refresh(continueListeningProvider.future),
            ref.refresh(continueReadingProvider.future),
            ref.refresh(recentlyAddedProvider(selectedLibraryId).future),
          ]),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: ContinueListeningSection()),
              const SliverToBoxAdapter(child: ContinueReadingSection()),
              // A header naming this section — it used to be implicit
              // (RecentlyAddedSection carried its own "Recently Added"
              // label as a carousel title), lost when this became a plain
              // grid with no title of its own. Recently Added also caps out
              // at 30 books, so anyone scoped to a specific library still
              // needs a way to see everything in it (the full, paginated,
              // sort/filterable LibraryDetailScreen).
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recently Added',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (selectedLibraryId != null)
                        TextButton.icon(
                          onPressed: () =>
                              context.push('/libraries/$selectedLibraryId'),
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('View full library'),
                        ),
                    ],
                  ),
                ),
              ),
              ...recentlyAdded.when(
                data: (books) {
                  if (books.isEmpty) {
                    return [
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text('No books yet.')),
                      ),
                    ];
                  }
                  return [
                    SliverPadding(
                      padding: const EdgeInsets.all(12),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.62,
                            ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => BookGridTile(book: books[index]),
                          childCount: books.length,
                        ),
                      ),
                    ),
                  ];
                },
                loading: () => [
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                error: (error, _) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(friendlyApiError(error))),
                  ),
                ],
              ),
            ],
          ),
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
                onPressed: () => ref.invalidate(librariesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AppBar action for the Home tab, alongside Settings — the title itself is
/// now a persistent search bar ([HomeSearchBar]) rather than this, so this
/// only needs to be an icon. With more than one library, shows a menu to
/// re-scope the Recently Added grid to a specific library (or back to "All
/// Libraries") in place; with exactly one library there's nothing to switch
/// between, so it instead links straight to that library's own full
/// contents (`LibraryDetailScreen`, with sort/type/author filters) —
/// Recently Added alone caps out at 30 books and was never meant to replace
/// browsing a whole library. Renders nothing while libraries haven't loaded
/// yet or there are none.
class HomeLibraryAction extends ConsumerWidget {
  const HomeLibraryAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraries = ref.watch(librariesProvider).value ?? [];
    final selectedId = ref.watch(selectedLibraryFilterProvider);

    if (libraries.isEmpty) {
      return const SizedBox.shrink();
    }

    if (libraries.length == 1) {
      final library = libraries.single;
      return IconButton(
        tooltip: library.name,
        icon: const Icon(Icons.local_library_outlined),
        onPressed: () => context.push('/libraries/${library.id}'),
      );
    }

    final selectedName = selectedId == null
        ? 'All Libraries'
        : libraries
              .firstWhere(
                (l) => l.id == selectedId,
                orElse: () => libraries.first,
              )
              .name;

    return PopupMenuButton<int?>(
      tooltip: selectedName,
      icon: Icon(
        selectedId == null ? Icons.local_library_outlined : Icons.local_library,
      ),
      initialValue: selectedId,
      onSelected: (value) =>
          ref.read(selectedLibraryFilterProvider.notifier).select(value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('All Libraries')),
        for (final library in libraries)
          PopupMenuItem(value: library.id, child: Text(library.name)),
      ],
    );
  }
}
