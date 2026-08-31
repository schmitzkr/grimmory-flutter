import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Talks to a self-hosted Grimmory server's `/api/v1` REST API.
///
/// Auth endpoint *paths and request field names* are confirmed against a
/// live instance (grimmory.mael.is, 2026-08-30 — validation errors revealed
/// exact required fields). Everything else — library/book/series/bookmark
/// endpoints and every model shape — is confirmed against Grimmory's real
/// Java source (github.com/grimmory-tools/grimmory, package org.booklore;
/// Grimmory is a rebrand/fork of BookLore), 2026-08-31, after the original
/// guesses (based on the documented-but-unstable API surface without
/// source access) turned out wrong: entity IDs are numeric (`Long`), and a
/// dedicated `/api/v1/app/*` controller namespace exists purpose-built for
/// mobile clients (paginated summaries, continue-listening/recently-added)
/// — this client uses that namespace wherever it covers a need, falling
/// back to the general endpoints only where the app namespace doesn't
/// cover something (audiobook streaming/info, bookmarks).
class ApiClient {
  late final Dio _dio;
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  // In-memory token cache — avoids an async secure-storage read on every
  // request. Warmed at startup via [initialToken].
  String? _token;

  // Ensures concurrent 401s share one refresh call instead of racing to use
  // a single-use refresh token simultaneously.
  Future<bool>? _refreshFuture;

  String? get token => _token;

  /// For requests made outside this class's own [_dio] instance (e.g. an
  /// image widget fetching cover art directly) — Grimmory's cover/stream
  /// endpoints require the same bearer auth as everything else. Confirmed
  /// (2026-08-31, via QueryParameterJwtFilter's source) that a normal
  /// Authorization header authenticates these endpoints fine — the
  /// alternative `?token=` query param some Grimmory clients use exists
  /// only as a fallback for contexts that can't set custom headers (a
  /// browser's bare `<audio>`/`<img src>`), which doesn't apply to us.
  Map<String, String> get authHeaders =>
      _token == null ? {} : {'Authorization': 'Bearer $_token'};

  ApiClient(this._prefs, this._secureStorage, {String? initialToken}) {
    _token = initialToken;

    final serverUrl = _prefs.getString('server_url');
    // A relative-only baseUrl (e.g. '/api/v1' with no server configured yet)
    // is rejected by Dio on non-web platforms, so leave it empty until
    // updateBaseUrl() is called from onboarding.
    final baseUrl = (serverUrl == null || serverUrl.isEmpty)
        ? ''
        : '$serverUrl/api/v1';
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final path = error.requestOptions.path;
            final skipRefresh =
                path.contains('/auth/refresh') ||
                path.contains('/auth/login') ||
                path.contains('/auth/register') ||
                path.contains('/auth/logout') ||
                path.contains('/auth/oidc');
            if (!skipRefresh) {
              final refreshed = await _refreshToken();
              if (refreshed) {
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $_token';
                final response = await _dio.fetch(opts);
                handler.resolve(response);
                return;
              }
            }
          }

