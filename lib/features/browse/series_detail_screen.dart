import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_grid.dart';

final seriesBooksProvider = FutureProvider.family<List<Book>, String>((
  ref,
  seriesName,
) async {
  return ref.read(apiClientProvider).getSeriesBooks(seriesName);
});

class SeriesDetailScreen extends ConsumerWidget {
  const SeriesDetailScreen({required this.seriesName, super.key});

  final String seriesName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(seriesBooksProvider(seriesName));

    return Scaffold(
      appBar: AppBar(title: Text(seriesName)),
      body: books.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No audiobooks in this series.'));
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(seriesBooksProvider(seriesName).future),
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
                      ref.invalidate(seriesBooksProvider(seriesName)),
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
