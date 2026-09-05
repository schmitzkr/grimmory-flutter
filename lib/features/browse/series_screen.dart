import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/empty_state.dart';

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
              return ListTile(
                leading: const Icon(Icons.collections_bookmark_outlined),
                title: Text(s.seriesName),
                subtitle: Text(
                  '${s.bookCount} ${s.bookCount == 1 ? 'book' : 'books'}',
                ),
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
