import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// A book/audiobook cover, fetched with auth headers since Grimmory's cover
/// endpoint requires the same bearer auth as everything else.
class BookCover extends ConsumerWidget {
  const BookCover({
    required this.bookId,
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.fileType,
    this.coverVersion,
  });

  final int bookId;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  /// [Book.primaryFileType] — picks the fallback icon shown while no cover
  /// art is available. `null` (or anything other than `'AUDIOBOOK'`) gets
  /// the generic book icon rather than headphones, since this widget used
  /// to show headphones unconditionally even for EPUBs.
  final String? fileType;

  /// `Book.coverVersion` — appended to the URL so a regenerated cover
  /// actually replaces the cached one instead of the old image being served
  /// from the image cache forever.
  final String? coverVersion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiClient = ref.watch(apiClientProvider);

    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: apiClient.coverUrl(bookId, version: coverVersion),
        httpHeaders: apiClient.authHeaders,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => _placeholder(context),
        // Not every book has an audiobook-specific cover generated yet —
        // fall back to the general book cover before giving up, same order
        // Grimmory's own frontend uses (UrlHelperService).
        errorWidget: (context, url, error) => CachedNetworkImage(
          imageUrl: apiClient.fallbackCoverUrl(bookId, version: coverVersion),
          httpHeaders: apiClient.authHeaders,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) => _placeholder(context),
          errorWidget: (context, url, error) => _placeholder(context),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Icon(
      fileType == 'AUDIOBOOK' ? Icons.headphones : Icons.menu_book,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}
