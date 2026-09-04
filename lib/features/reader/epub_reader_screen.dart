import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../bookmarks/epub_bookmarks_sheet.dart';
import '../library/progress_refresh.dart';
import '../player/mini_player.dart';
import 'epub_gesture_overlay.dart';
import 'epub_spine_fractions.dart';

/// EPUB rendering is entirely client-side via `flutter_epub_viewer`
/// (WebView + epub.js), which parses a real local EPUB file directly —
/// so this downloads the book's raw file once per session rather than
/// using Grimmory's piecemeal spine/manifest/resource-file endpoints
/// (`/api/v1/epub/**`), which this package has no use for.
///
/// Loaded via `EpubSource.fromData` (raw bytes) rather than
/// `EpubSource.fromFile` — the latter's `File` parameter type comes from a
/// `dart.library.io` conditional export that the analyzer resolves to the
/// package's web stub even in this Android-only app, so a real `dart:io`
/// `File` fails static type-checking against it.
const _readerDarkModeKey = 'reader_dark_mode';

/// `EpubTheme.dark()`/`.light()`'s `backgroundDecoration`/`foregroundColor`
/// never actually reach the book's own CSS — `EpubViewer` always sends a
/// `null`/empty background to the underlying JS (`epub_viewer.dart`'s
/// `loadBook` call hardcodes `'backgroundColor': null`, and
/// `EpubController.updateTheme` hardcodes `''`), so those factories only
/// ever change text color, leaving light-mode-only page backgrounds behind
/// white (or worse, dark) text. Driving both background and link color
/// through `customCss` instead sidesteps that entirely — it's forwarded
/// unconditionally as raw epub.js theme rules (selector -> CSS properties).
final _lightEpubTheme = EpubTheme.custom(
  customCss: {
    'body': {'background': '#fafafa', 'color': '#1a1a1a'},
    'a, a:link, a:visited': {
      'color': '#1a56db',
      'text-decoration': 'underline',
    },
  },
);

final _darkEpubTheme = EpubTheme.custom(
  customCss: {
    'body': {'background': '#121212', 'color': '#e8e8e8'},
    'a, a:link, a:visited': {
      'color': '#8ab4f8',
      'text-decoration': 'underline',
    },
  },
);

class EpubReaderScreen extends ConsumerStatefulWidget {
  const EpubReaderScreen({
    required this.bookId,
    required this.title,
    this.jumpToCfi,
    super.key,
  });

  final int bookId;
  final String title;
  final String? jumpToCfi;

