import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'bookmarks_sheet.dart' show bookmarksProvider;

/// [currentCfi] is the reader's last-known position (from `onRelocated`,
/// tracked by `EpubReaderScreen`) — null only in the brief window before the
/// first relocation callback fires, which disables "Add bookmark" rather
/// than falling back to a stale/default position.
Future<void> showEpubBookmarksSheet(
  BuildContext context,
  WidgetRef ref, {
  required int bookId,
  required String? currentCfi,
  required ValueChanged<String> onJumpTo,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _EpubBookmarksSheet(
      bookId: bookId,
      currentCfi: currentCfi,
      onJumpTo: onJumpTo,
    ),
  );
}

class _EpubBookmarksSheet extends ConsumerWidget {
  const _EpubBookmarksSheet({
    required this.bookId,
    required this.currentCfi,
    required this.onJumpTo,
  });

  final int bookId;
  final String? currentCfi;
  final ValueChanged<String> onJumpTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider(bookId));

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Bookmarks', style: TextStyle(fontSize: 18)),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add bookmark at current position'),
              enabled: currentCfi != null,
              onTap: currentCfi == null
                  ? null
                  : () async {
                      final cfi = currentCfi!;
                      try {
                        await ref
                            .read(apiClientProvider)
                            .createBookmark(bookId, cfi: cfi);
                        ref.invalidate(bookmarksProvider(bookId));
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not create bookmark.'),
                            ),
                          );
                        }
                      }
                    },
            ),
            const Divider(height: 1),
            Expanded(
              child: bookmarksAsync.when(
                data: (bookmarks) {
                  // Only cfi-based rows apply to an EPUB reader — a book's
                  // bookmarks are always one shape in practice (its format
                  // doesn't change), but filtering keeps this robust rather
                  // than assuming.
                  final epubBookmarks = bookmarks
                      .where((b) => b.cfi != null)
                      .toList();
                  if (epubBookmarks.isEmpty) {
                    return const Center(child: Text('No bookmarks yet.'));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: epubBookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = epubBookmarks[index];
                      final hasTitle = bookmark.title?.isNotEmpty == true;
                      return ListTile(
                        leading: const Icon(Icons.bookmark),
                        title: Text(
                          hasTitle ? bookmark.title! : 'Bookmark ${index + 1}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await ref
                                .read(apiClientProvider)
                                .deleteBookmark(bookmark.id);
                            ref.invalidate(bookmarksProvider(bookId));
                          },
                        ),
                        onTap: () {
                          onJumpTo(bookmark.cfi!);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    const Center(child: Text('Could not load bookmarks.')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
