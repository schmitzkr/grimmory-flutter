import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/models.dart';
import '../../core/utils/duration_format.dart';
import '../../core/widgets/book_cover.dart';
import '../../core/widgets/sheet_header.dart';
import '../bookmarks/bookmarks_sheet.dart';
import 'playback_provider.dart';
import 'sleep_timer.dart';

// Preset speeds offered in the speed sheet — same range most audiobook
// apps expose; the slider covers the space between them.
const _speedSteps = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0];

String _formatSpeed(double speed) {
  final s = speed.toStringAsFixed(2);
  return s.endsWith('0') ? speed.toStringAsFixed(1) : s;
}

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
    final sleepRemaining = ref.watch(sleepTimerProvider);

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
          // A running timer shows as a filled icon with the minutes left,
          // so falling asleep to silence is never a mystery.
          IconButton(
            tooltip: sleepRemaining == null
                ? 'Sleep timer'
                : 'Sleep timer: ${formatDuration(sleepRemaining)} left',
            icon: sleepRemaining == null
                ? const Icon(Icons.bedtime_outlined)
                : Badge(
                    label: Text('${sleepRemaining.inMinutes + 1}m'),
                    child: const Icon(Icons.bedtime),
                  ),
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
          if (!isFolderBased && chapters.isNotEmpty)
            _CurrentChapterLabel(chapters: chapters),
          if (sleepRemaining != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Sleeps in ${formatDuration(sleepRemaining)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
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
                iconSize: 28,
                icon: const Icon(Icons.skip_previous),
                onPressed: queue.length > 1 ? handler.skipToPrevious : null,
              ),
              IconButton(
                tooltip: 'Back 30 seconds',
                iconSize: 36,
                icon: const Icon(Icons.replay_30),
                onPressed: handler.rewind,
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
                tooltip: 'Forward 30 seconds',
                iconSize: 36,
                icon: const Icon(Icons.forward_30),
                onPressed: handler.fastForward,
              ),
              IconButton(
                tooltip: 'Next track',
                iconSize: 28,
                icon: const Icon(Icons.skip_next),
                onPressed: queue.length > 1 ? handler.skipToNext : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => _showSpeedSheet(context),
              icon: const Icon(Icons.speed),
              label: Text('${_formatSpeed(speed)}× speed'),
            ),
          ),
          if (isFolderBased) ...[
            const Divider(height: 32),
            Text('Tracks', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _CurrentAwareList(
              currentIndex: playbackState?.queueIndex ?? 0,
              itemCount: queue.length,
              itemBuilder: (context, i, isCurrent) => ListTile(
                contentPadding: EdgeInsets.zero,
                selected: isCurrent,
                leading: Icon(isCurrent ? Icons.play_arrow : null),
                title: Text(queue[i].displaySubtitle ?? queue[i].title),
                trailing: queue[i].duration != null
                    ? Text(formatDuration(queue[i].duration!))
                    : null,
                onTap: () => handler.seekToTrack(i),
              ),
            ),
          ] else if (chapters.isNotEmpty) ...[
            const Divider(height: 32),
            Text('Chapters', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            StreamBuilder<Duration>(
              stream: AudioService.position,
              builder: (context, snapshot) {
                final current = currentChapterIndex(
                  chapters,
                  snapshot.data?.inMilliseconds ?? 0,
                );
                return _CurrentAwareList(
                  currentIndex: current,
                  itemCount: chapters.length,
                  itemBuilder: (context, i, isCurrent) {
                    final chapter = chapters[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      selected: isCurrent,
                      leading: isCurrent
                          ? const Icon(Icons.play_arrow)
                          : Text('${chapter.index + 1}'),
                      title: Text(chapter.title),
                      trailing: Text(
                        formatDuration(
                          Duration(milliseconds: chapter.durationMs),
                        ),
                      ),
                      onTap: () =>
                          handler.seekToBookPosition(chapter.startTimeMs),
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showSpeedSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const _SpeedSheet(),
    );
  }
}

/// The chapter that contains a book-wide position: the last one whose
/// start is at or before it (−1 when the list is empty).
int currentChapterIndex(List<AudiobookChapter> chapters, int positionMs) {
  var current = -1;
  for (var i = 0; i < chapters.length; i++) {
    if (chapters[i].startTimeMs <= positionMs) current = i;
  }
  return current < 0 && chapters.isNotEmpty ? 0 : current;
}

/// "Chapter 4 · The Long Dark" under the title, live with the position.
class _CurrentChapterLabel extends StatelessWidget {
  const _CurrentChapterLabel({required this.chapters});

  final List<AudiobookChapter> chapters;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: AudioService.position,
      builder: (context, snapshot) {
        final i = currentChapterIndex(
          chapters,
          snapshot.data?.inMilliseconds ?? 0,
        );
        if (i < 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Chapter ${chapters[i].index + 1} · ${chapters[i].title}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}

/// A list of tiles that highlights [currentIndex] and, once, scrolls the
/// enclosing scroll view so that tile is visible when the screen opens.
class _CurrentAwareList extends StatefulWidget {
  const _CurrentAwareList({
    required this.currentIndex,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int currentIndex;
  final int itemCount;
  final Widget Function(BuildContext context, int index, bool isCurrent)
  itemBuilder;

  @override
  State<_CurrentAwareList> createState() => _CurrentAwareListState();
}

class _CurrentAwareListState extends State<_CurrentAwareList> {
  final _currentKey = GlobalKey();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
  }

  void _scrollToCurrent() {
    if (_scrolled || !mounted) return;
    final ctx = _currentKey.currentContext;
    if (ctx == null) return;
    _scrolled = true;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.3,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < widget.itemCount; i++)
          KeyedSubtree(
            key: i == widget.currentIndex ? _currentKey : null,
            child: widget.itemBuilder(context, i, i == widget.currentIndex),
          ),
      ],
    );
  }
}

/// Presets plus a slider, reflecting the live speed — replacing a single
/// button that could only cycle forward through eight steps.
class _SpeedSheet extends ConsumerWidget {
  const _SpeedSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handler = ref.read(audioHandlerProvider);
    final speed = ref.watch(playbackStateProvider).value?.speed ?? 1.0;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHeader('Playback speed'),
          Text(
            '${_formatSpeed(speed)}×',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Slider(
            value: speed.clamp(0.5, 3.0),
            min: 0.5,
            max: 3.0,
            divisions: 25,
            label: '${_formatSpeed(speed)}×',
            onChanged: (v) => handler.setSpeed((v * 20).round() / 20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                for (final preset in _speedSteps)
                  ChoiceChip(
                    label: Text('${_formatSpeed(preset)}×'),
                    selected: (preset - speed).abs() < 0.01,
                    onSelected: (_) => handler.setSpeed(preset),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
