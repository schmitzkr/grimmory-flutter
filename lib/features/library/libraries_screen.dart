import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';

final librariesProvider = FutureProvider<List<Library>>((ref) async {
  return ref.read(apiClientProvider).getLibraries();
});

/// Post-login landing screen. Series/search/book-detail screens are later
/// milestones (see the project plan, M1) — this covers the libraries list
/// only for now.
class LibrariesScreen extends ConsumerWidget {
  const LibrariesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraries = ref.watch(librariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Libraries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: libraries.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No libraries found.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(librariesProvider.future),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final library = items[index];
                return ListTile(
                  leading: const Icon(Icons.headphones),
                  title: Text(library.name),
                  subtitle: library.type != null ? Text(library.type!) : null,
                  onTap: () {
                    // Library detail screen (browsing books within a
                    // library) is a later milestone.
                  },
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
      ),
    );
  }
}
