import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/features/book/book_text.dart';

void main() {
  group('plainText', () {
    test('strips tags, decodes entities, keeps paragraph breaks', () {
      expect(
        plainText(
          '<p>Tom &amp; Jerry</p><p>Act&nbsp;II &mdash; <b>bold</b></p>',
        ),
        'Tom & Jerry\n\nAct II — bold',
      );
    });

    test('turns line breaks into newlines and collapses whitespace', () {
      expect(
        plainText('one<br/>two   three\n\n\n\nfour'),
        'one\ntwo three\n\nfour',
      );
    });

    test('leaves plain text alone', () {
      expect(plainText('  Just words.  '), 'Just words.');
    });
  });

  test('publishedYear keeps the year of a LocalDate', () {
    expect(publishedYear('2021-03-09'), '2021');
    expect(publishedYear('2021'), '2021');
    expect(publishedYear(null), isNull);
    expect(publishedYear(''), isNull);
    expect(publishedYear('unknown'), 'unknown');
  });

  test('readStatusLabel covers every server value', () {
    expect(readStatusLabel('READ'), 'Finished');
    expect(readStatusLabel('READING'), 'Reading');
    expect(readStatusLabel('WONT_READ'), "Won't read");
    expect(readStatusLabel('UNSET'), 'No status');
    expect(readStatusLabel(null), 'No status');
    expect(manualReadStatuses.keys, contains('ABANDONED'));
  });
}
