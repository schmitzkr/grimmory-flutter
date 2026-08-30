/// Normalizes a user-entered Grimmory server URL: trims whitespace, strips a
/// trailing slash, and defaults to `https://` when no scheme was given.
/// Returns null if the input can't reasonably be a URL at all.
String? normalizeServerUrl(String input) {
  var url = input.trim();
  if (url.isEmpty) return null;

  if (!url.contains('://')) {
    url = 'https://$url';
  }
  while (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }

  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return null;
  return url;
}
