import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/api/api_client.dart';
import 'package:grimmory/core/api/models.dart';
import 'package:grimmory/features/player/browse_tree.dart';

class _FakeApi implements ApiClient {
  int continueCalls = 0;
  bool failContinue = false;

  @override
  Future<List<Book>> getContinueListening({int limit = 10}) async {
    continueCalls++;
    if (failContinue) throw StateError('offline');
    return const [
      Book(
        id: 1,
        title: 'One',
        authors: ['A', 'B'],
        primaryFileType: 'AUDIOBOOK',
      ),
    ];
  }

  @override
  Future<List<Book>> getSeriesBooks(
    String seriesName, {
    int page = 0,
    int size = 100,
  }) async => const [
    Book(id: 2, title: 'Audio', primaryFileType: 'AUDIOBOOK'),
    Book(id: 3, title: 'Epub', primaryFileType: 'EPUB'),
  ];

  @override
  Future<List<Library>> getLibraries() async => const [
    Library(id: 9, name: 'Main'),
  ];

  @override
  String coverUrl(int bookId, {String? version}) =>
      'https://x.test/cover/$bookId${version == null ? '' : '?v=$version'}';

  @override
  Map<String, String> get authHeaders => const {'Authorization': 'Bearer t'};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeApi api;
  late DateTime clock;
  late BrowseTree tree;

  setUp(() {
    api = _FakeApi();
    clock = DateTime(2026, 9, 4, 12);
    tree = BrowseTree(api, now: () => clock);
  });

  test('root lists the three fixed entries without touching the API', () async {
    final root = await tree.children(AudioService.browsableRootId);
    expect(root.map((i) => i.id), [
      BrowseTree.rootContinueListening,
      BrowseTree.rootLibraries,
      BrowseTree.rootSeries,
    ]);
    expect(root.every((i) => !i.playable!), isTrue);
    expect(api.continueCalls, 0);
  });

  test('leaves carry the book id, joined authors and authed art', () async {
    final items = await tree.children(BrowseTree.rootContinueListening);
    final leaf = items.single;
    expect(leaf.id, '1');
    expect(leaf.artist, 'A, B');
    expect(leaf.playable, isTrue);
    expect(leaf.extras?['bookId'], 1);
    expect(leaf.artUri.toString(), 'https://x.test/cover/1');
    expect(leaf.artHeaders, {'Authorization': 'Bearer t'});
  });

  test('a failing level renders empty instead of erroring', () async {
    api.failContinue = true;
    expect(await tree.children(BrowseTree.rootContinueListening), isEmpty);
  });

  test('series children are filtered to audiobooks', () async {
    final items = await tree.children(
      'series:${Uri.encodeComponent('The Expanse')}',
    );
    expect(items.map((i) => i.id), ['2']);
  });

  test('libraries become browsable folders', () async {
    final items = await tree.children(BrowseTree.rootLibraries);
    expect(items.single.id, 'lib:9');
    expect(items.single.playable, isFalse);
  });

  test('a level is memoised for the cache TTL, then refetched', () async {
    await tree.children(BrowseTree.rootContinueListening);
    await tree.children(BrowseTree.rootContinueListening);
    expect(api.continueCalls, 1);

    clock = clock.add(const Duration(seconds: 61));
    await tree.children(BrowseTree.rootContinueListening);
    expect(api.continueCalls, 2);
  });

  test('a failure is not cached', () async {
    api.failContinue = true;
    await tree.children(BrowseTree.rootContinueListening);
    api.failContinue = false;
    expect(await tree.children(BrowseTree.rootContinueListening), hasLength(1));
  });
}
