import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/api/models.dart';

void main() {
  // Grimmory's entity IDs are numeric (Java `Long`), not strings — the bug
  // that originally broke the Libraries screen when a real instance's
  // response hit `int` where the app assumed `String`. These lock that
  // parsing in.

  test('Library.fromJson parses a numeric id', () {
    final library = Library.fromJson({
      'id': 42,
      'name': 'Audiobooks',
      'bookCount': 7,
    });
    expect(library.id, 42);
    expect(library.name, 'Audiobooks');
    expect(library.bookCount, 7);
  });

  test('Book.fromJson parses authors as a list and a numeric id', () {
    final book = Book.fromJson({
      'id': 100,
      'title': 'The Hobbit',
      'authors': ['J.R.R. Tolkien'],
      'seriesName': 'Middle-earth',
      'narrator': 'Rob Inglis',
    });
    expect(book.id, 100);
    expect(book.authors, ['J.R.R. Tolkien']);
    expect(book.seriesName, 'Middle-earth');
    expect(book.narrator, 'Rob Inglis');
  });

  test('Book.fromJson tolerates a summary response with no authors key', () {
    final book = Book.fromJson({'id': 1, 'title': 'Untitled'});
    expect(book.authors, isEmpty);
    expect(book.seriesName, isNull);
  });

  test(
    'AudiobookInfo.fromJson parses a folder-based book with tracks',
    () {
      final info = AudiobookInfo.fromJson({
        'bookId': 5,
        'durationMs': 3600000,
        'folderBased': true,
        'tracks': [
          {
            'index': 0,
            'fileName': 'part1.mp3',
            'title': 'Part 1',
            'durationMs': 1800000,
            'cumulativeStartMs': 0,
          },
          {
            'index': 1,
            'fileName': 'part2.mp3',
            'title': 'Part 2',
            'durationMs': 1800000,
            'cumulativeStartMs': 1800000,
          },
        ],
      });
      expect(info.folderBased, isTrue);
      expect(info.tracks, hasLength(2));
      expect(info.tracks[1].cumulativeStartMs, 1800000);
    },
  );

  test(
    'AudiobookInfo.fromJson parses a single-stream book with chapters',
    () {
      final info = AudiobookInfo.fromJson({
        'bookId': 6,
        'durationMs': 7200000,
        'folderBased': false,
        'chapters': [
          {
            'index': 0,
            'title': 'Chapter 1',
            'startTimeMs': 0,
            'endTimeMs': 600000,
            'durationMs': 600000,
          },
        ],
      });
      expect(info.folderBased, isFalse);
      expect(info.tracks, isEmpty);
      expect(info.chapters, hasLength(1));
      expect(info.chapters.first.title, 'Chapter 1');
    },
  );

  test('AudiobookProgress round-trips through toJson/fromJson', () {
    const progress = AudiobookProgress(
      positionMs: 12345,
      trackIndex: 2,
      trackPositionMs: 500,
      percentage: 0.42,
    );
    final roundTripped = AudiobookProgress.fromJson(progress.toJson());
    expect(roundTripped, progress);
  });

  test('Bookmark.fromJson uses "notes", not "note"', () {
    final bookmark = Bookmark.fromJson({
      'id': 9,
      'bookId': 5,
      'positionMs': 1000,
      'notes': 'Great scene',
    });
    expect(bookmark.notes, 'Great scene');
  });
}
