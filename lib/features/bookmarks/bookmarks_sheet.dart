import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/utils/duration_format.dart';
import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/empty_state.dart';
import '../player/playback_provider.dart';
import '../../core/widgets/sheet_header.dart';

/// autoDispose: bookmarks are edited from the web too, so each sheet opens
/// on a fresh list instead of whatever this process fetched first.
final bookmarksProvider = FutureProvider.autoDispose
    .family<List<Bookmark>, int>((ref, bookId) async {
      return ref.read(apiClientProvider).getBookmarks(bookId);
    });

/// Audiobook bookmarks: adding captures the player's current position, and
/// tapping one seeks the player there.
Future<void> showBookmarksSheet(
  BuildContext context,
  WidgetRef ref,
  int bookId,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => BookmarksSheet(
      bookId: bookId,
      canAdd: true,
      onAdd: (ref) =>
          ref.read(audioHandlerProvider).createBookmarkAtCurrentPosition(),
      include: (bookmark) => true,
      rowTitle: (bookmark, index) {
        if (bookmark.title?.isNotEmpty == true) return bookmark.title!;
        final positionMs = bookmark.positionMs;
        return positionMs == null
            ? 'Bookmark'
            : formatDuration(Duration(milliseconds: positionMs));
      },
      rowSubtitle: (bookmark) {
        final positionMs = bookmark.positionMs;
        if (bookmark.title?.isNotEmpty != true || positionMs == null) {
          return null;
        }
        return formatDuration(Duration(milliseconds: positionMs));
      },
      onTap: (ref, bookmark) {
        final positionMs = bookmark.positionMs;
        if (positionMs == null) return false;
        ref.read(audioHandlerProvider).seekToBookPosition(positionMs);
        return true;
      },
    ),
  );
}

/// One bottom sheet for both bookmark flavours — the audio and EPUB sheets
/// were the same header, add row, list and delete with different row
/// labels and tap targets. [onTap] returns whether it handled the tap (the
/// sheet then closes); [include] filters rows that don't apply (an EPUB
/// reader only wants CFI-based ones).
class BookmarksSheet extends ConsumerWidget {
  const BookmarksSheet({
    required this.bookId,
    required this.canAdd,
    required this.onAdd,
    required this.include,
    required this.rowTitle,
    required this.onTap,
    this.rowSubtitle,
    super.key,
  });

  final int bookId;
  final bool canAdd;
  final Future<void> Function(WidgetRef ref) onAdd;
  final bool Function(Bookmark bookmark) include;
  final String Function(Bookmark bookmark, int index) rowTitle;
  final String? Function(Bookmark bookmark)? rowSubtitle;
  final bool Function(WidgetRef ref, Bookmark bookmark) onTap;

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
            const SheetHeader('Bookmarks'),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add bookmark at current position'),
              enabled: canAdd,
              onTap: !canAdd
                  ? null
                  : () => _run(
                      context,
                      ref,
                      () => onAdd(ref),
                      failure: 'Could not create bookmark.',
                    ),
            ),
            const Divider(height: 1),
            Expanded(
              child: AsyncValueView(
                value: bookmarksAsync,
                errorMessage: 'Could not load bookmarks.',
                onRetry: () => ref.invalidate(bookmarksProvider(bookId)),
                data: (all) {
                  final bookmarks = all.where(include).toList();
                  if (bookmarks.isEmpty) {
                    return const EmptyState('No bookmarks yet.');
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: bookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = bookmarks[index];
                      final subtitle = rowSubtitle?.call(bookmark);
                      return ListTile(
                        leading: const Icon(Icons.bookmark),
                        title: Text(rowTitle(bookmark, index)),
                        subtitle: subtitle == null ? null : Text(subtitle),
                        trailing: IconButton(
                          tooltip: 'Delete bookmark',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _run(
                            context,
                            ref,
                            () => ref
                                .read(apiClientProvider)
                                .deleteBookmark(bookmark.id),
                            failure: 'Could not delete bookmark.',
                          ),
                        ),
                        onTap: () {
                          if (onTap(ref, bookmark)) Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Runs a mutation, refreshes the list on success, and reports failure
  /// in a snackbar — create and delete used to differ here, with delete
  /// letting its error escape as an unhandled exception.
  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action, {
    required String failure,
  }) async {
    try {
      await action();
      ref.invalidate(bookmarksProvider(bookId));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure)));
      }
    }
  }
}