          // One-time automatic retry for a GET that failed on a transient
          // connection issue. GETs are safe to retry blindly since they're
          // read-only; mutating requests are deliberately left alone.
          final isConnectionIssue =
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.connectionError;
          final alreadyRetried = error.requestOptions.extra['_retried'] == true;
          if (isConnectionIssue &&
              error.requestOptions.method == 'GET' &&
              !alreadyRetried) {
            try {
              final opts = error.requestOptions;
              opts.extra['_retried'] = true;
              final response = await _dio.fetch(opts);
              handler.resolve(response);
              return;
            } catch (_) {
              // Retry itself failed — fall through and surface the original
              // error below.
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  void updateBaseUrl(String serverUrl) {
    _dio.options.baseUrl = '$serverUrl/api/v1';
    _prefs.setString('server_url', serverUrl);
  }

  Future<bool> _refreshToken() {
    _refreshFuture ??= _doRefresh().whenComplete(() => _refreshFuture = null);
    return _refreshFuture!;
  }

  /// Public entry point for callers outside this class's own [_dio]
  /// instance — e.g. the audio player, whose HTTP requests for stream bytes
  /// go through just_audio's own client, not [_dio], so a 401 mid-stream
  /// never passes through the interceptor above and needs to trigger a
  /// refresh explicitly. Shares the same single-flight guard as the
  /// interceptor's own refresh calls.
  Future<bool> refreshToken() => _refreshToken();

  Future<bool> _doRefresh() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken == null) return false;
    try {
      final resp = await _dio.post(
        '/auth/refresh',
        // Confirmed via a live validation error: the field is camelCase
        // "refreshToken", not "refresh_token" as originally guessed.
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );
      final tokens = AuthTokens.fromJson(resp.data as Map<String, dynamic>);
      await _storeTokens(tokens);
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  Future<void> _storeTokens(AuthTokens tokens) async {
    _token = tokens.accessToken;
    await _secureStorage.write(key: 'access_token', value: tokens.accessToken);
    await _secureStorage.write(
      key: 'refresh_token',
      value: tokens.refreshToken,
    );
    await _prefs.setBool('logged_in', true);
  }

  // ── Auth ───────────────────────────────────────────────────────────────

  /// [username] — confirmed via a live validation error: Grimmory logs in
  /// with a username, not an email address (the field is literally named
  /// "username" and its message is "Username must not be blank").
  Future<void> login(String username, String password) async {
    final resp = await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    await _storeTokens(AuthTokens.fromJson(resp.data as Map<String, dynamic>));
  }

  /// Confirmed via a live validation error that this endpoint's contract is
  /// NOT "hand me a completed ID token" (the original guess) — it's "hand
  /// me the raw PKCE authorization result and let the server exchange it
  /// with the IdP itself": required fields are exactly `code`, `state`,
  /// `codeVerifier`, `nonce`, `redirectUri`. This is why OIDC login doesn't
  /// use the `oidc` package's full OidcUserManager (which performs its own
  /// code-for-token exchange against the IdP and would never hand over a
  /// raw, unexchanged authorization code) — see
  /// features/auth/oidc_login_controller.dart, which runs the
  /// authorize-request half of the flow by hand instead.
  Future<void> loginWithOidc({
    required String code,
    required String state,
    required String codeVerifier,
    required String nonce,
    required String redirectUri,
  }) async {
    final resp = await _dio.post(
      '/auth/oidc/callback',
      data: {
        'code': code,
        'state': state,
        'codeVerifier': codeVerifier,
        'nonce': nonce,
        'redirectUri': redirectUri,
      },
    );
    await _storeTokens(AuthTokens.fromJson(resp.data as Map<String, dynamic>));
  }

  Future<void> logout() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken != null) {
      try {
        await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      } catch (_) {}
    }
    _token = null;
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _prefs.remove('logged_in');
  }

  // ── Libraries ───────────────────────────────────────────────────────

  /// Uses the general `/libraries` endpoint (`LibraryController`), not
  /// `/app/libraries` (`AppLibraryController`) — the latter throws a
  /// server-side `LazyInitializationException` on every call (confirmed via
  /// live server logs and the Grimmory source: `AppLibraryController
  /// .getLibraries()` has no `@Transactional`, and `AppBookMapper
  /// .toLibrarySummary()` accesses the lazy `LibraryEntity.libraryPaths`
  /// collection after the session is gone). `/libraries` is what Grimmory's
  /// own web frontend calls for the same screen, so it's confirmed working
  /// in production. Tradeoff: its `Library` DTO has no `bookCount` field, so
  /// [Library.bookCount] falls back to its `@Default(0)` here. Revert to
  /// `/app/libraries` once the upstream bug is fixed.
  Future<List<Library>> getLibraries() async {
    final resp = await _dio.get('/libraries');
    return (resp.data as List)
        .map((l) => Library.fromJson(l as Map<String, dynamic>))
        .toList();
  }

  // ── Books (AppBookController) ─────────────────────────────────────────

  /// [sort] must be one of the keys `AppBookService.getSortField()`
  /// recognizes server-side (confirmed against source, 2026-08-31):
  /// `addedon` (default), `title`, `series`/`seriesname`, `narrator`,
  /// `publisheddate`, `personalrating`, `readstatus`, `lastreadtime`, plus a
  /// few ebook/comic-only fields this app has no UI for. Anything else
  /// silently falls back to `addedon` server-side rather than erroring.
  /// [authors] filters to books by any of the given author names (OR'd
  /// together) — one of ~25 filter dimensions `BookListRequest` supports;
  /// the rest (tags, language, ratings, comic-specific facets, etc.) aren't
  /// exposed by this app's UI.
  Future<List<Book>> getLibraryBooks(
    int libraryId, {
    int page = 0,
    int size = 100,
    String? sort,
    String? dir,
    List<String>? authors,
  }) async {
    final resp = await _dio.get(
      '/app/books',
      queryParameters: {
        'libraryId': libraryId,
        'page': page,
        'size': size,
        'sort': ?sort,
        'dir': ?dir,
        'authors': ?authors,
      },
    );
    return _extractPageContent(resp.data).map(Book.fromJson).toList();
  }

