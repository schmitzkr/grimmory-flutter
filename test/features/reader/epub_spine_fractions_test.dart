import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/features/reader/epub_spine_fractions.dart';

Uint8List _epub(Map<String, String> files) {
  final archive = Archive();
  files.forEach((name, content) {
    archive.addFile(ArchiveFile.bytes(name, utf8.encode(content)));
  });
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

const _container = '''
<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
''';

const _opf = '''
<?xml version="1.0"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0">
  <manifest>
    <item href="cover.xhtml" id="cover" media-type="application/xhtml+xml"/>
    <item id="ch1" href="text/ch%201.xhtml" media-type="application/xhtml+xml"/>
    <item id='ch2' href='text/ch2.xhtml' media-type='application/xhtml+xml'/>
    <item id="css" href="style.css" media-type="text/css"/>
  </manifest>
  <spine>
    <itemref idref="cover"/>
    <itemref idref="ch1"/>
    <itemref idref="ch2" linear="no"/>
  </spine>
</package>
''';

void main() {
  group('spineIndexOf', () {
    test('reads the even spine step epub.js writes', () {
      expect(EpubSpineFractions.spineIndexOf('epubcfi(/6/2!/4/2/1:0)'), 0);
      expect(EpubSpineFractions.spineIndexOf('epubcfi(/6/14[ch5]!/4/2)'), 6);
    });

    test('rejects a CFI without a spine step', () {
      expect(EpubSpineFractions.spineIndexOf('epubcfi(/4/2)'), isNull);
      expect(EpubSpineFractions.spineIndexOf(''), isNull);
    });
  });

  group('parse', () {
    test('weights spine items by uncompressed size, in spine order', () {
      final spine = EpubSpineFractions.parse(
        _epub({
          'META-INF/container.xml': _container,
          'OEBPS/content.opf': _opf,
          'OEBPS/cover.xhtml': 'x' * 100,
          'OEBPS/text/ch 1.xhtml': 'x' * 300,
          'OEBPS/text/ch2.xhtml': 'x' * 600,
          'OEBPS/style.css': 'x' * 5000,
        }),
      )!;
      expect(spine.length, 3);
      expect(spine.percentageAt('epubcfi(/6/2!/4)'), closeTo(0, 1e-9));
      expect(spine.percentageAt('epubcfi(/6/4[ch1]!/4/2)'), closeTo(10, 1e-9));
      expect(spine.percentageAt('epubcfi(/6/6!/4)'), closeTo(40, 1e-9));
      expect(spine.percentageAt('epubcfi(/6/8!/4)'), isNull);
    });

    test('returns null for a zip that is not an EPUB', () {
      expect(EpubSpineFractions.parse(_epub({'readme.txt': 'hi'})), isNull);
    });

    test('returns null for garbage bytes', () {
      expect(EpubSpineFractions.parse(Uint8List.fromList([1, 2, 3])), isNull);
    });
  });

  group('cache round-trip', () {
    test('encode/tryDecode preserves the fractions', () {
      final spine = EpubSpineFractions.parse(
        _epub({
          'META-INF/container.xml': _container,
          'OEBPS/content.opf': _opf,
          'OEBPS/cover.xhtml': 'x' * 100,
          'OEBPS/text/ch 1.xhtml': 'x' * 300,
          'OEBPS/text/ch2.xhtml': 'x' * 600,
        }),
      )!;
      final decoded = EpubSpineFractions.tryDecode(spine.encode())!;
      expect(decoded.length, spine.length);
      expect(decoded.percentageAt('epubcfi(/6/6!/4)'), closeTo(40, 1e-9));
    });

    test('tryDecode rejects malformed caches', () {
      expect(EpubSpineFractions.tryDecode('not json'), isNull);
      expect(EpubSpineFractions.tryDecode('[]'), isNull);
      expect(EpubSpineFractions.tryDecode('[0.5]'), isNull);
      expect(EpubSpineFractions.tryDecode('[0, 0.5]'), isNull);
      expect(EpubSpineFractions.tryDecode('{"a":1}'), isNull);
    });
  });
}
