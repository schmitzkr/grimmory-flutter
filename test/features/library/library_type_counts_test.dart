import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/api/models.dart';
import 'package:grimmory/features/library/library_detail_screen.dart';

void main() {
  test('groups the fileTypes facet into the three filter choices', () {
    final counts = libraryTypeCounts(const [
      CountedOption(name: 'AUDIOBOOK', count: 12),
      CountedOption(name: 'EPUB', count: 30),
      CountedOption(name: 'PDF', count: 2),
      CountedOption(name: 'CBX', count: 1),
    ]);
    expect(counts[LibraryTypeFilter.all], 45);
    expect(counts[LibraryTypeFilter.audiobooks], 12);
    expect(counts[LibraryTypeFilter.ebooks], 33);
  });

  test('a library with no audiobooks reports zero for that group', () {
    final counts = libraryTypeCounts(const [
      CountedOption(name: 'EPUB', count: 4),
    ]);
    expect(counts[LibraryTypeFilter.audiobooks], 0);
    expect(counts[LibraryTypeFilter.ebooks], 4);
    expect(counts[LibraryTypeFilter.all], 4);
  });

  test('an empty facet still yields every key', () {
    final counts = libraryTypeCounts(const []);
    expect(counts.keys, containsAll(LibraryTypeFilter.values));
    expect(counts.values, everyElement(0));
  });
}
