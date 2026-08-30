import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';

final seriesListProvider = FutureProvider<List<Series>>((ref) async {
  return ref.read(apiClientProvider).getSeries();
});

/// Body of the "Series" tab on [HomeScreen].
class SeriesTab extends ConsumerWidget {
  const SeriesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesListProvider);

    return series.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No series found.'));
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(seriesListProvider.future),
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final s = items[index];
              return ListTile(
                leading: const Icon(Icons.collections_bookmark_outlined),
                title: Text(s.name),
                subtitle: Text(
                  '${s.bookCount} ${s.bookCount == 1 ? 'book' : 'books'}',
                ),
                onTap: () =>
                    context.push('/series/${Uri.encodeComponent(s.name)}'),
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
                onPressed: () => ref.invalidate(seriesListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
