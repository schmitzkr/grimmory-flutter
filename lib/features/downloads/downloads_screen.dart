import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/book_cover.dart';
import '../../core/widgets/empty_state.dart';
import '../player/mini_player.dart';
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
/// while browsing. Each row opens the book, so this is also the way to a
/// downloaded audiobook when the server is unreachable.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadManagerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: AsyncValueView(
        value: downloads,
        errorMessage: 'Could not load downloads.',
        onRetry: () => ref.invalidate(downloadManagerProvider),
        data: (records) {
          final items = records.values.toList()
            ..sort((a, b) => a.title.compareTo(b.title));
          if (items.isEmpty) {
            return const EmptyState(
              'No downloads yet.\n\nDownload an audiobook from its page to '
              'listen without a connection.',
            );
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
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}

/// App-bar shortcut to the downloads, with a count badge while there are
/// any — one tap from Home instead of Settings → Downloads.
class DownloadsAction extends ConsumerWidget {
  const DownloadsAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(downloadManagerProvider).value?.length ?? 0;
    return IconButton(
      tooltip: count == 0
          ? 'Downloads'
          : 'Downloads ($count ${count == 1 ? 'book' : 'books'})',
      icon: count == 0
          ? const Icon(Icons.download_outlined)
          : Badge.count(count: count, child: const Icon(Icons.download_done)),
      onPressed: () => context.push('/downloads'),
    );
  }
}

/// Confirms removing a finished download — the one tap used to delete a
/// multi-GB file with no way back but re-downloading. True to proceed.
Future<bool> confirmRemoveDownload(
  BuildContext context,
  DownloadRecord record,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remove download?'),
      content: Text(
        'This removes the ${formatBytes(record.totalBytes)} copy of '
        '"${record.title}" from this device. You can download it again later.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  return result ?? false;
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
      DownloadStatus.complete => [
        if (record.authors.isNotEmpty) record.authors.join(', '),
        formatBytes(record.totalBytes),
      ].join(' · '),
      DownloadStatus.failed =>
        record.error != null ? 'Failed: ${record.error}' : 'Failed',
    };
    final downloading = record.status == DownloadStatus.downloading;

    return ListTile(
      leading: SizedBox(
        width: 44,
        height: 44,
        child: BookCover(bookId: record.bookId, fileType: 'AUDIOBOOK'),
      ),
      title: Text(record.title),
      subtitle: downloading
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(value: record.progress),
            )
          : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () => context.push('/books/${record.bookId}'),
      trailing: IconButton(
        tooltip: downloading ? 'Cancel download' : 'Remove download',
        icon: Icon(downloading ? Icons.close : Icons.delete_outline),
        onPressed: () async {
          if (downloading) {
            await notifier.cancel(record.bookId);
            return;
          }
          if (record.status == DownloadStatus.complete &&
              !await confirmRemoveDownload(context, record)) {
            return;
          }
          await notifier.delete(record.bookId);
        },
      ),
    );
  }
}
