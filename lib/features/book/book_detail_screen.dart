import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/utils/duration_format.dart';
import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/book_cover.dart';
import '../bookmarks/epub_bookmarks_sheet.dart';
import '../browse/authors_screen.dart' show authorsListProvider;
import '../downloads/download_manager.dart';
import '../downloads/download_models.dart';
import '../library/progress_refresh.dart';
import '../onboarding/server_url_provider.dart';
import '../player/mini_player.dart';
import '../player/playback_provider.dart';
import '../reader/epub_reader_args.dart';
import 'book_text.dart';

/// autoDispose: a book's detail (progress, read status, files) changes
/// behind the app's back — on the web, from another device — so it's
/// refetched on every visit rather than cached for the process lifetime.
final bookProvider = FutureProvider.autoDispose.family<Book, int>((
  ref,
  bookId,
) async {
  return ref.read(apiClientProvider).getBook(bookId);
});

/// Only fetched for audiobooks — `/audiobooks/{bookId}/info` 404s for any
/// other format, which used to be called unconditionally here regardless
/// of book type, breaking (silently, with no feedback) whenever a library
/// mixed audiobooks with ebooks/comics.
final audiobookInfoProvider = FutureProvider.autoDispose
    .family<AudiobookInfo, int>((ref, bookId) async {
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
        actions: [
          if (book.value case final loaded?)
            PopupMenuButton<_DetailAction>(
              tooltip: 'More',
              onSelected: (action) => switch (action) {
                _DetailAction.status => _showReadStatusSheet(
                  context,
                  ref,
                  loaded,
                ),
                _DetailAction.rate => _showRatingSheet(context, ref, loaded),
                _DetailAction.openWeb => _openOnWeb(context, ref, loaded),
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _DetailAction.status,
                  child: ListTile(
                    leading: Icon(Icons.flag_outlined),
                    title: Text('Set read status'),
                  ),
                ),
                PopupMenuItem(
                  value: _DetailAction.rate,
                  child: ListTile(
                    leading: Icon(Icons.star_outline),
                    title: Text('Rate this book'),
                  ),
                ),
                PopupMenuItem(
                  value: _DetailAction.openWeb,
                  child: ListTile(
                    leading: Icon(Icons.open_in_browser),
                    title: Text('Open on the web'),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: AsyncValueView(
        value: book,
        onRetry: () => ref.invalidate(bookProvider(bookId)),
        data: (book) => _BookDetailBody(book: book),
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
    final isComic = book.primaryFileType == 'CBX';
    final isPdf = book.primaryFileType == 'PDF';
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
            child: BookCover(
              bookId: book.id,
              fileType: book.primaryFileType,
              coverVersion: book.coverVersion,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          book.title,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        if (book.subtitle?.isNotEmpty ?? false)
          Text(
            book.subtitle!,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        if (book.authors.isNotEmpty) _AuthorLinks(names: book.authors),
        if (narrator != null)
          Text(
            'Narrated by $narrator',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        if (book.seriesName != null)
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                textStyle: Theme.of(context).textTheme.bodySmall,
              ),
              onPressed: () => context.push(
                '/series/${Uri.encodeComponent(book.seriesName!)}',
              ),
              icon: const Icon(Icons.collections_bookmark_outlined, size: 16),
              label: Text(
                book.seriesNumber == null
                    ? book.seriesName!
                    : '${book.seriesName!} · Book ${_formatSeriesNumber(book.seriesNumber!)}',
              ),
            ),
          ),
        if ((book.personalRating ?? 0) > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _Stars(rating: book.personalRating!, size: 18),
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
          _ReadingProgress(book: book),
          FilledButton.icon(
            onPressed: () => context.push('/books/${book.id}/read'),
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
                extra: EpubReaderArgs(jumpToCfi: cfi),
              ),
            ),
            icon: const Icon(Icons.bookmark_border),
            label: const Text('Bookmarks'),
          ),
        ] else if (isComic) ...[
          _ReadingProgress(book: book),
          FilledButton.icon(
            onPressed: () => context.push('/books/${book.id}/comic'),
            icon: const Icon(Icons.auto_stories_outlined),
            label: Text(
              (book.normalizedReadProgress ?? 0) > 0
                  ? 'Continue Reading'
                  : 'Start Reading',
            ),
          ),
        ] else if (isPdf) ...[
          _ReadingProgress(book: book),
          FilledButton.icon(
            onPressed: () => context.push('/books/${book.id}/pdf'),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(
              (book.normalizedReadProgress ?? 0) > 0
                  ? 'Continue Reading'
                  : 'Start Reading',
            ),
          ),
        ] else ...[
          Text(
            book.primaryFileType == null
                ? 'This book has no readable file.'
                : "Reading ${book.primaryFileType} books isn't supported in this app yet.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openOnWeb(context, ref, book),
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Open on the web'),
          ),
        ],
        _AboutSection(book: book),
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
                      trailing: Text(
                        formatDurationShort(
                          Duration(milliseconds: track.durationMs),
                        ),
                      ),
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
                      trailing: Text(
                        formatDurationShort(
                          Duration(milliseconds: chapter.durationMs),
                        ),
                      ),
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

enum _DetailAction { status, rate, openWeb }

String _formatSeriesNumber(double n) =>
    n == n.roundToDouble() ? n.toInt().toString() : n.toString();

/// The book's authors as links into their author screens. The detail DTO
/// carries names only, so ids come from the authors list (already loaded
/// whenever the Authors tab has been visited, fetched otherwise); a name
/// the list doesn't know stays plain text.
class _AuthorLinks extends ConsumerWidget {
  const _AuthorLinks({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authors = ref.watch(authorsListProvider).value ?? const [];
    final style = Theme.of(context).textTheme.titleMedium;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < names.length; i++) ...[
          if (i > 0) Text(', ', style: style),
          switch (authors.where((a) => a.name == names[i]).firstOrNull) {
            final match? => InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => context.push('/authors/${match.id}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: Text(
                  names[i],
                  style: style?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            null => Text(names[i], style: style),
          },
        ],
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, this.size = 20});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Semantics(
      label: 'Your rating: $rating of 5',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 1; i <= 5; i++)
              Icon(
                i <= rating ? Icons.star : Icons.star_border,
                size: size,
                color: color,
              ),
          ],
        ),
      ),
    );
  }
}