  /// Available filter facet values (with book counts) for a library —
  /// confirmed against `AppFilterController`/`AppBookService.getFilterOptions`
  /// as `GET /api/v1/app/filter-options`, not `/app/filter` as originally
  /// assumed before checking source.
  Future<FilterOptions> getFilterOptions({int? libraryId}) async {
    final resp = await _dio.get(
      '/app/filter-options',
      queryParameters: {'libraryId': ?libraryId},
    );
    return FilterOptions.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Book> getBook(int bookId) async {
    final resp = await _dio.get('/app/books/$bookId');
    return Book.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<Book>> searchBooks(
    String query, {
    int page = 0,
    int size = 20,
  }) async {
    final resp = await _dio.get(
      '/app/books/search',
      queryParameters: {'q': query, 'page': page, 'size': size},
    );
    return _extractPageContent(resp.data).map(Book.fromJson).toList();
  }

  Future<List<Book>> getContinueListening({int limit = 10}) async {
    final resp = await _dio.get(
      '/app/books/continue-listening',
      queryParameters: {'limit': limit},
    );
    return (resp.data as List)
        .map((b) => Book.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  // ── Audiobook playback (not under /app — this endpoint isn't
  // app-namespaced) ────────────────────────────────────────────────────

  Future<AudiobookInfo> getAudiobookInfo(int bookId) async {
    final resp = await _dio.get('/audiobooks/$bookId/info');
    return AudiobookInfo.fromJson(resp.data as Map<String, dynamic>);
  }

  String streamUrl(int bookId) =>
      '${_dio.options.baseUrl}/audiobooks/$bookId/stream';

  String trackStreamUrl(int bookId, int trackIndex) =>
      '${_dio.options.baseUrl}/audiobooks/$bookId/track/$trackIndex/stream';

  /// Not `/audiobooks/{bookId}/cover` (`AudiobookReaderController`) — that
  /// endpoint extracts embedded ID3/tag art from the audio file itself and
  /// 404s for the vast majority of files, which don't carry embedded art.
  /// Confirmed against Grimmory's real source and its own frontend
  /// (`UrlHelperService.getAudiobookCoverUrl`) that the actual served cover
  /// — generated during library scan, or set via the cover
  /// upload/regenerate endpoints — lives in a separate controller
  /// (`BookMediaController`) under `/media/book/{bookId}/audiobook-cover`.
  String coverUrl(int bookId) =>
      '${_dio.options.baseUrl}/media/book/$bookId/audiobook-cover';

  /// Fallback for a book with no audiobook-specific cover generated yet —
  /// the general book cover `BookMediaController` also serves, which the
  /// real frontend falls back to the same way (`UrlHelperService
  /// .getCoverUrl`, used when `audiobookCoverUpdatedOn` is unset).
  String fallbackCoverUrl(int bookId) =>
      '${_dio.options.baseUrl}/media/book/$bookId/cover';

  // ── Progress (AppBookController — GET/PUT .../progress) ───────────────

  Future<AudiobookProgress?> getAudiobookProgress(int bookId) async {
    try {
      final resp = await _dio.get('/app/books/$bookId/progress');
      final data = resp.data as Map<String, dynamic>;
      final audiobookProgress = data['audiobookProgress'];
      if (audiobookProgress == null) return null;
      return AudiobookProgress.fromJson(
        audiobookProgress as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> updateAudiobookProgress(
    int bookId,
    AudiobookProgress progress,
  ) async {
    await _dio.put(
      '/app/books/$bookId/progress',
      data: {'audiobookProgress': progress.toJson()},
    );
  }

  // ── Series (AppSeriesController) ──────────────────────────────────────

  Future<List<Series>> getSeries({int page = 0, int size = 100}) async {
    final resp = await _dio.get(
      '/app/series',
      queryParameters: {'page': page, 'size': size},
    );
    return _extractPageContent(resp.data).map(Series.fromJson).toList();
  }

  Future<List<Book>> getSeriesBooks(
    String seriesName, {
    int page = 0,
    int size = 100,
  }) async {
    final resp = await _dio.get(
      '/app/series/${Uri.encodeComponent(seriesName)}/books',
      queryParameters: {'page': page, 'size': size},
    );
    return _extractPageContent(resp.data).map(Book.fromJson).toList();
  }

  // ── Bookmarks (BookMarkController — not app-namespaced) ────────────────

  Future<List<Bookmark>> getBookmarks(int bookId) async {
    final resp = await _dio.get('/bookmarks/book/$bookId');
    return (resp.data as List)
        .map((b) => Bookmark.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  Future<Bookmark> createBookmark(
    int bookId, {
    required int positionMs,
    int? trackIndex,
    String? title,
  }) async {
    final resp = await _dio.post(
      '/bookmarks',
      data: {
        'bookId': bookId,
        'positionMs': positionMs,
        'trackIndex': ?trackIndex,
        'title': ?title,
      },
    );
    return Bookmark.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteBookmark(int bookmarkId) async {
    await _dio.delete('/bookmarks/$bookmarkId');
  }

  /// Every `/app/*` list endpoint that supports pagination wraps its
  /// results as `{"content": [...], "page", "size", "totalElements", ...}`
  /// (Grimmory's `AppPageResponse<T>`) rather than returning a bare array.
  List<Map<String, dynamic>> _extractPageContent(dynamic data) {
    final content = (data as Map<String, dynamic>)['content'] as List;
    return content.cast<Map<String, dynamic>>();
  }
}
