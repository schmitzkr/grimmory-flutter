import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../book/book_detail_screen.dart' show bookProvider;
import '../library/progress_refresh.dart';
import '../player/mini_player.dart';
import 'page_progress_saver.dart';

/// Comic (CBZ/CBR/CB7 — Grimmory's `CBX`) reader. Nothing is downloaded or
/// unpacked on the device: the server lists the readable pages
/// (`/cbx/{id}/pages`) and renders each one as an image
/// (`/media/book/{id}/cbx/pages/{n}`), so this is a paged, zoomable image
/// viewer over the same authenticated image loading `BookCover` uses.
///
/// Progress is the 1-based page number plus a percentage computed the way
/// the web reader does; saves go through [PageProgressSaver] onto the same
/// file-level progress path as the EPUB reader.
class ComicReaderScreen extends ConsumerStatefulWidget {
  const ComicReaderScreen({required this.bookId, super.key});

  final int bookId;

  @override
  ConsumerState<ComicReaderScreen> createState() => _ComicReaderScreenState();
}

class _ComicReaderScreenState extends ConsumerState<ComicReaderScreen> {
  List<int>? _pages;
  PageController? _controller;
  PageProgressSaver? _saver;
  int _index = 0;
  Object? _error;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _saver?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      // Best-effort: without the detail the save just uses the shim field.
      int? bookFileId;
      try {
        final book = await apiClient.getBook(widget.bookId);
        bookFileId = book.fileIdFor(PageFormat.cbx);
      } catch (_) {}

      final pages = await apiClient.getComicPages(
        widget.bookId,
        format: PageFormat.cbx,
      );
      final progress = await apiClient.getPageProgress(
        widget.bookId,
        PageFormat.cbx,
      );
      final initial = progress == null
          ? 0
          : (progress.page - 1).clamp(0, pages.isEmpty ? 0 : pages.length - 1);

      if (!mounted) return;
      setState(() {
        _pages = pages;
        _index = initial;
        _controller = PageController(initialPage: initial);
        _saver = PageProgressSaver(
          pageCount: pages.length,
          pageNumberAt: (index) => pages[index],
          persist: (progress) => apiClient.updatePageProgress(
            widget.bookId,
            progress,
            format: PageFormat.cbx,
            bookFileId: bookFileId,
          ),
          onError: _showSyncFailedSnackBar,
        );
      });
      _precacheAround(initial);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    _precacheAround(index);
    _saver?.pageChanged(index);
  }

  /// The next page is what a reader is about to look at; warming it keeps
  /// the swipe from landing on a spinner.
  void _precacheAround(int index) {
    final pages = _pages;
    if (pages == null) return;
    final apiClient = ref.read(apiClientProvider);
    for (final i in [index + 1, index - 1]) {
      if (i < 0 || i >= pages.length) continue;
      unawaited(
        precacheImage(
          CachedNetworkImageProvider(
            apiClient.comicPageUrl(
              widget.bookId,
              pages[i],
              format: PageFormat.cbx,
            ),
            headers: apiClient.authHeaders,
          ),
          context,
        ).catchError((_) {}),
      );
    }
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

  /// Save the current page, refresh every screen showing this book's
  /// progress, then pop — see the EPUB reader's `_exit` for why this runs
  /// here (while mounted, through the container) and not in `dispose()`.
  Future<void> _exit() async {
    if (_isExiting) return;
    setState(() => _isExiting = true);
    final saver = _saver;
    if (saver != null && (_pages?.isNotEmpty ?? false)) {
      final ok = await saver.saveNow(_index);
      // The snackbar is already up (onError); give it a moment to be read.
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
    final title =
        ref.watch(bookProvider(widget.bookId)).value?.title ?? 'Comic';
    final pages = _pages;

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

    if (pages == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (pages.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'The server found no pages in this comic.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final apiClient = ref.watch(apiClientProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(title),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Semantics(
                  label: 'Page ${_index + 1} of ${pages.length}',
                  liveRegion: true,
                  child: ExcludeSemantics(
                    child: Text(
                      '${_index + 1} / ${pages.length}',
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
            PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => _ComicPage(
                url: apiClient.comicPageUrl(
                  widget.bookId,
                  pages[index],
                  format: PageFormat.cbx,
                ),
                headers: apiClient.authHeaders,
                label: 'Page ${index + 1} of ${pages.length}',
              ),
            ),
            if (_isExiting) const SavingOverlay(),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pages.length > 1)
              SafeArea(
                top: false,
                child: Slider(
                  value: _index.toDouble(),
                  min: 0,
                  max: (pages.length - 1).toDouble(),
                  divisions: pages.length - 1,
                  label: '${_index + 1}',
                  onChanged: (value) => _controller?.jumpToPage(value.round()),
                ),
              ),
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }
}

/// Dims the page and swallows taps while the exit save runs — shared with
/// the PDF reader.
class SavingOverlay extends StatelessWidget {
  const SavingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: Colors.black54,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

/// One page: pinch-zoomable, letterboxed on black like every comic reader,
/// fetched with the bearer header the media endpoints require.
class _ComicPage extends StatelessWidget {
  const _ComicPage({
    required this.url,
    required this.headers,
    required this.label,
  });

  final String url;
  final Map<String, String> headers;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      image: true,
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: url,
            httpHeaders: headers,
            fit: BoxFit.contain,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
