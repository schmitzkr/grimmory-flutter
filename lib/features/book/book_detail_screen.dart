import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_cover.dart';
import '../bookmarks/epub_bookmarks_sheet.dart';
import '../downloads/download_manager.dart';
import '../downloads/download_models.dart';
import '../player/mini_player.dart';
import '../player/playback_provider.dart';
import '../reader/epub_reader_args.dart';

final bookProvider = FutureProvider.family<Book, int>((ref, bookId) async {
  return ref.read(apiClientProvider).getBook(bookId);
});

/// Only fetched for audiobooks — `/audiobooks/{bookId}/info` 404s for any
/// other format, which used to be called unconditionally here regardless
/// of book type, breaking (silently, with no feedback) whenever a library
/// mixed audiobooks with ebooks/comics.
final audiobookInfoProvider = FutureProvider.family<AudiobookInfo, int>((
  ref,
  bookId,
) async {
  return ref.read(apiClientProvider).getAudiobookInfo(bookId);
});

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({required this.bookId, super.key});

  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookProvider(bookId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          book.value?.primaryFileType == 'AUDIOBOOK' ? 'Audiobook' : 'Book',
        ),
      ),
      body: book.when(
        data: (book) => _BookDetailBody(book: book),
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
                  onPressed: () => ref.invalidate(bookProvider(bookId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}

class _BookDetailBody extends ConsumerWidget {
  const _BookDetailBody({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAudiobook = book.primaryFileType == 'AUDIOBOOK';
    final isEpub = book.primaryFileType == 'EPUB';
    final audiobookInfo = isAudiobook
        ? ref.watch(audiobookInfoProvider(book.id))
        : null;
    final narrator = audiobookInfo?.value?.narrator ?? book.narrator;

    // Whether *this* book is the one currently loaded in the audio handler —
    // without this, the Play button always says "Play" even while this
    // exact book is already playing, with nothing on the page indicating
    // it's the one making sound.
    final currentMediaItem = ref.watch(currentMediaItemProvider).value;
    final isCurrentBook =
        isAudiobook && currentMediaItem?.extras?['bookId'] == book.id;
    final isPlaying =
        isCurrentBook &&
        (ref.watch(playbackStateProvider).value?.playing ?? false);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: BookCover(bookId: book.id, fileType: book.primaryFileType),
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
        if (isAudiobook) ...[
          if (isCurrentBook)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.graphic_eq,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPlaying ? 'Now playing' : 'Paused',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          FilledButton.icon(
            onPressed: () {
              final handler = ref.read(audioHandlerProvider);
              if (isCurrentBook) {
                // Already loaded -- just toggle in place rather than
                // reissuing playFromMediaId(), which would reload the
                // source from scratch.
                isPlaying ? handler.pause() : handler.play();
              } else {
                // Fire-and-forget: navigate immediately rather than
                // blocking the tap on the full load (fetch metadata, build
                // the audio source, start playing) — the player screen
                // reflects loading/now-playing state reactively via the
                // audio handler's own streams.
                handler.playFromMediaId(book.id.toString());
                context.push('/player');
              }
            },
            icon: Icon(
              isCurrentBook
                  ? (isPlaying ? Icons.pause : Icons.play_arrow)
                  : Icons.play_arrow,
            ),
            label: Text(
              isCurrentBook ? (isPlaying ? 'Pause' : 'Resume') : 'Play',
            ),
          ),
          const SizedBox(height: 8),
          _DownloadButton(book: book),
        ] else if (isEpub) ...[
          if (book.readStatus == 'READ')
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Finished'),
            )
          else if ((book.normalizedReadProgress ?? 0) > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  Text('${(book.normalizedReadProgress! * 100).round()}% read'),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 160,
                    child: LinearProgressIndicator(
                      value: book.normalizedReadProgress,
                    ),
                  ),
                ],
              ),
            ),
          FilledButton.icon(
            onPressed: () => context.push(
              '/books/${book.id}/read',
              extra: EpubReaderArgs(title: book.title),
            ),
            icon: const Icon(Icons.menu_book),
            label: Text(
              (book.normalizedReadProgress ?? 0) > 0
                  ? 'Continue Reading'
                  : 'Start Reading',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => showEpubBookmarksSheet(
              context,
              ref,
              bookId: book.id,
              currentCfi: null,
              onJumpTo: (cfi) => context.push(
                '/books/${book.id}/read',
                extra: EpubReaderArgs(title: book.title, jumpToCfi: cfi),
              ),
            ),
            icon: const Icon(Icons.bookmark_border),
            label: const Text('Bookmarks'),
          ),
        ] else ...[
          Text(
            book.primaryFileType == null
                ? 'This book has no readable file.'
                : "Reading ${book.primaryFileType} books isn't supported in this app yet.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        if (isAudiobook)
          audiobookInfo!.when(
            data: (info) => Column(
              children: [
                if (info.folderBased && info.tracks.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Tracks',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
            ),
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(friendlyApiError(error), textAlign: TextAlign.center),
            ),
          ),
      ],
    );
  }
}

class _DownloadButton extends ConsumerWidget {
  const _DownloadButton({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuilds whenever the download registry changes for any book, not
    // just this one, but that's a small in-memory map — cheap either way.
    ref.watch(downloadManagerProvider);
    final notifier = ref.read(downloadManagerProvider.notifier);
    final record = notifier.recordFor(book.id);

    switch (record?.status) {
      case null:
        return OutlinedButton.icon(
          onPressed: () => notifier.download(book),
          icon: const Icon(Icons.download_outlined),
          label: const Text('Download for offline'),
        );
      case DownloadStatus.queued:
      case DownloadStatus.downloading:
        return Column(
          children: [
            LinearProgressIndicator(value: record!.progress),
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: () => notifier.cancel(book.id),
              icon: const Icon(Icons.close),
              label: const Text('Cancel download'),
            ),
          ],
        );
      case DownloadStatus.complete:
        return OutlinedButton.icon(
          onPressed: () => notifier.delete(book.id),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Downloaded — remove'),
        );
      case DownloadStatus.failed:
        return OutlinedButton.icon(
          onPressed: () => notifier.download(book),
          icon: const Icon(Icons.refresh),
          label: const Text('Download failed — retry'),
        );
    }
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
