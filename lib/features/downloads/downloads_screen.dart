import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'download_manager.dart';
import 'download_models.dart';

String formatBytes(int bytes) {
  if (bytes >= 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / 1024).toStringAsFixed(0)} KB';
}

/// Every downloaded (or in-progress/failed) book in one place — the answer
/// to "what if I have several downloaded": a single list with a total
/// storage figure, rather than only being able to spot them one at a time
/// while browsing.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadManagerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: downloads.when(
        data: (records) {
          final items = records.values.toList()
            ..sort((a, b) => a.title.compareTo(b.title));
          if (items.isEmpty) {
            return const Center(child: Text('No downloads yet.'));
          }
          final totalBytes = ref
              .read(downloadManagerProvider.notifier)
              .totalStorageBytes();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${items.length} ${items.length == 1 ? 'book' : 'books'} · ${formatBytes(totalBytes)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _DownloadTile(record: items[index]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            const Center(child: Text('Could not load downloads.')),
      ),
    );
  }
}

class _DownloadTile extends ConsumerWidget {
  const _DownloadTile({required this.record});

  final DownloadRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(downloadManagerProvider.notifier);
    final subtitle = switch (record.status) {
      DownloadStatus.queued => 'Queued',
      DownloadStatus.downloading =>
        'Downloading… ${(record.progress * 100).round()}%',
      DownloadStatus.complete => formatBytes(record.totalBytes),
      DownloadStatus.failed =>
        record.error != null ? 'Failed: ${record.error}' : 'Failed',
    };

    return ListTile(
      leading: const Icon(Icons.menu_book_outlined),
      title: Text(record.title),
      subtitle: record.status == DownloadStatus.downloading
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(value: record.progress),
            )
          : Text(subtitle),
      trailing: IconButton(
        icon: Icon(
          record.status == DownloadStatus.downloading
              ? Icons.close
              : Icons.delete_outline,
        ),
        onPressed: () => record.status == DownloadStatus.downloading
            ? notifier.cancel(record.bookId)
            : notifier.delete(record.bookId),
      ),
    );
  }
}
