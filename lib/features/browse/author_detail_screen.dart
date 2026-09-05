import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/book_list_screen.dart';

final authorDetailProvider = FutureProvider.autoDispose.family<Author, int>((
  ref,
  authorId,
) async {
  return ref.read(apiClientProvider).getAuthorDetail(authorId);
});

final authorBooksProvider = FutureProvider.autoDispose
    .family<List<Book>, String>((ref, authorName) async {
      return ref.read(apiClientProvider).getBooksByAuthor(authorName);
    });

class AuthorDetailScreen extends ConsumerWidget {
  const AuthorDetailScreen({required this.authorId, super.key});

  final int authorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final author = ref.watch(authorDetailProvider(authorId));

    if (author case AsyncData(value: final detail)) {
      return BookListScreen(
        title: detail.name,
        provider: authorBooksProvider(detail.name),
        emptyMessage: 'No books by this author.',
        header: detail.description?.isNotEmpty == true
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(detail.description!),
              )
            : null,
      );
    }
    return Scaffold(
      appBar: AppBar(),
      body: AsyncValueView(
        value: author,
        onRetry: () => ref.invalidate(authorDetailProvider(authorId)),
        data: (_) => const SizedBox.shrink(),
      ),
    );
  }
}