/// Description (collapsed to a few lines with "Read more"), a compact
/// metadata line, and category chips — what the web's book page shows
/// under the cover, and what a reader needs to decide whether to start.
class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = book.description == null
        ? ''
        : plainText(book.description!);
    final facts = <String>[
      if (book.pageCount != null) '${book.pageCount} pages',
      ?publishedYear(book.publishedDate),
      if (book.publisher?.isNotEmpty ?? false) book.publisher!,
      if (book.language?.isNotEmpty ?? false) book.language!.toUpperCase(),
      if (book.libraryName?.isNotEmpty ?? false) book.libraryName!,
    ];
    if (description.isEmpty && facts.isEmpty && book.categories.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        if (description.isNotEmpty) ...[
          _ExpandableText(description),
          const SizedBox(height: 12),
        ],
        if (facts.isNotEmpty)
          Text(
            facts.join(' · '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        if (book.categories.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: -6,
            children: [
              for (final c in book.categories)
                Chip(
                  label: Text(c),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide.none,
                  backgroundColor: theme.colorScheme.surfaceContainerHigh,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText(this.text);

  final String text;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: 6,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: style,
              maxLines: _expanded ? null : 6,
              overflow: _expanded ? null : TextOverflow.ellipsis,
            ),
            if (overflows)
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? 'Show less' : 'Read more'),
              ),
          ],
        );
      },
    );
  }
}

Future<void> _showReadStatusSheet(
  BuildContext context,
  WidgetRef ref,
  Book book,
) async {
  final chosen = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Read status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final entry in manualReadStatuses.entries)
            ListTile(
              leading: Icon(
                entry.key == book.readStatus
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text(entry.value),
              onTap: () => Navigator.of(context).pop(entry.key),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (chosen == null || chosen == book.readStatus || !context.mounted) return;
  await _mutate(
    context,
    ref,
    book.id,
    () => ref.read(apiClientProvider).updateReadStatus(book.id, chosen),
    success: 'Marked as ${readStatusLabel(chosen).toLowerCase()}',
    failure: 'Could not update read status',
  );
}

Future<void> _showRatingSheet(
  BuildContext context,
  WidgetRef ref,
  Book book,
) async {
  final chosen = await showModalBottomSheet<int>(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rate this book',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    tooltip: '$i star${i == 1 ? '' : 's'}',
                    iconSize: 36,
                    icon: Icon(
                      i <= (book.personalRating ?? 0)
                          ? Icons.star
                          : Icons.star_border,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => Navigator.of(context).pop(i),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
  if (chosen == null || !context.mounted) return;
  await _mutate(
    context,
    ref,
    book.id,
    () => ref.read(apiClientProvider).updatePersonalRating(book.id, chosen),
    success: 'Rated $chosen of 5',
    failure: 'Could not save rating',
  );
}

/// Runs a detail-screen mutation, then refreshes every screen showing this
/// book (the same set the readers refresh on exit) and reports the result.
Future<void> _mutate(
  BuildContext context,
  WidgetRef ref,
  int bookId,
  Future<void> Function() action, {
  required String success,
  required String failure,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context, listen: false);
  try {
    await action();
    refreshProgressConsumers(container, bookId: bookId);
    messenger.showSnackBar(SnackBar(content: Text(success)));
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('$failure: ${friendlyApiError(e)}')),
    );
  }
}

/// The web's page for this book — the way out for anything the app cannot
/// do itself (unsupported formats, metadata editing).
Future<void> _openOnWeb(BuildContext context, WidgetRef ref, Book book) async {
  final serverUrl = ref.read(serverUrlProvider);
  if (serverUrl == null) return;
  final ok = await launchUrl(
    Uri.parse('$serverUrl/book/${book.id}'),
    mode: LaunchMode.externalApplication,
  );
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Could not open a browser.')));
  }
}

/// "Finished" / "N% read" + bar — the same block for every format that
/// reports a 0-100 `readProgress` (EPUB, comics, PDFs).
class _ReadingProgress extends StatelessWidget {
  const _ReadingProgress({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    if (book.readStatus == 'READ') {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text('Finished'),
      );
    }
    final progress = book.normalizedReadProgress ?? 0;
    if (progress <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Text('${(progress * 100).round()}% read'),
          const SizedBox(height: 6),
          SizedBox(width: 160, child: LinearProgressIndicator(value: progress)),
        ],
      ),
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
