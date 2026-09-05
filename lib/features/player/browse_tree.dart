import 'package:audio_service/audio_service.dart';

import '../../core/api/api_client.dart';
import '../../core/api/models.dart';

/// The Android Auto browse tree, kept apart from the handler so it can be
/// exercised without a real `AudioPlayer`. audio_service's Android backend
/// already implements MediaBrowserService; `getChildren` is the one method
/// that surface needs, and the handler just delegates to [children].
///
/// Every level is fetched on demand and memoised for [cacheTtl] — Android
/// Auto re-requests the same parent on each expansion, and a browse tree
/// that hits the API for every tap is both slow and a burst of identical
/// requests. An API failure renders as an empty level rather than an error
/// the head unit can't display.
class BrowseTree {
  BrowseTree(
    this._apiClient, {
    this.cacheTtl = const Duration(seconds: 60),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const rootContinueListening = 'root:continue';
  static const rootLibraries = 'root:libraries';
  static const rootSeries = 'root:series';

  final ApiClient _apiClient;
  final Duration cacheTtl;
  final DateTime Function() _now;
  final _cache = <String, ({DateTime at, List<MediaItem> items})>{};

  Future<List<MediaItem>> children(String parentMediaId) async {
    if (parentMediaId == AudioService.browsableRootId) {
      return const [
        MediaItem(
          id: rootContinueListening,
          title: 'Continue Listening',
          playable: false,
        ),
        MediaItem(id: rootLibraries, title: 'Libraries', playable: false),
        MediaItem(id: rootSeries, title: 'Series', playable: false),
      ];
    }

    final cached = _cache[parentMediaId];
    if (cached != null && _now().difference(cached.at) < cacheTtl) {
      return cached.items;
    }
    try {
      final items = await _fetch(parentMediaId);
      _cache[parentMediaId] = (at: _now(), items: items);
      return items;
    } catch (_) {
      return const [];
    }
  }

  Future<List<MediaItem>> _fetch(String parentMediaId) async {
    switch (parentMediaId) {
      case rootContinueListening:
        final books = await _apiClient.getContinueListening();
        return books.map(leaf).toList();
      case rootLibraries:
        final libraries = await _apiClient.getLibraries();
        return [
          for (final library in libraries)
            MediaItem(
              id: 'lib:${library.id}',
              title: library.name,
              playable: false,
            ),
        ];
      case rootSeries:
        final series = await _apiClient.getSeries();
        return [
          for (final s in series)
            MediaItem(
              id: 'series:${Uri.encodeComponent(s.seriesName)}',
              title: s.seriesName,
              playable: false,
            ),
        ];
    }
    // Only audiobooks are playable — every leaf here is handed straight to
    // playFromMediaId(), which would fail (getAudiobookInfo 404s) for any
    // other format, so both list levels filter to AUDIOBOOK.
    if (parentMediaId.startsWith('lib:')) {
      final libraryId = int.parse(parentMediaId.substring('lib:'.length));
      final books = await _apiClient.getLibraryBooks(
        libraryId,
        fileType: const ['AUDIOBOOK'],
      );
      return books.map(leaf).toList();
    }
    if (parentMediaId.startsWith('series:')) {
      final seriesName = Uri.decodeComponent(
        parentMediaId.substring('series:'.length),
      );
      final books = await _apiClient.getSeriesBooks(seriesName);
      return books
          .where((b) => b.primaryFileType == 'AUDIOBOOK')
          .map(leaf)
          .toList();
    }
    return const [];
  }

  /// A playable leaf — id is the bare book id (no track suffix), so tapping
  /// it in Android Auto calls `playFromMediaId` exactly the same way the
  /// phone UI's Play button does.
  MediaItem leaf(Book book) => MediaItem(
    id: book.id.toString(),
    title: book.title,
    artist: book.authors.isNotEmpty ? book.authors.join(', ') : null,
    artUri: Uri.parse(_apiClient.coverUrl(book.id, version: book.coverVersion)),
    artHeaders: _apiClient.authHeaders,
    playable: true,
    extras: {'bookId': book.id},
  );
}
