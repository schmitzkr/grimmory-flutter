import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/book_cover.dart';
import 'playback_provider.dart';
import 'sleep_timer.dart';

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
    final nowPlaying = ref.watch(nowPlayingProvider);
    if (nowPlaying == null) return const SizedBox.shrink();

    final mediaItem = nowPlaying.mediaItem;
    final playing = nowPlaying.playing;
    final bookId = nowPlaying.bookId;
    final handler = ref.read(audioHandlerProvider);
    final sleepRemaining = ref.watch(sleepTimerProvider);
    final durationMs = mediaItem.duration?.inMilliseconds ?? 0;

    return Material(
      elevation: 4,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: () => context.push('/player'),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // A hairline of progress along the top edge — the bar used to
              // give no sense of position at all.
              StreamBuilder<Duration>(
                stream: AudioService.position,
                builder: (context, snapshot) {
                  final pos = snapshot.data?.inMilliseconds ?? 0;
                  return LinearProgressIndicator(
                    value: durationMs > 0
                        ? (pos / durationMs).clamp(0.0, 1.0)
                        : 0,
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                  );
                },
              ),
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    if (bookId != null)
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: BookCover(
                            bookId: bookId,
                            fileType: 'AUDIOBOOK',
                          ),
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
                    if (sleepRemaining != null)
                      Tooltip(
                        message:
                            'Sleep timer: ${sleepRemaining.inMinutes + 1} min left',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bedtime,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${sleepRemaining.inMinutes + 1}m',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    IconButton(
                      tooltip: 'Forward 30 seconds',
                      icon: const Icon(Icons.forward_30),
                      onPressed: handler.fastForward,
                    ),
                    IconButton(
                      tooltip: playing ? 'Pause' : 'Play',
                      icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                      onPressed: playing ? handler.pause : handler.play,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
