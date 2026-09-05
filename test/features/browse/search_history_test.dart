import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/features/browse/search_history.dart';

void main() {
  test('puts the newest query first and drops its older duplicate', () {
    expect(rememberSearch(['carl', 'dungeon'], 'Dungeon '), [
      'Dungeon',
      'carl',
    ]);
  });

  test('ignores blank queries', () {
    expect(rememberSearch(['carl'], '   '), ['carl']);
  });

  test('caps the history', () {
    final history = List.generate(searchHistoryMax, (i) => 'q$i');
    final next = rememberSearch(history, 'new');
    expect(next, hasLength(searchHistoryMax));
    expect(next.first, 'new');
    expect(next, isNot(contains('q${searchHistoryMax - 1}')));
  });
}
