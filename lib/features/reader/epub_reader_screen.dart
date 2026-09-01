import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';

/// EPUB rendering is entirely client-side via `flutter_epub_viewer`
/// (WebView + epub.js), which parses a real local EPUB file directly —
/// so this downloads the book's raw file once per session rather than
/// using Grimmory's piecemeal spine/manifest/resource-file endpoints
/// (`/api/v1/epub/**`), which this package has no use for.
class EpubReaderScreen extends ConsumerStatefulWidget {
  const EpubReaderScreen({
    required this.bookId,
    required this.title,
    super.key,
  });

  final int bookId;
  final String title;

  @override
  ConsumerState<EpubReaderScreen> createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends ConsumerState<EpubReaderScreen> {
  final _controller = EpubController();
  File? _file;
  String? _initialCfi;
  List<EpubChapter> _chapters = [];
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/epub_${widget.bookId}.epub';
      await apiClient.downloadBookFile(widget.bookId, path);
      final progress = await apiClient.getEpubProgress(widget.bookId);

      if (!mounted) return;
      setState(() {
        _file = File(path);
        _initialCfi = progress?.cfi;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  void _saveProgress(EpubLocation location) {
    ref
        .read(apiClientProvider)
        .updateEpubProgress(
          widget.bookId,
          EpubProgress(cfi: location.startCfi, percentage: location.progress),
        )
        .catchError((_) {
          // Best-effort — a dropped progress save shouldn't interrupt
          // reading, same convention as the audiobook player.
        });
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

    if (_file == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Chapters',
            onPressed: _chapters.isEmpty ? null : () => _showChapters(context),
          ),
        ],
      ),
      body: EpubViewer(
        epubController: _controller,
        epubSource: EpubSource.fromFile(_file!),
        initialCfi: _initialCfi,
        onChaptersLoaded: (chapters) {
          if (mounted) setState(() => _chapters = chapters);
        },
        onRelocated: _saveProgress,
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
