import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grimmory/core/api/api_client.dart';
import 'package:grimmory/core/api/models.dart';

typedef _Handler = ResponseBody Function(RequestOptions options);

/// Answers requests in-process. Everything above the adapter — the auth
/// interceptor, retry logic, base URL, JSON transformer — runs for real.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  _Handler handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object? data, {int status = 200}) => ResponseBody.fromString(
  jsonEncode(data),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

DioException _connectionError(RequestOptions options) =>
    DioException.connectionError(requestOptions: options, reason: 'refused');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApiClient client;
  late _FakeAdapter adapter;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'server_url': 'https://books.test',
    });
    FlutterSecureStorage.setMockInitialValues({'refresh_token': 'refresh-1'});
    final prefs = await SharedPreferences.getInstance();
    client = ApiClient(
      prefs,
      const FlutterSecureStorage(),
      initialToken: 'token-1',
    );
    adapter = _FakeAdapter((_) => _json(<String, dynamic>{}));
    client.httpClientAdapter = adapter;
  });

  test('prefixes /api/v1 and attaches the bearer token', () async {
    adapter.handler = (_) => _json([]);
    await client.getLibraries();

    final request = adapter.requests.single;
    expect(request.uri.toString(), 'https://books.test/api/v1/libraries');
    expect(request.headers['Authorization'], 'Bearer token-1');
    expect(client.authHeaders, {'Authorization': 'Bearer token-1'});
  });

  group('progress writes', () {
    // Grimmory stores progress per file; the deprecated per-type fields
    // alone persist nothing for audiobooks and are dropped for an EPUB
    // whose library format priority makes an audiobook file primary. The
    // fileProgress block is what actually lands — its encoding has to match
    // the web client's exactly (positions as strings, trackIndex in href).
    test('audiobook sends fileProgress keyed on bookFileId', () async {
      await client.updateAudiobookProgress(
        5,
        const AudiobookProgress(
          positionMs: 3500,
          trackIndex: 2,
          trackPositionMs: 500,
          percentage: 12.3,
        ),
        bookFileId: 55,
      );

      final request = adapter.requests.single;
      expect(request.method, 'PUT');
      expect(request.path, '/app/books/5/progress');
      final body = request.data as Map<String, dynamic>;
      expect(body['fileProgress'], {
        'bookFileId': 55,
        'positionData': '3500',
        'positionHref': '2',
        'progressPercent': 12.3,
      });
      expect(body['audiobookProgress'], {
        'positionMs': 3500,
        'trackIndex': 2,
        'trackPositionMs': 500,
        'percentage': 12.3,
      });
    });

    test('audiobook omits fileProgress without a bookFileId', () async {
      await client.updateAudiobookProgress(
        5,
        const AudiobookProgress(positionMs: 100, percentage: 0.1),
        bookFileId: null,
      );

      final body = adapter.requests.single.data as Map<String, dynamic>;
      expect(body.containsKey('fileProgress'), isFalse);
      expect(body['audiobookProgress']['trackIndex'], isNull);
    });

    test('single-file audiobook leaves positionHref null', () async {
      await client.updateAudiobookProgress(
        5,
        const AudiobookProgress(positionMs: 100, percentage: 0.1),
        bookFileId: 55,
      );

      final body = adapter.requests.single.data as Map<String, dynamic>;
      expect(body['fileProgress']['positionHref'], isNull);
    });

    test('epub sends the CFI as positionData', () async {
      await client.updateEpubProgress(
        7,
        const EpubProgress(cfi: 'epubcfi(/6/4!/4/2)', percentage: 3.2),
        bookFileId: 71,
      );

      final request = adapter.requests.single;
      expect(request.path, '/app/books/7/progress');
      final body = request.data as Map<String, dynamic>;
      expect(body['fileProgress'], {
        'bookFileId': 71,
        'positionData': 'epubcfi(/6/4!/4/2)',
        'positionHref': null,
        'progressPercent': 3.2,
      });
      expect(body['epubProgress']['cfi'], 'epubcfi(/6/4!/4/2)');
      expect(body['epubProgress']['percentage'], 3.2);
    });
  });

  // `/app/books/continue-reading` and `/continue-listening` return [] for
  // admin accounts (their null "all libraries" set is passed straight into
  // a JPQL IN clause), so the carousels are built from the filtered list
  // endpoint instead — the same recipe as the web dashboard.
  group('continue reading/listening', () {
    Map<String, dynamic> summary(int id, {String? lastReadTime}) => {
      'id': id,
      'title': 'Book $id',
      'readStatus': 'READING',
      'readProgress': 12.5,
      'lastReadTime': lastReadTime,
    };

    test('reading queries the list endpoint for in-progress ebooks', () async {
      adapter.handler = (_) => _json({'content': [], 'page': 0});
      await client.getContinueReading();

      final request = adapter.requests.single;
      expect(request.path, '/app/books');
      expect(request.queryParameters, {
        'status': 'READING,RE_READING',
        'fileType': 'EPUB,PDF,CBX,FB2,MOBI,AZW3',
        'page': 0,
        'size': 50,
      });
      // Comma-joined single values, never Dio's bracketed list encoding.
      expect(request.uri.query, contains('status=READING%2CRE_READING'));
      expect(request.uri.query, isNot(contains('%5B%5D')));
    });

    test('listening asks for audiobooks only', () async {
      adapter.handler = (_) => _json({'content': [], 'page': 0});
      await client.getContinueListening(limit: 3);
      expect(adapter.requests.single.queryParameters['fileType'], 'AUDIOBOOK');
    });

    test('orders by lastReadTime desc, drops undated, applies limit', () async {
      adapter.handler = (_) => _json({
        'content': [
          summary(1, lastReadTime: '2026-09-01T10:00:00Z'),
          summary(2),
          summary(3, lastReadTime: '2026-09-05T00:37:01Z'),
          summary(4, lastReadTime: '2026-09-04T21:38:42Z'),
        ],
        'page': 0,
      });

      final books = await client.getContinueReading(limit: 2);
      expect(books.map((b) => b.id), [3, 4]);
      expect(books.first.lastReadTime, DateTime.utc(2026, 9, 5, 0, 37, 1));
    });
  });

  group('dashboard', () {
    // The web stores its dashboard layout in the user's settings on
    // /users/me; the phone reads the same field so the two agree.
    test('reads the saved layout from the user settings', () async {
      adapter.handler = (_) => _json({
        'id': 1,
        'username': 'someone',
        'userSettings': {
          'filterMode': 'and',
          'dashboardConfig': {
            'scrollers': [
              {
                'id': '2',
                'type': 'lastRead',
                'title': 'dashboard.scroller.continueReading',
                'enabled': true,
                'order': 1,
                'maxItems': 12,
                'magicShelfId': null,
                'sortField': null,
                'sortDirection': null,
              },
              {
                'id': 'x1',
                'type': 'magicShelf',
                'title': 'Cosy Fantasy',
                'enabled': true,
                'order': 2,
                'maxItems': null,
                'magicShelfId': 7,
              },
            ],
          },
        },
      });

      final config = await client.getDashboardConfig();
      expect(adapter.requests.single.path, '/users/me');
      expect(config?.scrollers, hasLength(2));
      expect(config?.scrollers.first.kind, ScrollerType.lastRead);
      expect(config?.scrollers.first.maxItems, 12);
      expect(config?.scrollers.last.magicShelfId, 7);
      expect(config?.scrollers.last.maxItems, isNull);
    });

    test('is null until the user has customised the web dashboard', () async {
      adapter.handler = (_) => _json({'id': 1, 'userSettings': {}});
      expect(await client.getDashboardConfig(), isNull);

      adapter.handler = (_) => _json({'id': 1, 'userSettings': null});
      expect(await client.getDashboardConfig(), isNull);
    });

    test('random books are a scoped page of the random endpoint', () async {
      adapter.handler = (_) => _json({'content': [], 'page': 0});
      await client.getRandomBooks(size: 40, libraryId: 3);

      final request = adapter.requests.single;
      expect(request.path, '/app/books/random');
      expect(request.queryParameters, {'page': 0, 'size': 40, 'libraryId': 3});
    });
  });

  group('progress reads', () {
    test('audiobook parses a real row', () async {
      adapter.handler = (_) => _json({
        'readProgress': null,
        'audiobookProgress': {
          'positionMs': 3500,
          'trackIndex': 2,
          'percentage': 12.3,
          'updatedAt': '2026-09-04T18:26:03Z',
        },
      });

      final progress = await client.getAudiobookProgress(5);
      expect(progress?.positionMs, 3500);
      expect(progress?.trackIndex, 2);
      expect(progress?.percentage, 12.3);
    });

    // A save made through the deprecated shim by an older build leaves a
    // file-progress row with only lastReadTime set, which the server maps
    // to positionMs: null — that must read as "no progress", not throw.
    test('audiobook treats a hollow row as no progress', () async {
      adapter.handler = (_) => _json({
        'audiobookProgress': {'positionMs': null, 'percentage': null},
      });
      expect(await client.getAudiobookProgress(5), isNull);

      adapter.handler = (_) => _json({'audiobookProgress': null});
      expect(await client.getAudiobookProgress(5), isNull);
    });

    test('reads return null on 404 but rethrow other failures', () async {
      adapter.handler = (_) => _json({'status': 404}, status: 404);
      expect(await client.getAudiobookProgress(5), isNull);
      expect(await client.getEpubProgress(5), isNull);

      adapter.handler = (_) => _json({'status': 500}, status: 500);
      expect(client.getEpubProgress(5), throwsA(isA<DioException>()));
    });

    test('epub parses cfi and percentage', () async {
      adapter.handler = (_) => _json({
        'epubProgress': {'cfi': 'epubcfi(/6/50!/4)', 'percentage': 44.2},
      });

      final progress = await client.getEpubProgress(49);
      expect(progress?.cfi, 'epubcfi(/6/50!/4)');
      expect(progress?.href, isNull);
      expect(progress?.percentage, 44.2);
    });
  });

  group('auth interceptor', () {
    test('refreshes on 401 and retries with the new token', () async {
      adapter.handler = (options) {
        if (options.path == '/auth/refresh') {
          return _json({'accessToken': 'token-2', 'refreshToken': 'refresh-2'});
        }
        if (options.headers['Authorization'] == 'Bearer token-1') {
          return _json({'status': 401}, status: 401);
        }
        return _json({'id': 1, 'title': 'Retried'});
      };

      final book = await client.getBook(1);

      expect(book.title, 'Retried');
      expect(client.token, 'token-2');
      final paths = adapter.requests.map((r) => r.path).toList();
      expect(paths, ['/app/books/1', '/auth/refresh', '/app/books/1']);
      expect(adapter.requests[1].data, {'refreshToken': 'refresh-1'});
      expect(adapter.requests.last.headers['Authorization'], 'Bearer token-2');
    });

    test('does not try to refresh a 401 from the auth endpoints', () async {
      adapter.handler = (_) => _json({'status': 401}, status: 401);

      await expectLater(
        client.login('user', 'wrong'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.requests.map((r) => r.path), ['/auth/login']);
      expect(client.token, 'token-1');
    });

    test('retries a GET exactly once on a connection error', () async {
      var attempts = 0;
      adapter.handler = (options) {
        attempts++;
        if (attempts == 1) throw _connectionError(options);
        return _json([]);
      };

      expect(await client.getLibraries(), isEmpty);
      expect(attempts, 2);
    });

    test('gives up after the single GET retry', () async {
      adapter.handler = (options) => throw _connectionError(options);

      await expectLater(client.getLibraries(), throwsA(isA<DioException>()));
      expect(adapter.requests, hasLength(2));
    });

    test('never retries a mutating request on a connection error', () async {
      adapter.handler = (options) => throw _connectionError(options);

      await expectLater(
        client.updateEpubProgress(
          7,
          const EpubProgress(cfi: 'x', percentage: 1),
          bookFileId: null,
        ),
        throwsA(isA<DioException>()),
      );
      expect(adapter.requests, hasLength(1));
    });
  });

  group('token expiry', () {
    test(
      'refreshes ahead of a known expiry instead of waiting for a 401',
      () async {
        adapter.handler = (options) {
          if (options.path == '/auth/login') {
            return _json({
              'accessToken': 'token-short',
              'refreshToken': 'refresh-1',
              'expires': DateTime.now()
                  .add(const Duration(seconds: 30))
                  .millisecondsSinceEpoch,
            });
          }
          if (options.path == '/auth/refresh') {
            return _json({
              'accessToken': 'token-2',
              'refreshToken': 'refresh-2',
              'expires': DateTime.now()
                  .add(const Duration(hours: 1))
                  .millisecondsSinceEpoch,
            });
          }
          return _json([]);
        };

        await client.login('user', 'pw');
        await client.getLibraries();

        expect(adapter.requests.map((r) => r.path), [
          '/auth/login',
          '/auth/refresh',
          '/libraries',
        ]);
        expect(
          adapter.requests.last.headers['Authorization'],
          'Bearer token-2',
        );
        expect(client.token, 'token-2');
      },
    );

    test('a token with a distant expiry is used as-is', () async {
      adapter.handler = (options) {
        if (options.path == '/auth/login') {
          return _json({
            'accessToken': 'token-long',
            'refreshToken': 'refresh-1',
            'expires': DateTime.now()
                .add(const Duration(hours: 2))
                .millisecondsSinceEpoch,
          });
        }
        return _json([]);
      };

      await client.login('user', 'pw');
      await client.getLibraries();

      expect(adapter.requests.map((r) => r.path), [
        '/auth/login',
        '/libraries',
      ]);
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer token-long',
      );
    });
  });

  test(
    'downloadFile streams through the authed client with no receive timeout',
    () async {
      final dir = await Directory.systemTemp.createTemp('grimreader_api_');
      addTearDown(() => dir.delete(recursive: true));
      final path = '${dir.path}/track_0.mp3';
      final bytes = List<int>.generate(64, (i) => i);
      adapter.handler = (_) =>
          ResponseBody.fromBytes(Uint8List.fromList(bytes), 200);

      var lastProgress = 0;
      await client.downloadFile(
        'https://books.test/api/v1/audiobooks/5/track/0/stream',
        path,
        onReceiveProgress: (received, _) => lastProgress = received,
      );

      final request = adapter.requests.single;
      expect(
        request.uri.toString(),
        'https://books.test/api/v1/audiobooks/5/track/0/stream',
      );
      expect(request.headers['Authorization'], 'Bearer token-1');
      expect(request.receiveTimeout, Duration.zero);
      expect(await File(path).readAsBytes(), bytes);
      expect(lastProgress, 64);
    },
  );

  test('cover URLs carry the version only when one is known', () {
    expect(
      client.coverUrl(5),
      'https://books.test/api/v1/media/book/5/audiobook-cover',
    );
    expect(
      client.coverUrl(5, version: '1725000000000'),
      'https://books.test/api/v1/media/book/5/audiobook-cover?v=1725000000000',
    );
    expect(
      client.fallbackCoverUrl(5, version: 'a b'),
      'https://books.test/api/v1/media/book/5/cover?v=a+b',
    );
  });

  test('paginated /app lists are unwrapped from "content"', () async {
    adapter.handler = (_) => _json({
      'content': [
        {
          'seriesName': 'The Expanse',
          'bookCount': 9,
          'authors': ['J. Corey'],
        },
      ],
      'page': 0,
      'size': 100,
      'totalElements': 1,
    });

    final series = await client.getSeries();
    expect(series.single.seriesName, 'The Expanse');
    expect(series.single.bookCount, 9);
  });
}
