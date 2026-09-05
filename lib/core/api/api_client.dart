import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;
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
/// The Continue Reading/Listening order: books with a recorded
/// [Book.lastReadTime], newest first, cut to [limit]. A book with no
/// timestamp has never actually been opened by this user (a status set by
/// hand on the web, say) and is left out, as the web dashboard leaves it out.
List<Book> inProgressOrder(Iterable<Book> books, {required int limit}) {
  final dated = books.where((b) => b.lastReadTime != null).toList()
    ..sort((a, b) => b.lastReadTime!.compareTo(a.lastReadTime!));
  return dated.take(limit).toList();
}

class ApiClient {
  late final Dio _dio;
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  // In-memory token cache — avoids an async secure-storage read on every
  // request. Warmed at startup via [initialToken].
  String? _token;
  // From `AccessTokenDto.expires`; unknown for a token restored at startup
  // (only the string is persisted), in which case the 401 path still covers
  // expiry.
  DateTime? _tokenExpiresAt;

  // How close to expiry a request triggers a refresh before being sent,
  // instead of paying a 401 round-trip first.
  static const _refreshAhead = Duration(seconds: 60);

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

  /// Lets tests answer requests in-process (request bodies, status codes,
  /// the 401→refresh→retry path) without a server; everything above the
  /// adapter — interceptors, transformers, base URL — still runs for real.
  @visibleForTesting
  set httpClientAdapter(HttpClientAdapter adapter) =>
      _dio.httpClientAdapter = adapter;

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
        onRequest: (options, handler) async {
          final expiresAt = _tokenExpiresAt;
          if (_token != null &&
              expiresAt != null &&
              !_isAuthPath(options.path) &&
              expiresAt.difference(DateTime.now()) < _refreshAhead) {
            // Best-effort: if this fails the request goes out with the old
            // token and the 401 path below takes over.
            await _refreshToken();
          }
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final skipRefresh = _isAuthPath(error.requestOptions.path);
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

  /// The auth endpoints never get a token refresh triggered on their
  /// behalf — a 401 from them means bad credentials, and the refresh call
  /// itself must not recurse into another refresh.
  static bool _isAuthPath(String path) =>
      path.contains('/auth/refresh') ||
      path.contains('/auth/login') ||
      path.contains('/auth/register') ||
      path.contains('/auth/logout') ||
      path.contains('/auth/oidc');

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
        // camelCase, like every other field on this API (confirmed against
        // `RefreshTokenRequest` and a live validation error).
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );
      final tokens = AuthTokens.fromJson(resp.data as Map<String, dynamic>);
      await _storeTokens(tokens);
      return true;
    } on DioException catch (e) {
      // Only a definite rejection of the refresh token ends the session,
      // and then only locally: `/auth/logout` revokes *every* refresh token
      // the account has (`LogoutService.revokeRefreshToken(user)`), which
      // used to sign the user out of the web and any other device too. A
      // rate limit (429), a server error or a dead network leaves the
      // stored token alone — the request goes out with the old access
      // token and either works or fails on its own terms.
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) await _clearLocalSession();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _storeTokens(AuthTokens tokens) async {
    _token = tokens.accessToken;
    final expires = tokens.expires;
    // `expires` is the access token's LIFETIME in seconds
    // (`AccessTokenDto.expires = accessTokenExpirationMs / 1000`, 7200 on
    // v3.3.3) — not a timestamp. Reading it as epoch milliseconds put every
    // expiry in 1970, so the proactive refresh above fired before *every*
    // request; each refresh rotates the server-side token, and the
    // server's limit of five failed refreshes per IP in 15 minutes then
    // turned a burst of requests into a forced logout (v0.11.12–v0.11.14).
    _tokenExpiresAt = expires == null
        ? null
        : DateTime.now().add(Duration(seconds: expires));
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

  /// `state` here is NOT arbitrary client-generated randomness — confirmed
  /// via the real Grimmory server source (`OidcStateService`) that it's a
  /// one-time value the server itself generates and caches (5 min TTL),
  /// then consumes exactly once on callback. A state this app made up
  /// itself will never be in that cache, and the server rejects it with
  /// "Invalid or expired OIDC state parameter" every time. Callers must
  /// use [getOidcState] to obtain the state value before starting the
  /// authorize request, not generate their own.
  Future<String> getOidcState() async {
    final resp = await _dio.get('/auth/oidc/state');
    return (resp.data as Map<String, dynamic>)['state'] as String;
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

  Future<void> _clearLocalSession() async {
    _token = null;
    _tokenExpiresAt = null;
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  Future<void> logout() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken != null) {
      try {
        await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      } catch (e) {
        // Local sign-out proceeds regardless; only a server-side rejection
        // (not an unreachable server) is worth a note in the log.
        final offline =
            e is DioException && e.type != DioExceptionType.badResponse;
        if (!offline) debugPrint('logout: server rejected refresh token: $e');
      }
    }
    await _clearLocalSession();
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
  /// exposed by this app's UI. [fileType] values match `Library
  /// .allowedFormats`'s enum (`AUDIOBOOK`, `EPUB`, `PDF`, `CBX`, `FB2`,
  /// `MOBI`, `AZW3`) — used for the library screen's audiobook/ebook filter.
  Future<List<Book>> getLibraryBooks(
    int libraryId, {
    int page = 0,
    int size = 100,
    String? sort,
    String? dir,
    List<String>? authors,
    List<String>? fileType,
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
        'fileType': ?fileType,
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

  /// Downloads one of the book's raw files to [destinationPath], through
  /// this class's own `_dio` so the bearer token goes with it.
  ///
  /// With [fileId], `GET /books/{bookId}/files/{fileId}/download`
  /// (`AdditionalFileController`, JWT + book-access check, present since
  /// v3.3.3): any file attached to the book, book-format or not — its
  /// repository query filters on nothing but the two ids. That is how a
  /// dual-format book whose primary file is the audiobook still gives up
  /// its EPUB or PDF. Without [fileId], the older
  /// `GET /books/{bookId}/download` (`BookController`), which only ever
  /// serves the *primary* file — kept for the case where the book detail
  /// (and so the file ids) could not be fetched.
  Future<void> downloadBookFile(
    int bookId,
    String destinationPath, {
    int? fileId,
  }) async {
    final path = fileId == null
        ? '/books/$bookId/download'
        : '/books/$bookId/files/$fileId/download';
    await _dio.download(path, destinationPath);
  }

  /// Streams [url] (absolute — e.g. [streamUrl]/[trackStreamUrl]) to
  /// [destinationPath] through this client, so the bearer header, the
  /// 401→refresh→retry path and the connection-error retry all apply — a
  /// multi-hour audiobook download outlives an access token. The receive
  /// timeout is lifted for just this call: it's a per-chunk idle timeout in
  /// Dio, but a large file on a slow link still trips the 20s default.
  Future<void> downloadFile(
    String url,
    String destinationPath, {
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    await _dio.download(
      url,
      destinationPath,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      options: Options(receiveTimeout: Duration.zero),
    );
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

  /// Continue Listening — the audiobooks this user is partway through,
  /// most recently played first. See [_inProgressBooks] for why this does
  /// not call `/app/books/continue-listening`.
  Future<List<Book>> getContinueListening({int limit = 10}) =>
      _inProgressBooks(fileTypes: const ['AUDIOBOOK'], limit: limit);

  /// Continue Reading — the non-audiobook counterpart. The file-type split
  /// mirrors the server's own `findTopContinueReadingBookIds`
  /// (`bookType <> AUDIOBOOK`): a dual-format book that is being both read
  /// and listened to shows in both carousels, as on the web.
  Future<List<Book>> getContinueReading({int limit = 10}) =>
      _inProgressBooks(fileTypes: _readableFileTypes, limit: limit);

  static const _readableFileTypes = [
    'EPUB',
    'PDF',
    'CBX',
    'FB2',
    'MOBI',
    'AZW3',
  ];

  /// `GET /app/books` filtered to READING/RE_READING and the given file
  /// types, then ordered by [Book.lastReadTime] here — the same client-side
  /// recipe as Grimmory's web dashboard.
  ///
  /// Not the purpose-built `/app/books/continue-reading` and
  /// `/continue-listening`: for an **admin** account
  /// `AppBookService.getAccessibleLibraryIds` returns `null` (meaning "all
  /// libraries"), and those two endpoints hand that null straight into a
  /// JPQL `b.library.id IN :libraryIds`, which matches nothing — so an admin
  /// always gets an empty list even with books in progress (v3.3.3 and
  /// `develop` alike, 2026-09-05). Every other list endpoint goes through
  /// `AppBookSpecification.inLibraries`, which treats null as no filter,
  /// which is why this one works. Ordering is done here rather than with
  /// `sort=lastReadTime`, because that sort field joins the per-user
  /// progress collection across *all* users.
  ///
  /// [fileTypes] and the statuses are sent comma-joined in a single value:
  /// Spring's conversion splits that into the record's `List<String>` on
  /// its own, independent of how Dio encodes a Dart list (its default is
  /// the bracketed `status[]=` form, which the server's record binder is
  /// not known to accept).
  Future<List<Book>> _inProgressBooks({
    required List<String> fileTypes,
    required int limit,
  }) async {
    final resp = await _dio.get(
      '/app/books',
      queryParameters: {
        'status': 'READING,RE_READING',
        'fileType': fileTypes.join(','),
        'page': 0,
        // Only this user's in-progress books of these types come back, so
        // one page comfortably holds every candidate before the cut.
        'size': 50,
      },
    );
    final books = _extractPageContent(resp.data).map(Book.fromJson);
    return inProgressOrder(books, limit: limit);
  }

  /// `/app/books/recently-added`, not `/app/books/recently` as an earlier
  /// pass at this guessed before checking `AppBookController`'s source.
  Future<List<Book>> getRecentlyAdded({int limit = 10}) async {
    final resp = await _dio.get(
      '/app/books/recently-added',
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
  ///
  /// [version] (see `Book.coverVersion`) is appended as a query parameter
  /// purely to defeat image caches after a cover is regenerated — the path
  /// itself never changes, which is how the web client does it too.
  String coverUrl(int bookId, {String? version}) => _versioned(
    '${_dio.options.baseUrl}/media/book/$bookId/audiobook-cover',
    version,
  );

  /// Fallback for a book with no audiobook-specific cover generated yet —
  /// the general book cover `BookMediaController` also serves, which the
  /// real frontend falls back to the same way (`UrlHelperService
  /// .getCoverUrl`, used when `audiobookCoverUpdatedOn` is unset).
  String fallbackCoverUrl(int bookId, {String? version}) =>
      _versioned('${_dio.options.baseUrl}/media/book/$bookId/cover', version);

  static String _versioned(String url, String? version) =>
      version == null ? url : '$url?v=${Uri.encodeQueryComponent(version)}';

  /// `BookMediaController` — `GET /media/author/{authorId}/photo`. 404s for
  /// an author without one, so gate on [Author.hasPhoto] before using it.
  String authorPhotoUrl(int authorId) =>
      '${_dio.options.baseUrl}/media/author/$authorId/photo';

  // ── Progress (AppBookController — GET/PUT .../progress) ───────────────
  //
  // Grimmory stores progress per *file* now (`UserBookFileProgressEntity`,
  // keyed on `bookFileId`); the per-type request fields (`epubProgress`,
  // `audiobookProgress`) are `@Deprecated` shims routed by the book's
  // primary-file type. Two real bugs came from relying on the shims alone:
  // the audiobook shim persists nothing at all (every legacy branch has an
  // empty `case AUDIOBOOK`, and the read side only looks at the file
  // table), and the EPUB shim is dropped outright on a book whose library
  // format priority makes an audiobook file primary. So the save calls
  // below send the `fileProgress` block the web client sends — same
  // `positionData`/`positionHref` encoding — alongside the shim field.

  Future<AudiobookProgress?> getAudiobookProgress(int bookId) async {
    try {
      final resp = await _dio.get('/app/books/$bookId/progress');
      final data = resp.data as Map<String, dynamic>;
      final audiobookProgress = data['audiobookProgress'];
      // Saves made through the deprecated shim by earlier builds of this
      // app left a hollow file-progress row (lastReadTime only), which the
      // server maps to `{positionMs: null, ...}` — no position to resume.
      if (audiobookProgress == null ||
          (audiobookProgress as Map<String, dynamic>)['positionMs'] == null) {
        return null;
      }
      return AudiobookProgress.fromJson(audiobookProgress);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> updateAudiobookProgress(
    int bookId,
    AudiobookProgress progress, {
    required int? bookFileId,
  }) async {
    await _dio.put(
      '/app/books/$bookId/progress',
      data: {
        'audiobookProgress': progress.toJson(),
        if (bookFileId != null)
          'fileProgress': {
            'bookFileId': bookFileId,
            'positionData': progress.positionMs.toString(),
            'positionHref': progress.trackIndex?.toString(),
            'progressPercent': progress.percentage,
          },
      },
    );
  }

  Future<EpubProgress?> getEpubProgress(int bookId) async {
    try {
      final resp = await _dio.get('/app/books/$bookId/progress');
      final data = resp.data as Map<String, dynamic>;
      final epubProgress = data['epubProgress'];
      if (epubProgress == null) return null;
      return EpubProgress.fromJson(epubProgress as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> updateEpubProgress(
    int bookId,
    EpubProgress progress, {
    required int? bookFileId,
  }) async {
    await _dio.put(
      '/app/books/$bookId/progress',
      data: {
        'epubProgress': progress.toJson(),
        if (bookFileId != null)
          'fileProgress': {
            'bookFileId': bookFileId,
            'positionData': progress.cfi,
            'positionHref': progress.href,
            'progressPercent': progress.percentage,
          },
      },
    );
  }

  /// Page-based progress (comics, PDFs): `cbxProgress`/`pdfProgress` on the
  /// same `GET /app/books/{id}/progress` response the EPUB reader uses.
  Future<PageProgress?> getPageProgress(int bookId, PageFormat format) async {
    try {
      final resp = await _dio.get('/app/books/$bookId/progress');
      final data = resp.data as Map<String, dynamic>;
      final progress = data[format.jsonKey];
      if (progress == null ||
          (progress as Map<String, dynamic>)['page'] == null) {
        return null;
      }
      return PageProgress.fromJson(progress);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Same dual write as [updateEpubProgress]: the deprecated per-type field
  /// plus the file-level block that actually persists. `positionData` is
  /// the page number as a string — the encoding `ReadingProgressService`
  /// parses back with `Integer.parseInt` for PDF/CBX.
  Future<void> updatePageProgress(
    int bookId,
    PageProgress progress, {
    required PageFormat format,
    required int? bookFileId,
  }) async {
    await _dio.put(
      '/app/books/$bookId/progress',
      data: {
        format.jsonKey: {
          'page': progress.page,
          'percentage': progress.percentage,
        },
        if (bookFileId != null)
          'fileProgress': {
            'bookFileId': bookFileId,
            'positionData': progress.page.toString(),
            'positionHref': null,
            'progressPercent': progress.percentage,
          },
      },
    );
  }

  /// `PUT /app/books/{id}/status` — one of Grimmory's `ReadStatus` values
  /// (UNREAD, READING, RE_READING, READ, PARTIALLY_READ, PAUSED, WONT_READ,
  /// ABANDONED, UNSET). Also what the web's status menu calls.
  Future<void> updateReadStatus(int bookId, String status) async {
    await _dio.put('/app/books/$bookId/status', data: {'status': status});
  }

  /// `PUT /app/books/{id}/rating` — the personal rating, 1–5 (the server
  /// rejects anything else with a 400).
  Future<void> updatePersonalRating(int bookId, int rating) async {
    await _dio.put('/app/books/$bookId/rating', data: {'rating': rating});
  }

  // ── Comics (CbxReaderController + BookMediaController) ────────────────

  /// `GET /cbx/{bookId}/pages` — the page numbers the server can render,
  /// in reading order (1-based). [bookType] picks the file on a book that
  /// has more than one format, same as the web reader passes it.
  Future<List<int>> getComicPages(int bookId, {PageFormat? format}) async {
    final resp = await _dio.get(
      '/cbx/$bookId/pages',
      queryParameters: {if (format != null) 'bookType': format.bookType},
    );
    return (resp.data as List).cast<num>().map((n) => n.toInt()).toList();
  }

  /// `BookMediaController` — `GET /media/book/{bookId}/cbx/pages/{page}`:
  /// the server extracts and serves each page image itself, so the app
  /// never touches the archive. Needs [authHeaders] like every media URL.
  String comicPageUrl(int bookId, int page, {PageFormat? format}) {
    final base = '${_dio.options.baseUrl}/media/book/$bookId/cbx/pages/$page';
    return format == null ? base : '$base?bookType=${format.bookType}';
  }

  // ── Dashboard (UserController + AppBookController) ─────────────────────

  /// The user's saved web-dashboard layout, or null when they have never
  /// customised it. Read from `GET /users/me` (the general user endpoint —
  /// the app-namespaced `/app/users/me` only carries a few permission
  /// flags), which is where the web's `DashboardConfigService` reads and
  /// writes it too, so the phone shows whatever row order and titles were
  /// arranged in the browser.
  Future<DashboardConfig?> getDashboardConfig() async =>
      (await getCurrentUser()).userSettings?.dashboardConfig;

  /// `GET /users/me` — the signed-in account (the general user endpoint;
  /// the app-namespaced `/app/users/me` only carries a few permission
  /// flags). Shown on the Settings screen and the source of
  /// [getDashboardConfig].
  Future<CurrentUser> getCurrentUser() async {
    final resp = await _dio.get('/users/me');
    return CurrentUser.fromJson(resp.data as Map<String, dynamic>);
  }

  /// `GET /app/books/random` — a page of [size] books starting at a random
  /// offset (the server picks the window, not the members), optionally
  /// scoped to one library. Feeds the "Discover Something New" row.
  Future<List<Book>> getRandomBooks({int size = 20, int? libraryId}) async {
    final resp = await _dio.get(
      '/app/books/random',
      queryParameters: {'page': 0, 'size': size, 'libraryId': ?libraryId},
    );
    return _extractPageContent(resp.data).map(Book.fromJson).toList();
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

  // ── Authors (AppAuthorController) ───────────────────────────────────────

  Future<List<Author>> getAuthors({int page = 0, int size = 100}) async {
    final resp = await _dio.get(
      '/app/authors',
      queryParameters: {'page': page, 'size': size},
    );
    return _extractPageContent(resp.data).map(Author.fromJson).toList();
  }

  Future<Author> getAuthorDetail(int authorId) async {
    final resp = await _dio.get('/app/authors/$authorId');
    return Author.fromJson(resp.data as Map<String, dynamic>);
  }

  /// There's no "books by author ID" endpoint — `BookListRequest.authors`
  /// filters by name, the same filter dimension the library screen's author
  /// filter uses.
  Future<List<Book>> getBooksByAuthor(
    String authorName, {
    int page = 0,
    int size = 100,
  }) async {
    final resp = await _dio.get(
      '/app/books',
      queryParameters: {
        'page': page,
        'size': size,
        'authors': [authorName],
      },
    );
    return _extractPageContent(resp.data).map(Book.fromJson).toList();
  }

  // ── Shelves (AppShelfController) ────────────────────────────────────────

  Future<List<Shelf>> getShelves() async {
    final resp = await _dio.get('/app/shelves');
    return (resp.data as List)
        .map((s) => Shelf.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<List<MagicShelf>> getMagicShelves() async {
    final resp = await _dio.get('/app/shelves/magic');
    return (resp.data as List)
        .map((s) => MagicShelf.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<List<Book>> getMagicShelfBooks(
    int magicShelfId, {
    int page = 0,
    int size = 100,
  }) async {
    final resp = await _dio.get(
      '/app/shelves/magic/$magicShelfId/books',
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

  /// Exactly one of [positionMs] (audiobook) or [cfi] (EPUB) should be
  /// given, matching `CreateBookMarkRequest`'s own
  /// `isAudiobookBookmark()`/CFI-based distinction (Grimmory source).
  Future<Bookmark> createBookmark(
    int bookId, {
    int? positionMs,
    int? trackIndex,
    String? cfi,
    String? title,
  }) async {
    final resp = await _dio.post(
      '/bookmarks',
      data: {
        'bookId': bookId,
        'positionMs': ?positionMs,
        'trackIndex': ?trackIndex,
        'cfi': ?cfi,
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
