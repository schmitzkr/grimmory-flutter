import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/downloads/download_manager.dart';
import '../../features/downloads/download_models.dart';
import '../api/models.dart';
import 'book_cover.dart';

/// The 2-column cover-grid layout shared by library detail, series detail,
/// and search results. [shrinkWrap]/[physics] default to plain
/// `GridView.builder` behavior (an independently-scrolling, unbounded-height
/// grid) — pass `shrinkWrap: true` and a non-scrolling [physics] when
/// nesting this inside another scrollable (e.g. the search bar's
/// suggestions view), so it sizes to its own content instead of demanding
/// infinite height.
class BookGrid extends StatelessWidget {
  const BookGrid({
    required this.books,
    this.shrinkWrap = false,
    this.physics,
    super.key,
  });

  final List<Book> books;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) => BookGridTile(book: books[index]),
    );
  }
}

class BookGridTile extends ConsumerWidget {
  const BookGridTile({required this.book, super.key});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloaded =
        ref.watch(downloadManagerProvider).value?[book.id]?.status ==
        DownloadStatus.complete;

    final normalizedProgress = book.normalizedReadProgress;
    final semanticLabel = book.authors.isEmpty
        ? book.title
        : '${book.title} by ${book.authors.join(', ')}';

    return Semantics(
      label: semanticLabel,
      button: true,
      child: InkWell(
        onTap: () => context.push('/books/${book.id}'),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: BookCover(
                        bookId: book.id,
                        fileType: book.primaryFileType,
                        coverVersion: book.coverVersion,
                      ),
                    ),
                    // Matches Grimmory's own web UI's top-left overlay stack
                    // (book-type-pill-overlay + series-number-overlay in
                    // book-card.component.html/.scss) — a format pill and a
                    // "#N" series-order badge, the one piece of cover overlay
                    // info that's actually about where a book sits when
                    // sorted by series.
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (book.primaryFileType != null)
                            _FormatPill(fileType: book.primaryFileType!),
                          if (book.seriesNumber != null) ...[
                            const SizedBox(height: 4),
                            _SeriesNumberBadge(
                              seriesNumber: book.seriesNumber!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (book.readStatus == 'READ')
                      Positioned(
                        left: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 14,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    else if ((normalizedProgress ?? 0) > 0 &&
                        (normalizedProgress ?? 0) < 1)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          child: LinearProgressIndicator(
                            value: normalizedProgress,
                            minHeight: 4,
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                      ),
                    if (downloaded)
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.download_done,
                            size: 14,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (book.authors.isNotEmpty)
              Text(
                book.authors.join(', '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

/// A small colored badge showing the book's file format (EPUB, AUDIOBOOK,
/// etc.) — mirrors Grimmory web's `book-type-pill-overlay`, including its
/// per-format color theming.
class _FormatPill extends StatelessWidget {
  const _FormatPill({required this.fileType});

  final String fileType;

  // Matches Grimmory's own web UI's per-format pill colors exactly (its
  // `.book-type-*` classes in book-card.component.scss, backed by Tailwind
  // v4's default palette via compat.scss's `--book-type-*-color` tokens) —
  // confirmed by reading both files directly rather than picking arbitrary
  // colors. Text is always white there too (`color: var(--color-white)`).
  static const _colors = {
    'EPUB': Color(0xFF16A34A), // green-600
    'PDF': Color(0xFFDC2626), // red-600
    'CBX': Color(0xFF3B82F6), // blue-500
    'FB2': Color(0xFFEC4899), // pink-500
    'MOBI': Color(0xFF6366F1), // indigo-500
    'AZW3': Color(0xFF14B8A6), // teal-500
    'AUDIOBOOK': Color(0xFFEAB308), // yellow-500
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[fileType] ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        fileType,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: MediaQuery.textScalerOf(context).scale(9),
          letterSpacing: 0.3,
        ),
        textScaler: TextScaler.noScaling,
      ),
    );
  }
}

/// "#N" badge showing where a book falls in its series — mirrors Grimmory
/// web's `series-number-overlay`. Drops a trailing `.0` for whole numbers
/// (e.g. "#3" not "#3.0"); a fractional entry (a novella between books 3
/// and 4) still shows as e.g. "#3.5".
class _SeriesNumberBadge extends StatelessWidget {
  const _SeriesNumberBadge({required this.seriesNumber});

  final double seriesNumber;

  @override
  Widget build(BuildContext context) {
    final label = seriesNumber == seriesNumber.roundToDouble()
        ? seriesNumber.toInt().toString()
        : seriesNumber.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        '#$label',
        style: TextStyle(
          color: Colors.white,
          fontSize: MediaQuery.textScalerOf(context).scale(10),
          fontWeight: FontWeight.w500,
        ),
        textScaler: TextScaler.noScaling,
      ),
    );
  }
}
