import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Where each spine item starts, as a fraction of the whole book by
/// uncompressed document size — the "section fractions" Grimmory's own web
/// reader (foliate-js) derives its progress figure from, computed here from
/// the EPUB's `META-INF/container.xml` and OPF directly.
///
/// Exists because epub.js's percentage is 0 until `book.locations
/// .generate()` finishes *and* a relocate has happened since, which a short
/// session never reaches — confirmed in the server's own tables: every
/// quick app session had saved the right CFI with `progress_percent = 0`,
/// leaving the book `UNREAD`, invisible in Continue Reading, and with no
/// percent on its detail screen. Chapter-start granularity is coarse but
/// monotonic, never regresses under the reader's percentage floor, and is
/// enough to clear the server's `READING` threshold from the first page.
class EpubSpineFractions {
  EpubSpineFractions._(this._starts);

  /// Start fraction of each spine item, plus a trailing 1.0.
  final List<double> _starts;

  int get length => _starts.length - 1;

  /// Null when the file isn't a readable EPUB (no container/OPF/spine, or
  /// every spine document is missing) — callers just lose the fallback.
  static EpubSpineFractions? parse(Uint8List epubBytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(epubBytes);
    } catch (_) {
      return null;
    }

    final container = _text(archive, 'META-INF/container.xml');
    final opfPath = container == null
        ? null
        : RegExp(
            r'''full-path\s*=\s*["']([^"']+)["']''',
          ).firstMatch(container)?.group(1);
    if (opfPath == null) return null;
    final opf = _text(archive, opfPath);
    if (opf == null) return null;
    final opfDir = opfPath.contains('/')
        ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1)
        : '';

    final hrefById = <String, String>{};
    for (final item in RegExp(r'<item\b[^>]*>').allMatches(opf)) {
      final tag = item.group(0)!;
      final id = _attr(tag, 'id');
      final href = _attr(tag, 'href');
      if (id != null && href != null) hrefById[id] = href;
    }

    final sizes = <int>[];
    for (final ref in RegExp(r'<itemref\b[^>]*>').allMatches(opf)) {
      final idref = _attr(ref.group(0)!, 'idref');
      final href = idref == null ? null : hrefById[idref];
      final path = href == null
          ? null
          : _resolve(opfDir, Uri.decodeComponent(href.split('#').first));
      sizes.add(path == null ? 0 : (archive.find(path)?.size ?? 0));
    }
    if (sizes.isEmpty) return null;
    final total = sizes.fold<int>(0, (sum, size) => sum + size);
    if (total <= 0) return null;

    final starts = <double>[];
    var seen = 0;
    for (final size in sizes) {
      starts.add(seen / total);
      seen += size;
    }
    starts.add(1.0);
    return EpubSpineFractions._(starts);
  }

  /// 0-100 at the *start* of the spine item [cfi] points into, or null if
  /// the CFI doesn't carry a spine step this recognises.
  double? percentageAt(String cfi) {
    final index = spineIndexOf(cfi);
    if (index == null || index < 0 || index >= length) return null;
    return _starts[index] * 100;
  }

  /// epub.js writes the spine position into a CFI as `/6/<(index+1)*2>` —
  /// `/6` is the package document's `<spine>` element, the even step the
  /// itemref's 1-based child position — e.g. `epubcfi(/6/14[ch5]!/4/2/1:0)`
  /// is spine index 6.
  static int? spineIndexOf(String cfi) {
    final match = RegExp(r'^epubcfi\(/6/(\d+)').firstMatch(cfi.trim());
    if (match == null) return null;
    return int.parse(match.group(1)!) ~/ 2 - 1;
  }

  static String? _text(Archive archive, String path) {
    final bytes = archive.find(path)?.readBytes();
    return bytes == null ? null : utf8.decode(bytes, allowMalformed: true);
  }

  static String? _attr(String tag, String name) =>
      RegExp('\\b$name\\s*=\\s*["\']([^"\']*)["\']').firstMatch(tag)?.group(1);

  static String _resolve(String dir, String href) {
    final parts = [...dir.split('/').where((p) => p.isNotEmpty)];
    for (final segment in href.split('/')) {
      if (segment == '..') {
        if (parts.isNotEmpty) parts.removeLast();
      } else if (segment != '.' && segment.isNotEmpty) {
        parts.add(segment);
      }
    }
    return parts.join('/');
  }
}
