import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/empty_state.dart';
import '../auth/current_user_provider.dart';
import 'continue_listening_section.dart';
import 'continue_reading_section.dart';
import 'dashboard.dart';
import 'recently_added_section.dart';

final librariesProvider = FutureProvider<List<Library>>((ref) async {
  return ref.read(apiClientProvider).getLibraries();
});

/// Which library the Home tab's Recently Added and Discover rows are scoped
/// to — `null` means "All Libraries". Set via the AppBar's library action
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
/// live on the shell, not here. Modelled on Grimmory's web dashboard: the
/// user's own row layout from their account settings (or the web's
/// defaults — Continue Listening, Continue Reading, Recently Added,
/// Discover Something New), each row a titled horizontal strip with the
/// web's per-row empty/error text. Recently Added and Discover are scoped
/// to whichever library [HomeLibraryAction] picks; the Continue rows and
/// magic shelves span every library, as on the web.
class LibrariesTab extends ConsumerWidget {
  const LibrariesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraries = ref.watch(librariesProvider);
    final selectedLibraryId = ref.watch(selectedLibraryFilterProvider);

    return AsyncValueView(
      value: libraries,
      onRetry: () => ref.invalidate(librariesProvider),
      data: (items) {
        if (items.isEmpty) return const EmptyState('No libraries found.');
        final scrollers = ref.watch(dashboardConfigProvider);
        return RefreshIndicator(
          // Each refresh fails on its own — one row's error must not reject
          // the whole gesture (which surfaced as an unhandled error out of
          // RefreshIndicator). Magic-shelf rows are family members with ids
          // only the config knows, so the whole family is invalidated.
          onRefresh: () {
            ref.invalidate(magicShelfScrollerProvider);
            return Future.wait([
              for (final refresh in [
                ref.refresh(librariesProvider.future),
                ref.refresh(currentUserProvider.future),
                ref.refresh(dashboardConfigProvider.future),
                ref.refresh(continueListeningProvider.future),
                ref.refresh(continueReadingProvider.future),
                ref.refresh(recentlyAddedProvider(selectedLibraryId).future),
                ref.refresh(discoverBooksProvider(selectedLibraryId).future),
              ])
                refresh.then<void>((_) {}, onError: (_) {}),
            ], eagerError: false);
          },
          // Every branch is a scrollable so pull-to-refresh works in all of
          // them; the config provider never errors (it falls back to the
          // defaults), so only loading and data are real.
          child: scrollers.when(
            loading: () => ListView(
              children: const [
                SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
            error: (error, _) => ListView(
              children: [
                ErrorRetryView(
                  message: friendlyApiError(error),
                  onRetry: () => ref.invalidate(dashboardConfigProvider),
                ),
              ],
            ),
            data: (rows) => ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: rows.length,
              itemBuilder: (context, index) => DashboardScrollerView(
                key: ValueKey(rows[index].id ?? '$index'),
                scroller: rows[index],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// AppBar action for the Home tab, alongside Settings — the title itself is
/// now a persistent search bar ([HomeSearchBar]) rather than this, so this
/// only needs to be an icon. With more than one library, shows a menu to
/// re-scope the Recently Added and Discover rows to a specific library (or
/// back to "All Libraries") in place; with exactly one library there's nothing to switch
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
