import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/downloads/download_manager.dart';
import '../../features/downloads/download_models.dart';
import '../api/models.dart';
import 'book_cover.dart';

/// The 2-column cover-grid layout shared by library detail, series detail,
/// and search results.
class BookGrid extends StatelessWidget {
  const BookGrid({required this.books, super.key});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
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

    // `readProgress` isn't on a consistent scale across book types: this
    // app computes and sends audiobook progress client-side as a genuine
    // 0.0-1.0 fraction (positionMs / durationMs), but everything else
    // (confirmed for EPUB against the real server/web-frontend source) is
    // stored and returned on a 0-100 scale. Normalize to a 0.0-1.0 fraction
    // here rather than at the model level, since this is the only place
    // that renders it.
    final normalizedProgress = book.primaryFileType == 'AUDIOBOOK'
        ? book.readProgress
        : book.readProgress != null
        ? book.readProgress! / 100
        : null;

    return InkWell(
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
                          backgroundColor: Colors.black.withValues(alpha: 0.35),
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
    );
  }
}
