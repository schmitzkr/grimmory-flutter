import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_grid.dart';

final libraryBooksProvider = FutureProvider.family<List<Book>, int>((
  ref,
  libraryId,
) async {
  return ref.read(apiClientProvider).getLibraryBooks(libraryId);
});

class LibraryDetailScreen extends ConsumerWidget {
  const LibraryDetailScreen({required this.libraryId, super.key});

  final int libraryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(libraryBooksProvider(libraryId));

    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: books.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No audiobooks in this library.'));
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(libraryBooksProvider(libraryId).future),
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
                  onPressed: () =>
                      ref.invalidate(libraryBooksProvider(libraryId)),
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
