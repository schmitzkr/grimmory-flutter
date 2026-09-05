import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/book_cover.dart';
import '../../core/widgets/empty_state.dart';

/// "9 books · 3 read", with "of 12" when metadata says the series is longer
/// than what the library holds — the same figures the web UI's series
/// cards show, straight off `AppSeriesSummary`.
String seriesSubtitle(Series s) {
  final books = '${s.bookCount} ${s.bookCount == 1 ? 'book' : 'books'}';
  final total = s.seriesTotal;
  final held = total != null && total > s.bookCount
      ? '$books of $total'
      : books;
  return s.booksRead > 0 ? '$held · ${s.booksRead} read' : held;
}

final seriesListProvider = FutureProvider<List<Series>>((ref) async {
  return ref.read(apiClientProvider).getSeries();
});

/// Body of the "Series" tab on [HomeScreen].
class SeriesTab extends ConsumerWidget {
  const SeriesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesListProvider);

    return AsyncValueView(
      value: series,
      onRetry: () => ref.invalidate(seriesListProvider),
      data: (items) {
        if (items.isEmpty) return const EmptyState('No series found.');
        return RefreshIndicator(
          onRefresh: () => ref.refresh(seriesListProvider.future),
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final s = items[index];
              final cover = s.coverBooks.isEmpty ? null : s.coverBooks.first;
              return ListTile(
                leading: cover == null
                    ? const SizedBox(
                        width: 40,
                        child: Icon(Icons.collections_bookmark_outlined),
                      )
                    : BookCover(
                        bookId: cover.bookId,
                        width: 40,
                        height: 56,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                        fileType: cover.primaryFileType,
                        coverVersion: cover.coverVersion,
                      ),
                title: Text(s.seriesName),
                subtitle: Text(seriesSubtitle(s)),
                onTap: () => context.push(
                  '/series/${Uri.encodeComponent(s.seriesName)}',
                ),
              );
            },
          ),
        );
      },
    );
  }
}
