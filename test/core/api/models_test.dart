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
    expect(book.files, isEmpty);
    expect(book.ebookFileId, isNull);
  });

  // File-level progress saves are keyed on the EPUB file's own id, not the
  // book's — and on a book that also has an audiobook file with higher
  // library format priority, the audiobook is the primary file, so
  // "primary" alone would pick the wrong one.
  test('Book.ebookFileId skips a primary audiobook file for the EPUB', () {
    final book = Book.fromJson({
      'id': 7,
      'title': 'Dual format',
      'primaryFileType': 'AUDIOBOOK',
      'files': [
        {'id': 70, 'bookType': 'AUDIOBOOK', 'primary': true},
        {'id': 71, 'bookType': 'EPUB', 'primary': false},
      ],
    });
    expect(book.files, hasLength(2));
    expect(book.ebookFileId, 71);
  });

  test('Book.ebookFileId prefers the primary file among several ebooks', () {
    final book = Book.fromJson({
      'id': 8,
      'title': 'Multi ebook',
      'files': [
        {'id': 80, 'bookType': 'MOBI'},
        {'id': 81, 'bookType': 'EPUB', 'primary': true},
      ],
    });
    expect(book.ebookFileId, 81);
  });

  // `AppBookFile` is a Lombok @Data class: its `boolean isPrimary` field
  // serialises under the property name `primary` (Jackson strips the `is`
  // from the generated `isPrimary()` getter), so the Dart-side field name is
  // NOT the JSON key. A model keyed on `isPrimary` silently never sees it.
  test('BookFile.fromJson reads the primary flag from the "primary" key', () {
    expect(
      BookFile.fromJson({
        'id': 1,
        'bookType': 'EPUB',
        'primary': true,
      }).isPrimary,
      isTrue,
    );
    expect(
      BookFile.fromJson({
        'id': 1,
        'bookType': 'EPUB',
        'isPrimary': true,
      }).isPrimary,
      isFalse,
    );
    expect(BookFile.fromJson({'id': 1}).folderBased, isFalse);
  });

  test('EpubProgress and AudiobookProgress parse a server response', () {
    final epub = EpubProgress.fromJson({
      'cfi': 'epubcfi(/6/4!/4/2)',
      'href': null,
      'percentage': 44.2,
    });
    expect(epub.cfi, 'epubcfi(/6/4!/4/2)');
    expect(epub.href, isNull);
    expect(epub.percentage, 44.2);

    final audio = AudiobookProgress.fromJson({
      'positionMs': 3500,
      'trackIndex': 2,
      'percentage': 12.3,
      'updatedAt': '2026-09-04T18:26:03Z',
    });
    expect(audio.positionMs, 3500);
    expect(audio.trackIndex, 2);
    expect(audio.trackPositionMs, isNull);
    expect(audio.percentage, 12.3);
  });

  test('normalizedReadProgress treats every type as 0-100', () {
    expect(
      const Book(
        id: 1,
        title: 't',
        primaryFileType: 'AUDIOBOOK',
        readProgress: 42,
      ).normalizedReadProgress,
      closeTo(0.42, 1e-9),
    );
    expect(
      const Book(
        id: 2,
        title: 't',
        primaryFileType: 'EPUB',
        readProgress: 42,
      ).normalizedReadProgress,
      closeTo(0.42, 1e-9),
    );
  });

  test('AudiobookInfo.fromJson parses a folder-based book with tracks', () {
    final info = AudiobookInfo.fromJson({
      'bookId': 5,
      'bookFileId': 55,
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
    expect(info.bookFileId, 55);
    expect(info.tracks, hasLength(2));
    expect(info.tracks[1].cumulativeStartMs, 1800000);
  });

  test('AudiobookInfo.fromJson parses a single-stream book with chapters', () {
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
    // A cached info.json from before bookFileId was parsed still loads.
    expect(info.bookFileId, isNull);
    expect(info.tracks, isEmpty);
    expect(info.chapters, hasLength(1));
    expect(info.chapters.first.title, 'Chapter 1');
  });

  test('AudiobookProgress round-trips through toJson/fromJson', () {
    const progress = AudiobookProgress(
      positionMs: 12345,
      trackIndex: 2,
      trackPositionMs: 500,
      percentage: 42.0,
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

  test('Series parses read counts and cover books', () {
    final series = Series.fromJson({
      'seriesName': 'The Expanse',
      'bookCount': 9,
      'seriesTotal': 12,
      'booksRead': 3,
      'latestAddedOn': '2026-09-01T00:00:00Z',
      'coverBooks': [
        {
          'bookId': 41,
          'coverUpdatedOn': '2026-08-30T10:00:00Z',
          'seriesNumber': 1.0,
          'primaryFileType': 'AUDIOBOOK',
        },
      ],
    });
    expect(series.seriesTotal, 12);
    expect(series.booksRead, 3);
    expect(series.coverBooks.single.bookId, 41);
    expect(series.coverBooks.single.coverVersion, isNotNull);
    expect(Series.fromJson({'seriesName': 'x', 'bookCount': 1}).booksRead, 0);
  });

  test('Author.hasPhoto and shelf publicShelf parse their Lombok keys', () {
    expect(
      Author.fromJson({'id': 1, 'name': 'A', 'hasPhoto': true}).hasPhoto,
      isTrue,
    );
    expect(Author.fromJson({'id': 1, 'name': 'A'}).hasPhoto, isFalse);
    expect(
      Shelf.fromJson({'id': 2, 'name': 'S', 'publicShelf': true}).publicShelf,
      isTrue,
    );
    expect(
      MagicShelf.fromJson({
        'id': 3,
        'name': 'M',
        'icon': 'pi-heart',
        'iconType': 'prime',
        'publicShelf': false,
      }).icon,
      'pi-heart',
    );
  });

  test('FilterOptions parses the fileTypes facet', () {
    final options = FilterOptions.fromJson({
      'authors': [],
      'fileTypes': [
        {'name': 'AUDIOBOOK', 'count': 12},
        {'name': 'EPUB', 'count': 30},
      ],
    });
    expect(options.fileTypes.map((f) => f.name), ['AUDIOBOOK', 'EPUB']);
    expect(options.readStatuses, isEmpty);
  });
}
