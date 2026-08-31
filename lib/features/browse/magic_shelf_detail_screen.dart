import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_grid.dart';

final magicShelfBooksProvider = FutureProvider.family<List<Book>, int>((
  ref,
  magicShelfId,
) async {
  return ref.read(apiClientProvider).getMagicShelfBooks(magicShelfId);
});

class MagicShelfDetailScreen extends ConsumerWidget {
  const MagicShelfDetailScreen({
    required this.magicShelfId,
    required this.title,
    super.key,
  });

  final int magicShelfId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(magicShelfBooksProvider(magicShelfId));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: books.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No audiobooks on this shelf.'));
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(magicShelfBooksProvider(magicShelfId).future),
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
                      ref.invalidate(magicShelfBooksProvider(magicShelfId)),
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
