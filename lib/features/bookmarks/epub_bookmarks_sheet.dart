import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'bookmarks_sheet.dart';

/// EPUB bookmarks over the shared [BookmarksSheet]. [currentCfi] is the
/// reader's last-known position (from `onRelocated`, tracked by
/// `EpubReaderScreen`) — null only in the brief window before the first
/// relocation callback fires, which disables "Add bookmark" rather than
/// falling back to a stale/default position. Only CFI-based rows are shown:
/// a book's bookmarks are always one shape in practice (its format doesn't
/// change), but filtering keeps this robust rather than assuming.
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
    builder: (context) => BookmarksSheet(
      bookId: bookId,
      canAdd: currentCfi != null,
      onAdd: (ref) =>
          ref.read(apiClientProvider).createBookmark(bookId, cfi: currentCfi!),
      include: (bookmark) => bookmark.cfi != null,
      rowTitle: (bookmark, index) => bookmark.title?.isNotEmpty == true
          ? bookmark.title!
          : 'Bookmark ${index + 1}',
      onTap: (ref, bookmark) {
        onJumpTo(bookmark.cfi!);
        return true;
      },
    ),
  );
}
