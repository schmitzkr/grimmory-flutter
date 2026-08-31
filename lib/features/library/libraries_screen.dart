import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import 'continue_listening_section.dart';

final librariesProvider = FutureProvider<List<Library>>((ref) async {
  return ref.read(apiClientProvider).getLibraries();
});

/// Body of the "Libraries" tab on [HomeScreen] — the AppBar/BottomNavigationBar
/// live on the shell, not here.
class LibrariesTab extends ConsumerWidget {
  const LibrariesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraries = ref.watch(librariesProvider);

    return libraries.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No libraries found.'));
        }
        return RefreshIndicator(
          onRefresh: () => Future.wait([
            ref.refresh(librariesProvider.future),
            ref.refresh(continueListeningProvider.future),
          ]),
          child: ListView.builder(
            // Index 0 is the Continue Listening header/carousel; library
            // tiles follow at items[index - 1].
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return const ContinueListeningSection();
              final library = items[index - 1];
              return ListTile(
                leading: const Icon(Icons.headphones),
                title: Text(library.name),
                subtitle: Text(
                  '${library.bookCount} ${library.bookCount == 1 ? 'book' : 'books'}',
                ),
                onTap: () => context.push('/libraries/${library.id}'),
              );
            },
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
