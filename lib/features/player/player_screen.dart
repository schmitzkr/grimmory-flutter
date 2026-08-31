import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final mediaItemAsync = ref.watch(currentMediaItemProvider);
    final playbackStateAsync = ref.watch(playbackStateProvider);
    final queueAsync = ref.watch(queueProvider);
    final chaptersAsync = ref.watch(chaptersProvider);
    final handler = ref.read(audioHandlerProvider);

    final mediaItem = mediaItemAsync.value;
    final playbackState = playbackStateAsync.value;
    final queue = queueAsync.value ?? [];
    final chapters = chaptersAsync.value ?? [];

    if (mediaItem == null) {
      return const Scaffold(body: Center(child: Text('Nothing playing.')));
    }

    final bookId = mediaItem.extras?['bookId'] as int?;
    // Folder-based books have one queue entry per track; a single-stream
    // book's queue always has exactly one entry (see
    // GrimmoryAudioHandler._loadSource) — chapters, when present, apply to
    // that case instead.
    final isFolderBased = queue.length > 1;
    final playing = playbackState?.playing ?? false;
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
                child: BookCover(bookId: bookId),
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
          StreamBuilder<Duration>(
            stream: AudioService.position,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = mediaItem.duration ?? Duration.zero;
              return Column(
                children: [
                  Slider(
                    value: duration.inMilliseconds > 0
                        ? position.inMilliseconds
                              .clamp(0, duration.inMilliseconds)
                              .toDouble()
                        : 0,
                    max: duration.inMilliseconds > 0
                        ? duration.inMilliseconds.toDouble()
                        : 1,
                    onChanged: (value) {},
                    onChangeEnd: (value) =>
                        handler.seek(Duration(milliseconds: value.round())),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatDuration(position)),
                        Text(formatDuration(duration)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
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
                  iconSize: 64,
                  icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
                  onPressed: playing ? handler.pause : handler.play,
                ),
              IconButton(
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
                onTap: () => handler.seekToChapterStart(chapter.startTimeMs),
              ),
          ],
        ],
      ),
    );
  }
}

