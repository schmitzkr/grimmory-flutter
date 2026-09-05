import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/api/models.dart';
import 'package:grimmory/features/library/dashboard.dart';

void main() {
  group('normalizeDashboard', () {
    // The web's normalizeConfig: no config, or one with no scrollers,
    // means the stock four in the stock order.
    test('falls back to the web defaults', () {
      expect(normalizeDashboard(null), dashboardDefaultScrollers);
      expect(
        normalizeDashboard(const DashboardConfig(scrollers: [])),
        dashboardDefaultScrollers,
      );
      expect(dashboardDefaultScrollers.map((s) => s.type), [
        'lastListened',
        'lastRead',
        'latestAdded',
        'random',
      ]);
    });

    test(
      'keeps enabled rows only, in order, and drops what it cannot render',
      () {
        final rows = normalizeDashboard(
          const DashboardConfig(
            scrollers: [
              DashboardScroller(id: 'c', type: 'random', order: 3),
              DashboardScroller(id: 'a', type: 'lastRead', order: 1),
              DashboardScroller(
                id: 'off',
                type: 'latestAdded',
                order: 0,
                enabled: false,
              ),
              DashboardScroller(
                id: 'b',
                type: 'magicShelf',
                order: 2,
                magicShelfId: 7,
              ),
              DashboardScroller(id: 'orphan', type: 'magicShelf', order: 4),
              DashboardScroller(
                id: 'new',
                type: 'somethingUpstreamAdded',
                order: 5,
              ),
            ],
          ),
        );
        expect(rows.map((s) => s.id), ['a', 'b', 'c']);
      },
    );
  });

  group('scrollerTitle', () {
    test('translates the web\'s stock keys and passes custom text through', () {
      expect(
        scrollerTitle(
          const DashboardScroller(
            type: 'lastRead',
            title: 'dashboard.scroller.continueReading',
          ),
        ),
        'Continue Reading',
      );
      expect(
        scrollerTitle(
          const DashboardScroller(
            type: 'random',
            title: 'dashboard.scroller.discoverNew',
          ),
        ),
        'Discover Something New',
      );
      expect(
        scrollerTitle(
          const DashboardScroller(type: 'magicShelf', title: 'Cosy Fantasy'),
        ),
        'Cosy Fantasy',
      );
    });

    test('names a row by type when the title is blank', () {
      expect(
        scrollerTitle(
          const DashboardScroller(type: 'lastListened', title: ' '),
        ),
        'Continue Listening',
      );
      expect(
        scrollerTitle(const DashboardScroller(type: 'latestAdded')),
        'Recently Added',
      );
    });
  });

  group('sortBooks', () {
    Book book(
      int id,
      String title, {
      DateTime? added,
      List<String> authors = const [],
    }) => Book(id: id, title: title, addedOn: added, authors: authors);

    test('orders titles naturally and case-insensitively', () {
      final books = [book(1, 'Book 10'), book(2, 'book 2'), book(3, 'Another')];
      expect(sortBooks(books, 'title', 'asc').map((b) => b.id), [3, 2, 1]);
      expect(sortBooks(books, 'title', 'desc').map((b) => b.id), [1, 2, 3]);
    });

    // The web compares null against a value as "after", then flips the
    // whole result for desc — so blanks lead a descending row.
    test('puts missing values last ascending and first descending', () {
      final books = [
        book(1, 'a', added: DateTime.utc(2026, 1, 1)),
        book(2, 'b'),
        book(3, 'c', added: DateTime.utc(2026, 3, 1)),
      ];
      expect(sortBooks(books, 'addedOn', 'asc').map((b) => b.id), [1, 3, 2]);
      expect(sortBooks(books, 'addedOn', 'desc').map((b) => b.id), [2, 3, 1]);
    });

    test('leaves the order alone for an unknown or unsupported field', () {
      final books = [book(2, 'b'), book(1, 'a')];
      expect(sortBooks(books, 'publisher', 'asc'), books);
      expect(sortBooks(books, null, 'asc'), books);
      expect(sortBooks(books, '', 'desc'), books);
    });

    test('sorts by first author', () {
      final books = [
        book(1, 'x', authors: ['Zed']),
        book(2, 'y', authors: ['Abe', 'Zed']),
        book(3, 'z'),
      ];
      expect(sortBooks(books, 'author', 'asc').map((b) => b.id), [2, 1, 3]);
    });
  });

  group('discoverPick', () {
    Book book(int id, {String? status}) =>
        Book(id: id, title: 'Book $id', readStatus: status);

    test('leaves out started, finished and set-aside books', () {
      final picked = discoverPick(
        [
          book(1, status: 'READ'),
          book(2, status: 'READING'),
          book(3, status: 'PAUSED'),
          book(4, status: 'WONT_READ'),
          book(5, status: 'ABANDONED'),
          book(6, status: 'PARTIALLY_READ'),
          book(7, status: 'UNREAD'),
          book(8, status: 'UNSET'),
          book(9),
        ],
        max: 20,
        random: Random(1),
      );
      expect(picked.map((b) => b.id).toSet(), {7, 8, 9});
    });

    test('shuffles and cuts to max', () {
      final books = [for (var i = 1; i <= 10; i++) book(i)];
      final picked = discoverPick(books, max: 4, random: Random(42));
      expect(picked, hasLength(4));
      expect(picked.map((b) => b.id).toSet().length, 4);
      // A different seed gives a different order — it really is shuffled.
      final other = discoverPick(books, max: 10, random: Random(7));
      expect(
        other.map((b) => b.id),
        isNot(
          discoverPick(books, max: 10, random: Random(42)).map((b) => b.id),
        ),
      );
    });
  });
}
