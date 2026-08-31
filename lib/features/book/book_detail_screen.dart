import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_cover.dart';
import '../player/playback_provider.dart';

final bookDetailProvider = FutureProvider.family<(Book, AudiobookInfo), int>(
  (ref, bookId) async {
    final apiClient = ref.read(apiClientProvider);
    final results = await Future.wait([
      apiClient.getBook(bookId),
      apiClient.getAudiobookInfo(bookId),
    ]);
    return (results[0] as Book, results[1] as AudiobookInfo);
  },
);

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({required this.bookId, super.key});

  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(bookDetailProvider(bookId));

    return Scaffold(
      appBar: AppBar(title: const Text('Audiobook')),
      body: detail.when(
        data: (data) {
          final (book, info) = data;
          final narrator = info.narrator ?? book.narrator;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: BookCover(bookId: bookId),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                book.title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (book.authors.isNotEmpty)
                Text(
                  book.authors.join(', '),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              if (narrator != null)
                Text(
                  'Narrated by $narrator',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              if (book.seriesName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    book.seriesName!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  // Fire-and-forget: navigate immediately rather than
                  // blocking the tap on the full load (fetch metadata,
                  // build the audio source, start playing) — the player
                  // screen reflects loading/now-playing state reactively
                  // via the audio handler's own streams.
                  ref
                      .read(audioHandlerProvider)
                      .playFromMediaId(bookId.toString());
                  context.push('/player');
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play'),
              ),
              if (info.folderBased && info.tracks.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Tracks', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final track in info.tracks)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text('${track.index + 1}'),
                    title: Text(track.title),
                    trailing: Text(_formatDurationMs(track.durationMs)),
                  ),
              ] else if (info.chapters.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Chapters',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final chapter in info.chapters)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text('${chapter.index + 1}'),
                    title: Text(chapter.title),
                    trailing: Text(_formatDurationMs(chapter.durationMs)),
                  ),
              ],
            ],
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
                  onPressed: () => ref.invalidate(bookDetailProvider(bookId)),
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

String _formatDurationMs(int ms) {
  final duration = Duration(milliseconds: ms);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  return '${minutes}m';
}
