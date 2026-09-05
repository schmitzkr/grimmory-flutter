import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/features/reader/page_progress.dart';

void main() {
  // Must match Grimmory's web comic reader exactly —
  // `Math.round(((currentPage + 1) / pages.length) * 1000) / 10` — so a
  // comic read half on the phone and half in the browser shows one number.
  test('matches the web reader formula to one decimal', () {
    expect(pagePercentage(pageIndex: 0, pageCount: 3), 33.3);
    expect(pagePercentage(pageIndex: 1, pageCount: 3), 66.7);
    expect(pagePercentage(pageIndex: 0, pageCount: 1), 100);
    expect(pagePercentage(pageIndex: 4, pageCount: 10), 50);
  });

  // The last page reports 100, which is what tips the server's READ
  // threshold (>= 99.5) — finishing a comic in the app marks it finished.
  test('last page is 100%', () {
    expect(pagePercentage(pageIndex: 41, pageCount: 42), 100);
  });

  test('clamps out-of-range indices and handles an empty book', () {
    expect(pagePercentage(pageIndex: -3, pageCount: 4), 25);
    expect(pagePercentage(pageIndex: 99, pageCount: 4), 100);
    expect(pagePercentage(pageIndex: 0, pageCount: 0), 0);
  });
}
