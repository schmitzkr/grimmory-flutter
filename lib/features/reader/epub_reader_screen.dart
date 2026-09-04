import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../book/book_detail_screen.dart' show bookProvider;
import '../bookmarks/epub_bookmarks_sheet.dart';
import '../library/continue_reading_section.dart' show continueReadingProvider;
import '../library/library_detail_screen.dart' show libraryBooksProvider;
import '../library/recently_added_section.dart' show recentlyAddedProvider;
import '../player/mini_player.dart';
import 'epub_gesture_overlay.dart';

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
  List<EpubChapter> _chapters = [];
  Object? _error;

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

  @override
  void dispose() {
    // Every screen showing this book's progress (book detail, Continue
    // Reading, Recently Added, a library grid) fetched its data before this
    // reading session started, so it's holding a stale cache with no
    // progress update in it — without this, going back showed the old
    // progress until a manual pull-to-refresh. `ref.invalidate` on a family
    // provider with no argument invalidates every argument instance of it.
    ref.invalidate(bookProvider(widget.bookId));
    ref.invalidate(continueReadingProvider);
    ref.invalidate(recentlyAddedProvider);
    ref.invalidate(libraryBooksProvider);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/epub_${widget.bookId}.epub';
      await apiClient.downloadBookFile(widget.bookId, path);
      final bytes = await File(path).readAsBytes();
      final progress = await apiClient.getEpubProgress(widget.bookId);

      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _initialCfi = widget.jumpToCfi ?? progress?.cfi;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  void _saveProgress(EpubLocation location) {
    _currentCfi = location.startCfi;
    unawaited(_persistProgress(location));
  }

  Future<void> _persistProgress(EpubLocation location) {
    return ref
        .read(apiClientProvider)
        .updateEpubProgress(
          widget.bookId,
          // location.progress is epub.js's own 0.0-1.0 fraction, but the
          // server stores/interprets this percentage on a 0-100 scale
          // (confirmed via the real web frontend, which does
          // `goToFraction(progress.percentage / 100)` to convert it back) —
          // sending the raw 0-1 fraction left read status stuck below the
          // server's READING threshold for anything under ~10% real
          // progress, so books never surfaced in Continue Reading unless
          // read well past their first chapter.
          EpubProgress(
            cfi: location.startCfi,
            percentage: location.progress * 100,
          ),
        )
        .catchError((_) {
          // Best-effort — a dropped progress save shouldn't interrupt
          // reading, same convention as the audiobook player.
        });
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
      final location = await _controller.getCurrentLocation().timeout(
        const Duration(seconds: 3),
      );
      await _persistProgress(location);
    } catch (_) {
      // Best-effort — never block leaving the reader on this.
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
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _saveProgressBeforeExit();
        if (mounted) Navigator.of(context).pop();
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
        body: EpubGestureOverlay(
          onTapLeft: _controller.prev,
          onTapRight: _controller.next,
          onSwipeDown: () => _showBookmarks(context),
          onSwipeUp: _chapters.isEmpty ? () {} : () => _showChapters(context),
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
