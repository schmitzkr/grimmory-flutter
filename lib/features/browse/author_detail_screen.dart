import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_grid.dart';
import '../player/mini_player.dart';

final authorDetailProvider = FutureProvider.family<Author, int>((
  ref,
  authorId,
) async {
  return ref.read(apiClientProvider).getAuthorDetail(authorId);
});

final authorBooksProvider = FutureProvider.family<List<Book>, String>((
  ref,
  authorName,
) async {
  return ref.read(apiClientProvider).getBooksByAuthor(authorName);
});

class AuthorDetailScreen extends ConsumerWidget {
  const AuthorDetailScreen({required this.authorId, super.key});

  final int authorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final author = ref.watch(authorDetailProvider(authorId));

    return author.when(
      data: (detail) => _AuthorBooks(detail: detail),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(friendlyApiError(error)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(authorDetailProvider(authorId)),
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

class _AuthorBooks extends ConsumerWidget {
  const _AuthorBooks({required this.detail});

  final Author detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(authorBooksProvider(detail.name));

    return Scaffold(
      appBar: AppBar(title: Text(detail.name)),
      body: Column(
        children: [
          if (detail.description?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(detail.description!),
            ),
          Expanded(
            child: books.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text('No audiobooks by this author.'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(authorBooksProvider(detail.name).future),
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
                            ref.invalidate(authorBooksProvider(detail.name)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
