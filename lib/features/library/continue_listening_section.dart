import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_grid.dart';

final continueListeningProvider = FutureProvider<List<Book>>((ref) async {
  return ref.read(apiClientProvider).getContinueListening();
});

/// A horizontal row of in-progress books at the top of the Libraries tab —
/// the phone-UI equivalent of the "Continue Listening" root Android Auto
/// already gets from the same [continueListeningProvider] endpoint via
/// GrimmoryAudioHandler.getChildren.
///
/// Renders nothing (not even an empty state) when there's nothing in
/// progress or the request fails — this is a bonus shortcut on top of the
/// Libraries tab, not something worth showing an error for.
class ContinueListeningSection extends ConsumerWidget {
  const ContinueListeningSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(continueListeningProvider).valueOrNull ?? [];
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Continue Listening',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: books.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 130,
                child: BookGridTile(book: books[index]),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
