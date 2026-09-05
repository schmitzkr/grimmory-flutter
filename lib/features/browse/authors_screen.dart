import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/empty_state.dart';

final authorsListProvider = FutureProvider<List<Author>>((ref) async {
  return ref.read(apiClientProvider).getAuthors();
});

/// Body of the "Authors" tab on [HomeScreen].
class AuthorsTab extends ConsumerWidget {
  const AuthorsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authors = ref.watch(authorsListProvider);
    final apiClient = ref.watch(apiClientProvider);

    return AsyncValueView(
      value: authors,
      onRetry: () => ref.invalidate(authorsListProvider),
      data: (items) {
        if (items.isEmpty) return const EmptyState('No authors found.');
        return RefreshIndicator(
          onRefresh: () => ref.refresh(authorsListProvider.future),
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final author = items[index];
              return ListTile(
                // The photo endpoint 404s for an author without one, so
                // only ask for it when the summary says it exists.
                leading: author.hasPhoto
                    ? CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          apiClient.authorPhotoUrl(author.id),
                          headers: apiClient.authHeaders,
                        ),
                      )
                    : const CircleAvatar(child: Icon(Icons.person_outline)),
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
    );
  }
}
