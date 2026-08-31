import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/utils/duration_format.dart';
import '../player/playback_provider.dart';

final bookmarksProvider = FutureProvider.family<List<Bookmark>, int>((
  ref,
  bookId,
) async {
  return ref.read(apiClientProvider).getBookmarks(bookId);
});

Future<void> showBookmarksSheet(
  BuildContext context,
  WidgetRef ref,
  int bookId,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _BookmarksSheet(bookId: bookId),
  );
}

class _BookmarksSheet extends ConsumerWidget {
  const _BookmarksSheet({required this.bookId});

  final int bookId;

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
              onTap: () async {
                final handler = ref.read(audioHandlerProvider);
                try {
                  await handler.createBookmarkAtCurrentPosition();
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
                  if (bookmarks.isEmpty) {
                    return const Center(child: Text('No bookmarks yet.'));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: bookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = bookmarks[index];
                      final positionMs = bookmark.positionMs;
                      final hasTitle = bookmark.title?.isNotEmpty == true;
                      final positionLabel = positionMs != null
                          ? formatDuration(Duration(milliseconds: positionMs))
                          : null;
                      return ListTile(
                        leading: const Icon(Icons.bookmark),
                        title: Text(
                          hasTitle ? bookmark.title! : positionLabel ?? 'Bookmark',
                        ),
                        subtitle: hasTitle && positionLabel != null
                            ? Text(positionLabel)
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await ref
                                .read(apiClientProvider)
                                .deleteBookmark(bookmark.id);
                            ref.invalidate(bookmarksProvider(bookId));
                          },
                        ),
                        onTap: positionMs == null
                            ? null
                            : () {
                                ref
                                    .read(audioHandlerProvider)
                                    .seekToChapterStart(positionMs);
                                Navigator.of(context).pop();
                              },
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
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
