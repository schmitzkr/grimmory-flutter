import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/api/models.dart';
import 'package:grimmory/features/browse/series_screen.dart';

void main() {
  test('plain count when nothing is read and the series is complete', () {
    expect(
      seriesSubtitle(const Series(seriesName: 's', bookCount: 1)),
      '1 book',
    );
    expect(
      seriesSubtitle(
        const Series(seriesName: 's', bookCount: 9, seriesTotal: 9),
      ),
      '9 books',
    );
  });

  test('shows the series total only when the library holds fewer', () {
    expect(
      seriesSubtitle(
        const Series(seriesName: 's', bookCount: 9, seriesTotal: 12),
      ),
      '9 books of 12',
    );
  });

  test('appends the read count when any are read', () {
    expect(
      seriesSubtitle(
        const Series(
          seriesName: 's',
          bookCount: 9,
          seriesTotal: 12,
          booksRead: 3,
        ),
      ),
      '9 books of 12 · 3 read',
    );
  });
}
