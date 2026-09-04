import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// means "All Libraries". Set via the AppBar title's dropdown
/// ([HomeLibrarySelector]). In-memory only: resets to "All" on cold start,
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
/// scoped to whichever library is picked from the AppBar title's dropdown.
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

/// AppBar title for the Home tab — shows the current library scope
/// ("All Libraries" or a specific library's name) and opens a menu to
/// change it. Only meaningful when there's more than one library; with
/// exactly one, it just labels the screen (nothing to switch between).
class HomeLibrarySelector extends ConsumerWidget {
  const HomeLibrarySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraries = ref.watch(librariesProvider).value ?? [];
    final selectedId = ref.watch(selectedLibraryFilterProvider);

    if (libraries.length <= 1) {
      return const Text('Home');
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
      initialValue: selectedId,
      onSelected: (value) =>
          ref.read(selectedLibraryFilterProvider.notifier).select(value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('All Libraries')),
        for (final library in libraries)
          PopupMenuItem(value: library.id, child: Text(library.name)),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(selectedName, overflow: TextOverflow.ellipsis)),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}
