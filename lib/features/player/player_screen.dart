import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/models.dart';
import '../../core/utils/duration_format.dart';
import '../../core/widgets/book_cover.dart';
import '../bookmarks/bookmarks_sheet.dart';
import 'playback_provider.dart';
import 'sleep_timer.dart';

// Cycles through these on tap — same range most audiobook apps expose.
const _speedSteps = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0];

/// Reflects whatever the audio handler is currently doing — there's no
/// bookId parameter, since navigation here always follows a
/// playFromMediaId() call from book_detail_screen.dart's Play button.
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlaying = ref.watch(nowPlayingProvider);
    final queue = ref.watch(queueProvider).value ?? [];
    final chapters = ref.watch(chaptersProvider).value ?? [];
    final handler = ref.read(audioHandlerProvider);

    if (nowPlaying == null) {
      // Reached when playback stopped under an open player, or from a
      // restored /player route — it needs a real app bar (back) and a way
      // to something useful, not a bare sentence.
      return Scaffold(
        appBar: AppBar(title: const Text('Now Playing')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.headphones_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              const Text('Nothing playing.'),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => context.go('/libraries'),
                child: const Text('Browse your library'),
              ),
            ],
          ),
        ),
      );
    }

    final mediaItem = nowPlaying.mediaItem;
    final playbackState = nowPlaying.state;
    final bookId = nowPlaying.bookId;
    // Folder-based books have one queue entry per track; a single-stream
    // book's queue always has exactly one entry (see
    // GrimmoryAudioHandler._loadSource) — chapters, when present, apply to
    // that case instead.
    final isFolderBased = queue.length > 1;
    final playing = nowPlaying.playing;
    final processingState =
        playbackState?.processingState ?? AudioProcessingState.idle;
    final isBuffering =
        processingState == AudioProcessingState.loading ||
        processingState == AudioProcessingState.buffering;
    final speed = playbackState?.speed ?? 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          if (bookId != null)
            IconButton(
              tooltip: 'Bookmarks',
              icon: const Icon(Icons.bookmark_border),
              onPressed: () => showBookmarksSheet(context, ref, bookId),
            ),
          IconButton(
            tooltip: 'Sleep timer',
            icon: const Icon(Icons.bedtime_outlined),
            onPressed: () => showSleepTimerSheet(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (bookId != null)
            Center(
              child: SizedBox(
                width: 240,
                height: 240,
                // No Book object here, just a bare id -- but the player
                // only ever plays audiobooks, so this is always accurate.
                child: BookCover(bookId: bookId, fileType: 'AUDIOBOOK'),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            mediaItem.title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (mediaItem.artist != null)
            Text(
              mediaItem.artist!,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          if (mediaItem.displaySubtitle != null)
            Text(
              mediaItem.displaySubtitle!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 24),
          _PositionSlider(
            duration: mediaItem.duration ?? Duration.zero,
            onSeek: handler.seek,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: 'Previous track',
                iconSize: 32,
                icon: const Icon(Icons.skip_previous),
                onPressed: queue.length > 1 ? handler.skipToPrevious : null,
              ),
              if (isBuffering)
                const SizedBox(
                  width: 64,
                  height: 64,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                IconButton(
                  tooltip: playing ? 'Pause' : 'Play',
                  iconSize: 64,
                  icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
                  onPressed: playing ? handler.pause : handler.play,
                ),
              IconButton(
                tooltip: 'Next track',
                iconSize: 32,
                icon: const Icon(Icons.skip_next),
                onPressed: queue.length > 1 ? handler.skipToNext : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                final currentIndex = _speedSteps.indexWhere(
                  (s) => (s - speed).abs() < 0.01,
                );
                final next =
                    _speedSteps[(currentIndex + 1) % _speedSteps.length];
                handler.setSpeed(next);
              },
              child: Text('${speed.toStringAsFixed(2)}x speed'),
            ),
          ),
          if (isFolderBased) ...[
            const Divider(height: 32),
            Text('Tracks', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (var i = 0; i < queue.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  i == (playbackState?.queueIndex ?? 0)
                      ? Icons.play_arrow
                      : null,
                ),
                title: Text(queue[i].displaySubtitle ?? queue[i].title),
                trailing: queue[i].duration != null
                    ? Text(formatDuration(queue[i].duration!))
                    : null,
                onTap: () => handler.seekToTrack(i),
              ),
          ] else if (chapters.isNotEmpty) ...[
            const Divider(height: 32),
            Text('Chapters', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final AudiobookChapter chapter in chapters)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text('${chapter.index + 1}'),
                title: Text(chapter.title),
                trailing: Text(
                  formatDuration(Duration(milliseconds: chapter.durationMs)),
                ),
                onTap: () => handler.seekToBookPosition(chapter.startTimeMs),
              ),
          ],
        ],
      ),
    );
  }
}

/// Follows the live position until the thumb is grabbed, then follows the
/// thumb — otherwise every position tick snaps it back mid-drag and the
/// slider looks stuck.
class _PositionSlider extends StatefulWidget {
  const _PositionSlider({required this.duration, required this.onSeek});

  final Duration duration;
  final Future<void> Function(Duration) onSeek;

  @override
  State<_PositionSlider> createState() => _PositionSliderState();
}

class _PositionSliderState extends State<_PositionSlider> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final maxMs = widget.duration.inMilliseconds;
    return StreamBuilder<Duration>(
      stream: AudioService.position,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final liveMs = maxMs > 0
            ? position.inMilliseconds.clamp(0, maxMs).toDouble()
            : 0.0;
        final shownMs = _dragValue ?? liveMs;
        return Column(
          children: [
            Slider(
              value: shownMs,
              max: maxMs > 0 ? maxMs.toDouble() : 1,
              onChanged: maxMs > 0
                  ? (value) => setState(() => _dragValue = value)
                  : null,
              onChangeEnd: (value) {
                setState(() => _dragValue = null);
                widget.onSeek(Duration(milliseconds: value.round()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDuration(Duration(milliseconds: shownMs.round()))),
                  Text(formatDuration(widget.duration)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
