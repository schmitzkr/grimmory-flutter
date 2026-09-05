import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/player/mini_player.dart';
import '../api/models.dart';
import 'async_value_view.dart';
import 'book_grid.dart';
import 'empty_state.dart';

/// "AppBar + book grid + pull-to-refresh + mini player" over one
/// `FutureProvider<List<Book>>` — series, author and magic-shelf detail are
/// all exactly this screen with a different provider and empty-state copy.
/// [header] sits above the grid (an author's description).
class BookListScreen extends ConsumerWidget {
  const BookListScreen({
    required this.title,
    required this.provider,
    required this.emptyMessage,
    this.header,
    super.key,
  });

  final String title;
  final FutureProvider<List<Book>> provider;
  final String emptyMessage;
  final Widget? header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          ?header,
          Expanded(
            child: AsyncValueView(
              value: books,
              onRetry: () => ref.invalidate(provider),
              data: (items) {
                if (items.isEmpty) return EmptyState(emptyMessage);
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(provider.future),
                  child: BookGrid(books: items),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
