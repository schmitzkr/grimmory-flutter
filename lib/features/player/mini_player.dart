import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/book_cover.dart';
import 'playback_provider.dart';

/// Persistent "now playing" bar — without this, playback continues in the
/// background after navigating away from [PlayerScreen] (correct: it's a
/// real foreground service) but nothing in the app itself shows what's
/// playing or lets you control it short of going back to /player by hand,
/// and there's no indication on a book's own detail page that it's the one
/// currently playing. Meant to sit in every screen's `bottomNavigationBar`
/// slot (renders nothing when nothing is loaded, so it's a no-op to include
/// unconditionally) — see HomeScreen for the one case that also has a real
/// bottom nav bar to stack above.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaItem = ref.watch(currentMediaItemProvider).value;
    if (mediaItem == null) return const SizedBox.shrink();

    final playbackState = ref.watch(playbackStateProvider).value;
    final playing = playbackState?.playing ?? false;
    final handler = ref.read(audioHandlerProvider);
    final bookId = mediaItem.extras?['bookId'] as int?;

    return Material(
      elevation: 4,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: () => context.push('/player'),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                if (bookId != null)
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: BookCover(bookId: bookId, fileType: 'AUDIOBOOK'),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mediaItem.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (mediaItem.artist != null)
                          Text(
                            mediaItem.artist!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                  onPressed: playing ? handler.pause : handler.play,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
