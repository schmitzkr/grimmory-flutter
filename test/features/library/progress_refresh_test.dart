import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/api/models.dart';
import 'package:grimmory/features/book/book_detail_screen.dart';
import 'package:grimmory/features/library/continue_listening_section.dart';
import 'package:grimmory/features/library/continue_reading_section.dart';
import 'package:grimmory/features/library/library_detail_screen.dart';
import 'package:grimmory/features/library/progress_refresh.dart';
import 'package:grimmory/features/library/recently_added_section.dart';

const _query = (
  libraryId: 1,
  sort: LibrarySort.dateAddedNewest,
  author: null,
  type: LibraryTypeFilter.all,
);

void main() {
  late ProviderContainer container;
  final calls = <String, int>{};

  void count(String key) => calls[key] = (calls[key] ?? 0) + 1;

  setUp(() {
    calls.clear();
    container = ProviderContainer.test(
      overrides: [
        bookProvider.overrideWith((ref, id) async {
          count('book:$id');
          return Book(id: id, title: 'Book $id');
        }),
        continueReadingProvider.overrideWith((ref) async {
          count('continueReading');
          return <Book>[];
        }),
        continueListeningProvider.overrideWith((ref) async {
          count('continueListening');
          return <Book>[];
        }),
        recentlyAddedProvider.overrideWith((ref, libraryId) async {
          count('recentlyAdded:$libraryId');
          return <Book>[];
        }),
        libraryBooksProvider.overrideWith((ref, query) async {
          count('libraryBooks');
          return <Book>[];
        }),
      ],
    );
  });

  // The screens holding these providers are always underneath the reader
  // or player when progress is saved, and Riverpod 3 pauses their
  // subscriptions there — a plain invalidate of a provider with only paused
  // listeners just marks it dirty and never recomputes. Reading it after
  // invalidating is what forces the refetch now.
  test('recomputes every live provider immediately', () {
    container.read(bookProvider(1));
    container.read(continueReadingProvider);
    container.read(continueListeningProvider);
    container.read(recentlyAddedProvider(null));
    expect(calls['book:1'], 1);

    refreshProgressConsumers(container, bookId: 1);

    expect(calls['book:1'], 2);
    expect(calls['continueReading'], 2);
    expect(calls['continueListening'], 2);
    expect(calls['recentlyAdded:null'], 2);
  });

  test('never instantiates a provider nothing has read yet', () {
    container.read(bookProvider(1));

    refreshProgressConsumers(container, bookId: 1);

    expect(calls['book:1'], 2);
    expect(calls.containsKey('continueReading'), isFalse);
    expect(calls.containsKey('continueListening'), isFalse);
    expect(calls.containsKey('recentlyAdded:null'), isFalse);
    expect(container.exists(continueReadingProvider), isFalse);
  });

  test('only refreshes the book that was read, not other cached books', () {
    container.read(bookProvider(1));
    container.read(bookProvider(2));

    refreshProgressConsumers(container, bookId: 2);

    expect(calls['book:1'], 1);
    expect(calls['book:2'], 2);
  });

  test('targets the unscoped Recently Added row the Home tab shows', () {
    container.read(recentlyAddedProvider(7));
    container.read(recentlyAddedProvider(null));

    refreshProgressConsumers(container, bookId: 1);

    expect(calls['recentlyAdded:null'], 2);
    expect(calls['recentlyAdded:7'], 1);
  });

  test('marks library grids dirty so they refetch on their next read', () {
    container.read(libraryBooksProvider(_query));
    expect(calls['libraryBooks'], 1);

    refreshProgressConsumers(container, bookId: 1);
    expect(calls['libraryBooks'], 1);

    container.read(libraryBooksProvider(_query));
    expect(calls['libraryBooks'], 2);
  });
}
