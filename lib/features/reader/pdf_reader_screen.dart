import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../book/book_detail_screen.dart' show bookProvider;
import '../library/progress_refresh.dart';
import '../player/mini_player.dart';
import 'comic_reader_screen.dart' show SavingOverlay;
import 'page_progress_saver.dart';
import 'reader_chrome.dart';

/// Shared with the EPUB reader's dark toggle: one preference, both readers.
const _readerDarkModeKey = 'reader_dark_mode';

/// PDF reader on `pdfrx` (PDFium): a continuous vertical scroll of pages
/// with pinch-zoom, the way Grimmory's own web PDF reader lays a book out.
///
/// Like the EPUB reader, the file is pulled down once (by file id, so a
/// dual-format book's PDF opens even when the audiobook is the primary
/// file) and cached in the temp directory.
///
/// Progress is the 1-based page number with the web reader's percentage
/// formula (`round(page / pageCount * 1000) / 10`), saved through
/// [PageProgressSaver] onto the same file-level progress path as the other
/// readers, so a PDF started here resumes at the same page on the web.
class PdfReaderScreen extends ConsumerStatefulWidget {
  const PdfReaderScreen({required this.bookId, super.key});

  final int bookId;

  @override
  ConsumerState<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends ConsumerState<PdfReaderScreen> {
  final _controller = PdfViewerController();
  PageProgressSaver? _saver;
  String? _path;
  int? _bookFileId;
  int _initialPage = 1;
  int _page = 1;
  int _pageCount = 0;
  Object? _error;
  String? _blockedReason;
  bool _isExiting = false;
  bool _night = false;
  bool _chromeVisible = true;

  @override
  void initState() {
    super.initState();
    _night = ref.read(sharedPrefsProvider).getBool(_readerDarkModeKey) ?? false;
    _load();
  }

  @override
  void dispose() {
    if (!_chromeVisible) setReaderImmersive(false);
    _saver?.dispose();
    super.dispose();
  }

  void _toggleChrome() {
    setState(() => _chromeVisible = !_chromeVisible);
    setReaderImmersive(!_chromeVisible);
  }

  void _toggleNight() {
    setState(() => _night = !_night);
    ref.read(sharedPrefsProvider).setBool(_readerDarkModeKey, _night);
  }

  Future<void> _load() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      Book? book;
      try {
        book = await apiClient.getBook(widget.bookId);
      } catch (_) {}
      final fileId = book?.fileIdFor(PageFormat.pdf);
      if (book != null && fileId == null && book.primaryFileType != 'PDF') {
        if (!mounted) return;
        setState(
          () => _blockedReason =
              'This book has no PDF file — its only file is '
              '${book!.primaryFileType?.toLowerCase() ?? 'not a PDF'}.',
        );
        return;
      }
      _bookFileId = fileId;

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/pdf_${widget.bookId}.pdf';
      final file = File(path);
      // Reused between sessions; retry after an error clears it (build).
      if (!await file.exists() || await file.length() == 0) {
        await apiClient.downloadBookFile(widget.bookId, path, fileId: fileId);
      }

      final progress = await apiClient.getPageProgress(
        widget.bookId,
        PageFormat.pdf,
      );
      // pdfrx clamps an out-of-range page to the last one itself, so a
      // saved page past the end of a re-scanned file still opens.
      final initial = progress == null ? 1 : progress.page.clamp(1, 1 << 20);

      if (!mounted) return;
      setState(() {
        _path = path;
        _initialPage = initial;
        _page = initial;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  /// The page count is only known once PDFium has opened the file, so the
  /// saver is built here rather than in [_load].
  void _onViewerReady(PdfDocument document, PdfViewerController controller) {
    final apiClient = ref.read(apiClientProvider);
    final count = document.pages.length;
    setState(() {
      _pageCount = count;
      _page = _page.clamp(1, count < 1 ? 1 : count);
      _saver?.dispose();
      _saver = PageProgressSaver(
        pageCount: count,
        pageNumberAt: (index) => index + 1,
        persist: (progress) => apiClient.updatePageProgress(
          widget.bookId,
          progress,
          format: PageFormat.pdf,
          bookFileId: _bookFileId,
        ),
        onError: _showSyncFailedSnackBar,
      );
    });
  }

  void _onPageChanged(int? pageNumber) {
    if (pageNumber == null || pageNumber == _page) return;
    setState(() => _page = pageNumber);
    _saver?.pageChanged(pageNumber - 1);
  }

  void _showSyncFailedSnackBar(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not sync reading progress: ${friendlyApiError(error)}',
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Same exit contract as the comic and EPUB readers: final save, refresh
  /// the screens showing this book's progress, then pop.
  Future<void> _exit() async {
    if (_isExiting) return;
    setState(() => _isExiting = true);
    final saver = _saver;
    if (saver != null && _pageCount > 0) {
      final ok = await saver.saveNow(_page - 1);
      if (!ok && mounted) {
        await Future.delayed(const Duration(milliseconds: 1200));
      }
    }
    if (!mounted) return;
    refreshProgressConsumers(
      ProviderScope.containerOf(context, listen: false),
      bookId: widget.bookId,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = ref.watch(bookProvider(widget.bookId)).value?.title ?? 'PDF';

    if (_blockedReason != null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_blockedReason!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(friendlyApiError(_error!), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    // A half-written or corrupt cache must not be reused.
                    final path = _path;
                    if (path != null) {
                      try {
                        await File(path).delete();
                      } catch (_) {}
                    }
                    setState(() {
                      _error = null;
                      _path = null;
                    });
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

    final path = _path;
    if (path == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Fetching PDF…'),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        backgroundColor: _night ? Colors.black : null,
        appBar: !_chromeVisible
            ? null
            : AppBar(
                title: Text(title),
                actions: [
                  IconButton(
                    tooltip: _night ? 'Day mode' : 'Night mode',
                    icon: Icon(
                      _night
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                    onPressed: _toggleNight,
                  ),
                  FullscreenButton(onPressed: _toggleChrome),
                  if (_pageCount > 0)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Semantics(
                          label: 'Page $_page of $_pageCount',
                          liveRegion: true,
                          child: ExcludeSemantics(
                            child: Text(
                              '$_page / $_pageCount',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
        body: Stack(
          children: [
            // Night mode is pdfrx's documented approach: invert the whole
            // viewer with a difference blend, which turns white paper black
            // and black type white and leaves images inverted (acceptable
            // for text-heavy PDFs, which is what night reading is).
            ColorFiltered(
              colorFilter: _night
                  ? const ColorFilter.mode(Colors.white, BlendMode.difference)
                  : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
              child: PdfViewer.file(
                path,
                controller: _controller,
                initialPageNumber: _initialPage,
                params: PdfViewerParams(
                  backgroundColor: _night
                      ? Colors.white
                      : Theme.of(context).colorScheme.surface,
                  onViewerReady: _onViewerReady,
                  onPageChanged: _onPageChanged,
                  errorBannerBuilder:
                      (context, error, stackTrace, documentRef) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Could not open this PDF: $error',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                ),
              ),
            ),
            if (!_chromeVisible) FullscreenExitButton(onPressed: _toggleChrome),
            if (_isExiting) const SavingOverlay(),
          ],
        ),
        bottomNavigationBar: !_chromeVisible
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_pageCount > 1)
                    SafeArea(
                      top: false,
                      child: Slider(
                        value: _page.clamp(1, _pageCount).toDouble(),
                        min: 1,
                        max: _pageCount.toDouble(),
                        divisions: _pageCount - 1,
                        label: '$_page',
                        onChanged: (value) =>
                            _controller.goToPage(pageNumber: value.round()),
                      ),
                    ),
                  const MiniPlayer(),
                ],
              ),
      ),
    );
  }
}
