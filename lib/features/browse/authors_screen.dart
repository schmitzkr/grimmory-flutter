import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';

final authorsListProvider = FutureProvider<List<Author>>((ref) async {
  return ref.read(apiClientProvider).getAuthors();
});

/// Body of the "Authors" tab on [HomeScreen].
class AuthorsTab extends ConsumerWidget {
  const AuthorsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authors = ref.watch(authorsListProvider);

    return authors.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No authors found.'));
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(authorsListProvider.future),
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final author = items[index];
              return ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(author.name),
                subtitle: Text(
                  '${author.bookCount} ${author.bookCount == 1 ? 'book' : 'books'}',
                ),
                onTap: () => context.push('/authors/${author.id}'),
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
                onPressed: () => ref.invalidate(authorsListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
