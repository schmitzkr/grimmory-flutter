import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/server_config.dart';

void main() {
  test('defaults a bare host to https', () {
    expect(
      normalizeServerUrl('books.example.com'),
      'https://books.example.com',
    );
  });

  test('keeps an explicit scheme and port', () {
    expect(
      normalizeServerUrl('http://192.168.1.10:6060'),
      'http://192.168.1.10:6060',
    );
  });

  test('trims whitespace and every trailing slash', () {
    expect(
      normalizeServerUrl('  https://books.example.com///  '),
      'https://books.example.com',
    );
  });

  test('keeps a sub-path (Grimmory behind a reverse-proxy prefix)', () {
    expect(
      normalizeServerUrl('https://home.example.com/grimmory/'),
      'https://home.example.com/grimmory',
    );
  });

  test('rejects input that cannot be a server', () {
    expect(normalizeServerUrl(''), isNull);
    expect(normalizeServerUrl('   '), isNull);
    expect(normalizeServerUrl('https://'), isNull);
    expect(normalizeServerUrl('/just/a/path'), isNull);
  });
}
