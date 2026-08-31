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
  });

  final int bookId;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiClient = ref.watch(apiClientProvider);

    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: apiClient.coverUrl(bookId),
        httpHeaders: apiClient.authHeaders,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => _placeholder(context),
        errorWidget: (context, url, error) => _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Icon(
      Icons.headphones,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}
