import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/errors.dart';
import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/empty_state.dart';
import '../auth/current_user_provider.dart';
import 'continue_listening_section.dart';
import 'continue_reading_section.dart';
import 'dashboard.dart';
import 'libraries_provider.dart';
import 'library_detail_screen.dart' show LibraryBooksView;
import 'recently_added_section.dart';

/// Body of the Home tab on [HomeScreen] — the AppBar/BottomNavigationBar
/// live on the shell, not here. Modelled on Grimmory's web dashboard: the
/// user's own row layout from their account settings (or the web's
/// defaults — Continue Listening, Continue Reading, Recently Added,
/// Discover Something New), each row a titled horizontal strip with the
/// web's per-row empty/error text, spanning every library the account can
/// see, as on the web. Browsing one library is the [LibrariesTab]'s job.
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraries = ref.watch(librariesProvider);

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
                ref.refresh(recentlyAddedProvider(null).future),
                ref.refresh(discoverBooksProvider(null).future),
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

/// The Libraries tab: every library the account can see, each opening its
/// full, paginated, sort/filterable contents (`LibraryDetailScreen`). With
/// exactly one library there is nothing to choose between, so the tab *is*
/// that library — its name as a header over [LibraryBooksView] — instead of
/// a one-row list that only adds a tap. This replaces the Home tab's old
/// app-bar library filter — browsing a single library is its own
/// destination now, rather than a scope applied to the dashboard rows.
class LibrariesTab extends ConsumerWidget {
  const LibrariesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraries = ref.watch(librariesProvider);

    return AsyncValueView(
      value: libraries,
      onRetry: () => ref.invalidate(librariesProvider),
      data: (items) {
        if (items.isEmpty) return const EmptyState('No libraries found.');
        if (items.length == 1) {
          final library = items.single;
          return LibraryBooksView(
            key: ValueKey(library.id),
            libraryId: library.id,
            header: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.local_library_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      library.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(librariesProvider.future),
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final library = items[index];
              return ListTile(
                leading: const Icon(Icons.local_library_outlined),
                title: Text(library.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/libraries/${library.id}'),
              );
            },
          ),
        );
      },
    );
  }
}
