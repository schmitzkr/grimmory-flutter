import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// The configured Grimmory server URL — the one piece of state the router's
/// redirect depends on besides auth. It used to live only in
/// SharedPreferences, which notifies nothing, so onboarding and "change
/// server" each had to force a `context.go` by hand to get the redirect
/// re-evaluated. Now the router listens to this and re-runs on its own.
final serverUrlProvider = NotifierProvider<ServerUrlNotifier, String?>(
  ServerUrlNotifier.new,
);

class ServerUrlNotifier extends Notifier<String?> {
  @override
  String? build() {
    final url = ref.watch(sharedPrefsProvider).getString('server_url');
    return (url == null || url.isEmpty) ? null : url;
  }

  /// Points the API client at [url] and persists it.
  Future<void> set(String url) async {
    ref.read(apiClientProvider).updateBaseUrl(url);
    await ref.read(sharedPrefsProvider).setString('server_url', url);
    state = url;
  }

  Future<void> clear() async {
    await ref.read(sharedPrefsProvider).remove('server_url');
    state = null;
  }
}