  @override
  ConsumerState<EpubReaderScreen> createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends ConsumerState<EpubReaderScreen> {
  final _controller = EpubController();
  Uint8List? _bytes;
  String? _initialCfi;
  // Updated on every onRelocated callback -- the reader's last-known
  // position, used as the target when adding a bookmark. Not rendered
  // directly, so plain field assignment (no setState) is enough.
  String? _currentCfi;
  // The highest percentage (0-100) confirmed for this book, seeded from the
  // server's own existing progress on load and updated as we go — a floor
  // no fresh save is allowed to regress below. See _persistProgress.
  double? _bestKnownPercentage;
  // The EPUB file's own id for file-level progress saves — see
  // ApiClient's progress section for why the bookId-only shim isn't
  // enough. Null (shim-only saves) if the detail fetch failed.
  int? _bookFileId;
  // Size-based fallback for the percentage while epub.js still reports 0
  // — see EpubSpineFractions and _percentageFor. Null if the file couldn't
  // be parsed, in which case saves rely on epub.js alone as before.
  EpubSpineFractions? _spine;
  // Set right before a progress save fails, read by the SnackBar it
  // triggers — see _persistProgress/_showSyncFailedSnackBar.
  String? _lastSyncError;
  List<EpubChapter> _chapters = [];
  Object? _error;
  // True from the moment a back gesture/press is accepted until the final
  // progress save lands and the screen pops — drives the saving overlay and
  // makes a second back press during that window a no-op.
  bool _isExiting = false;

  // Defaults to the system's current brightness so the reader doesn't open
  // looking inconsistent with the rest of the app; a persisted explicit
  // choice (below) overrides that once the user has picked one.
  late bool _isDark =
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPrefsProvider);
    if (prefs.containsKey(_readerDarkModeKey)) {
      _isDark = prefs.getBool(_readerDarkModeKey)!;
    }
    _load();
  }

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
    ref.read(sharedPrefsProvider).setBool(_readerDarkModeKey, _isDark);
    _controller.updateTheme(theme: _isDark ? _darkEpubTheme : _lightEpubTheme);
  }

  /// The one exit path: persist the live position, then refresh every
  /// screen showing this book's progress, then pop.
  ///
  /// The refresh used to live in `dispose()`, which is exactly where
  /// Riverpod 3 forbids it: every `WidgetRef` call runs
  /// `_assertNotDisposed()` and throws a `StateError` once the element is
  /// deactivated — silently, in a release build — so nothing was ever
  /// refreshed and the detail/home screens kept their stale progress until
  /// a manual pull-to-refresh. It runs here instead, while still mounted,
  /// through the container rather than `ref` so it doesn't care about this
  /// widget's lifecycle; see [refreshProgressConsumers] for why a plain
  /// `invalidate` of those (paused, off-stage) screens wasn't enough either.
  Future<void> _exit() async {
    if (_isExiting) return;
    setState(() => _isExiting = true);
    await _saveProgressBeforeExit();
    if (!mounted) return;
    refreshProgressConsumers(
      ProviderScope.containerOf(context, listen: false),
      bookId: widget.bookId,
    );
    Navigator.of(context).pop();
  }

  Future<void> _load() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/epub_${widget.bookId}.epub';
      await apiClient.downloadBookFile(widget.bookId, path);
      final bytes = await File(path).readAsBytes();
      // Off the UI isolate: this inflates the zip's central directory and
      // two small XML files, cheap but not free on a big book.
      final spine = await compute(EpubSpineFractions.parse, bytes);
      final progress = await apiClient.getEpubProgress(widget.bookId);
      int? bookFileId;
      try {
        bookFileId = (await apiClient.getBook(widget.bookId)).ebookFileId;
      } catch (_) {
        // Reading still works without it; saves just fall back to the shim.
      }

      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _initialCfi = widget.jumpToCfi ?? progress?.cfi;
        _bestKnownPercentage = progress?.percentage;
        _bookFileId = bookFileId;
        _spine = spine;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  void _saveProgress(EpubLocation location) {
    _currentCfi = location.startCfi;
    unawaited(
      _persistProgress(
        cfi: location.startCfi,
        percentage: _percentageFor(location),
      ).then((ok) {
        if (!ok) _showSyncFailedSnackBar();
      }),
    );
  }

  /// The 0-100 figure to save for [location]. epub.js's own fraction
  /// (`location.progress`, 0.0-1.0) is the precise one and wins whenever it
  /// has one — but it stays 0 until `book.locations.generate()` has
  /// finished *and* a relocate has fired since, which a short session never
  /// reaches, so those fell back to saving a hard 0 that left the book
  /// UNREAD server-side. The spine-size estimate covers exactly that gap.
  /// The server stores/interprets the percentage on a 0-100 scale
  /// (confirmed via the real web frontend, which does
  /// `goToFraction(progress.percentage / 100)` to convert it back).
  double _percentageFor(EpubLocation location) {
    if (location.progress > 0) return location.progress * 100;
    return _spine?.percentageAt(location.startCfi) ?? 0;
  }

  /// Returns whether the save actually succeeded — every caller used to
  /// swallow failures completely silently, which made a real, reported
  /// "progress never shows up" bug impossible to diagnose without server
  /// access. Reported failures now surface via [_showSyncFailedSnackBar]
  /// with the real API error (via [friendlyApiError]) instead.
  ///
  /// [percentage] is never actually sent below [_bestKnownPercentage]: a
  /// real reported bug was progress *disappearing* on a second read of the
  /// same book — epub.js's own percentage can come back as a stale,
  /// premature 0 before `book.locations.generate()` finishes (see
  /// [_saveProgressBeforeExit]'s own comment), and that shouldn't be
  /// allowed to overwrite real, already-recorded progress just because
  /// this particular reader session's locations map wasn't ready yet. The
  /// position ([cfi]) is always trusted fresh regardless — only the
  /// percentage figure has this floor.
  Future<bool> _persistProgress({
    required String cfi,
    required double percentage,
  }) async {
    final effectivePercentage = _bestKnownPercentage == null
        ? percentage
        : (percentage > _bestKnownPercentage!
              ? percentage
              : _bestKnownPercentage!);
    _bestKnownPercentage = effectivePercentage;
    try {
      await ref
          .read(apiClientProvider)
          .updateEpubProgress(
            widget.bookId,
            EpubProgress(cfi: cfi, percentage: effectivePercentage),
            bookFileId: _bookFileId,
          );
      return true;
    } catch (e) {
      _lastSyncError = friendlyApiError(e);
      return false;
    }
  }

  void _showSyncFailedSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not sync reading progress: ${_lastSyncError ?? 'unknown error'}',
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// `onRelocated` only fires after epub.js's own relocate event, which
  /// lags a little behind actually opening the book or turning a page — a
  /// real reported bug: open a book, read a page or two, back out quickly,
  /// and the position is lost because no relocate event had fired yet. This
  /// queries the live position on demand and awaits the save before letting
  /// the pop proceed, so leaving the reader always persists wherever you
  /// actually are, not just wherever the last passive event happened to be.
  Future<void> _saveProgressBeforeExit() async {
    if (_bytes == null) return;
    try {
      // epub.js's own `percentage` figure depends on `book.locations
      // .generate()` finishing in the background (it needs a pre-computed
      // locations map to know where a CFI falls as a fraction of the whole
      // book) — a fresh computation every time the reader opens, not
      // cached across sessions, and how long it takes scales with the
      // book's size. Confirmed via a live DB check that a quick "open,
      // read a page or two, back out" session was saving the exact right
      // CFI every time, but a hard 0 for percentage every time too —
      // because epub.js's cached location object is only recomputed on an
      // actual relocate event, and the very first one (right after
      // opening) fires before that background generation has had time to
      // finish; it then stays frozen at that stale value until something
      // re-triggers it. Re-displaying the last-known position forces a
      // fresh relocate each attempt; retrying with increasing delays
      // (rather than gambling on one fixed wait) keeps this working
      // across books of any size instead of just whichever one happened
      // to fit in a single guessed timeout.
      //
      // The first attempt is a plain read with no re-display and no wait:
      // once a session has been open long enough for a relocate to land
      // after location generation — i.e. nearly always, except that quick
      // open-and-back case — the cached figure is already real, and paying
      // the 400ms+ dance anyway is what made every back press feel laggy.
      final anchorCfi = _currentCfi ?? _initialCfi;
      var location = EpubLocation(
        startCfi: anchorCfi ?? '',
        endCfi: anchorCfi ?? '',
        progress: 0,
      );
      //
      // With a spine-size estimate available (the normal case), a 0 from
      // that first read is answered by the estimate instead, and the timed
      // retries are skipped entirely — they only still run for a file the
      // fallback couldn't parse.
      for (final delayMs in const [0, 400, 800, 1200]) {
        if (delayMs > 0) {
          if (anchorCfi != null) _controller.display(cfi: anchorCfi);
          await Future.delayed(Duration(milliseconds: delayMs));
        }
        location = await _controller.getCurrentLocation().timeout(
          const Duration(seconds: 3),
        );
        if (location.progress > 0) break;
        if (_spine?.percentageAt(location.startCfi) != null) break;
      }
      final ok = await _persistProgress(
        cfi: location.startCfi,
        percentage: _percentageFor(location),
      );
      if (!ok) {
        // The screen is about to be popped — briefly hold so the SnackBar
        // is actually visible before this Scaffold (and its
        // ScaffoldMessenger) disappears with it.
        _showSyncFailedSnackBar();
        await Future.delayed(const Duration(milliseconds: 1200));
      }
    } catch (_) {
      // getCurrentLocation() itself failed (e.g. epub.js never established
      // a location at all — happens if you back out before it settles even
      // once) — nothing to report, there's no position to have saved.
    }
  }

  void _showBookmarks(BuildContext context) {
    showEpubBookmarksSheet(
      context,
      ref,
      bookId: widget.bookId,
      currentCfi: _currentCfi,
      onJumpTo: (cfi) => _controller.display(cfi: cfi),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load this book.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    setState(() => _error = null);
                    _load();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_bytes == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: Icon(
                _isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              tooltip: _isDark
                  ? 'Switch to light theme'
                  : 'Switch to dark theme',
              onPressed: _toggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              tooltip: 'Bookmarks',
              onPressed: () => _showBookmarks(context),
            ),
            IconButton(
              icon: const Icon(Icons.menu_book_outlined),
              tooltip: 'Chapters',
              onPressed: _chapters.isEmpty
                  ? null
                  : () => _showChapters(context),
            ),
          ],
        ),
        body: Stack(
          children: [
            EpubGestureOverlay(
              onTapLeft: _controller.prev,
              onTapRight: _controller.next,
              onSwipeDown: () => _showBookmarks(context),
              onSwipeUp: _chapters.isEmpty
                  ? () {}
                  : () => _showChapters(context),
              child: EpubViewer(
                epubController: _controller,
                epubSource: EpubSource.fromData(_bytes!),
                initialCfi: _initialCfi,
                displaySettings: EpubDisplaySettings(
                  theme: _isDark ? _darkEpubTheme : _lightEpubTheme,
                ),
                onChaptersLoaded: (chapters) {
                  if (mounted) setState(() => _chapters = chapters);
                },
                onRelocated: _saveProgress,
              ),
            ),
            if (_isExiting) const _SavingOverlay(),
          ],
        ),
        bottomNavigationBar: const MiniPlayer(),
      ),
    );
  }

  void _showChapters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ChapterList(
        chapters: _chapters,
        onSelect: (chapter) {
          _controller.display(cfi: chapter.href);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// Shown over the page while the exit save is in flight — the save can take
/// a few hundred ms (up to a couple of seconds on a large book whose
/// locations haven't been generated yet), and with nothing on screen that
/// read as the back press having been ignored.
class _SavingOverlay extends StatelessWidget {
  const _SavingOverlay();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: colors.scrim.withValues(alpha: 0.4),
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      'Saving progress…',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterList extends StatelessWidget {
  const _ChapterList({required this.chapters, required this.onSelect});

  final List<EpubChapter> chapters;
  final ValueChanged<EpubChapter> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Chapters', style: TextStyle(fontSize: 18)),
            ),
            for (final chapter in chapters) ..._tiles(chapter),
          ],
        ),
      ),
    );
  }

  List<Widget> _tiles(EpubChapter chapter, [int depth = 0]) => [
    ListTile(
      contentPadding: EdgeInsets.only(left: 16.0 + depth * 16, right: 16),
      title: Text(chapter.title),
      onTap: () => onSelect(chapter),
    ),
    for (final sub in chapter.subitems) ..._tiles(sub, depth + 1),
  ];
}
