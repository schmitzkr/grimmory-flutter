/// Grimmory descriptions are often HTML (metadata providers return it). The
/// detail screen shows them as text, so tags go, the common entities are
/// decoded, and runs of whitespace collapse — block tags become paragraph
/// breaks first so a `<p>` list doesn't turn into one long line.
String plainText(String html) {
  var s = html
      .replaceAll(RegExp(r'<\s*br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(
        RegExp(r'</\s*(p|div|li|h[1-6]|blockquote)\s*>', caseSensitive: false),
        '\n\n',
      )
      .replaceAll(RegExp(r'<[^>]+>'), '');
  const entities = {
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&#39;': "'",
    '&apos;': "'",
    '&nbsp;': ' ',
    '&#160;': ' ',
    '&mdash;': '—',
    '&ndash;': '–',
    '&hellip;': '…',
  };
  entities.forEach((k, v) => s = s.replaceAll(k, v));
  s = s.replaceAll(RegExp(r'[ \t]+'), ' ');
  s = s.replaceAll(RegExp(r' *\n *'), '\n');
  s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return s.trim();
}

/// `2021-03-09` → `2021`; anything unparseable comes back as given.
String? publishedYear(String? date) {
  if (date == null || date.isEmpty) return null;
  final m = RegExp(r'^(\d{4})').firstMatch(date);
  return m?.group(1) ?? date;
}

/// The statuses a reader sets by hand, in menu order, with their labels.
/// READING/RE_READING/PARTIALLY_READ are set by progress, not by hand, and
/// UNSET is the absence of a status.
const manualReadStatuses = <String, String>{
  'READ': 'Finished',
  'UNREAD': 'Unread',
  'PAUSED': 'Paused',
  'ABANDONED': 'Abandoned',
  'WONT_READ': "Won't read",
};

String readStatusLabel(String? status) => switch (status) {
  null || '' || 'UNSET' => 'No status',
  'READING' => 'Reading',
  'RE_READING' => 'Re-reading',
  'PARTIALLY_READ' => 'Partially read',
  final s => manualReadStatuses[s] ?? s,
};
