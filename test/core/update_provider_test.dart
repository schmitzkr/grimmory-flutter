import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/update_provider.dart';

void main() {
  group('parseVersion', () {
    test('splits dotted integers', () {
      expect(parseVersion('0.11.9'), [0, 11, 9]);
      expect(parseVersion('2'), [2]);
    });

    test('rejects anything that is not dotted integers', () {
      expect(parseVersion('v0.11.9'), isNull);
      expect(parseVersion('0.11.9+31'), isNull);
      expect(parseVersion(''), isNull);
    });
  });

  group('isNewerVersion', () {
    test('compares component-wise', () {
      expect(isNewerVersion([0, 11, 10], [0, 11, 9]), isTrue);
      expect(isNewerVersion([0, 12, 0], [0, 11, 99]), isTrue);
      expect(isNewerVersion([1, 0, 0], [0, 99, 99]), isTrue);
      expect(isNewerVersion([0, 11, 9], [0, 11, 10]), isFalse);
      expect(isNewerVersion([0, 11, 9], [0, 11, 9]), isFalse);
    });

    test(
      'a longer version with an equal prefix is newer, a shorter is not',
      () {
        expect(isNewerVersion([1, 0, 1], [1, 0]), isTrue);
        expect(isNewerVersion([1, 0], [1, 0, 1]), isFalse);
      },
    );
  });

  group('AppRelease.fromGithubJson', () {
    test('strips the v prefix and finds the APK asset by name', () {
      final release = AppRelease.fromGithubJson({
        'tag_name': 'v0.11.9',
        'body': '  - fix: things\n',
        'published_at': '2026-09-04T18:22:31Z',
        'prerelease': false,
        'assets': [
          {
            'name': 'grimmory-debug-info.zip',
            'browser_download_url': 'https://example.test/dbg.zip',
          },
          {
            'name': 'grimreader.apk',
            'browser_download_url': 'https://example.test/grimreader.apk',
          },
        ],
      });
      expect(release.version, '0.11.9');
      expect(release.releaseNotes, '- fix: things');
      expect(release.releasedAt, DateTime.utc(2026, 9, 4, 18, 22, 31));
      expect(release.apkDownloadUrl, 'https://example.test/grimreader.apk');
      expect(release.prerelease, isFalse);
    });

    test('tolerates a release with no assets or notes yet', () {
      final release = AppRelease.fromGithubJson({'tag_name': 'v0.12.0'});
      expect(release.version, '0.12.0');
      expect(release.releaseNotes, '');
      expect(release.releasedAt, isNull);
      expect(release.apkDownloadUrl, isNull);
      expect(release.prerelease, isFalse);
    });
  });
}
