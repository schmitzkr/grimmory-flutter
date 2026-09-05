import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_list_screen.dart';
import 'shelves_screen.dart' show magicShelvesListProvider;

final magicShelfBooksProvider = FutureProvider.autoDispose
    .family<List<Book>, int>((ref, magicShelfId) async {
      return ref.read(apiClientProvider).getMagicShelfBooks(magicShelfId);
    });

/// The title comes from the shelves list (already loaded whenever this was
/// reached from the Shelves tab, fetched otherwise) rather than a route
/// `extra`, so a deep link or a restored route shows the real name too.
class MagicShelfDetailScreen extends ConsumerWidget {
  const MagicShelfDetailScreen({required this.magicShelfId, super.key});

  final int magicShelfId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref
        .watch(magicShelvesListProvider)
        .value
        ?.where((shelf) => shelf.id == magicShelfId)
        .firstOrNull
        ?.name;

    return BookListScreen(
      title: title ?? 'Shelf',
      provider: magicShelfBooksProvider(magicShelfId),
      emptyMessage: 'No books on this shelf.',
    );
  }
}
