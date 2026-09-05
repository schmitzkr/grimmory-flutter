import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'core/api/api_client.dart';
import 'core/providers.dart';
import 'features/auth/oidc_login_controller.dart';
import 'features/downloads/download_manager.dart';
import 'features/downloads/download_storage.dart';
import 'features/player/audio_handler.dart';
import 'features/player/playback_provider.dart';
import 'features/player/progress_sync.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();
  final initialToken = await secureStorage.read(key: 'access_token');
  final apiClient = ApiClient(prefs, secureStorage, initialToken: initialToken);

  // One storage instance for both the handler (offline playback) and the
  // download manager (UI), so they can't disagree about what's on disk.
  final downloadStorage = DownloadStorage();
  unawaited(downloadStorage.sweepOrphans());

  final audioHandler = await AudioService.init(
    builder: () =>
        GrimmoryAudioHandler(apiClient, downloadStorage: downloadStorage),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'is.schmitzkr.grimmory.audio',
      androidNotificationChannelName: 'Audiobook playback',
      androidNotificationOngoing: true,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        secureStorageProvider.overrideWithValue(secureStorage),
        apiClientProvider.overrideWithValue(apiClient),
        audioHandlerProvider.overrideWithValue(audioHandler),
        downloadStorageProvider.overrideWithValue(downloadStorage),
      ],
      child: const GrimmoryApp(),
    ),
  );
}

class GrimmoryApp extends ConsumerStatefulWidget {
  const GrimmoryApp({super.key});

  @override
  ConsumerState<GrimmoryApp> createState() => _GrimmoryAppState();
}

class _GrimmoryAppState extends ConsumerState<GrimmoryApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _listenForOidcRedirect();
  }

  /// Feeds an incoming OIDC redirect (is.schmitzkr.grimmory://oidc-callback)
  /// to [OidcLoginController.completeRedirect] — both the cold-start case
  /// (app wasn't running) and the warm case (app was backgrounded
  /// mid-login). See OidcLoginController's doc comment for why the redirect
  /// has to be owned this way rather than left to AppAuth's own activity.
  Future<void> _listenForOidcRedirect() async {
    _appLinks.uriLinkStream.listen(_handleUri);

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) _handleUri(initialUri);
  }

  void _handleUri(Uri uri) {
    if (uri.scheme != oidcRedirectUri.scheme ||
        uri.host != oidcRedirectUri.host) {
      return;
    }
    ref.read(oidcLoginControllerProvider.notifier).completeRedirect(uri);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    // Watched here, at the root, purely to keep it alive for the app's
    // lifetime — it has no value, only the side effect described on it.
    ref.watch(audiobookProgressSyncProvider);
    return MaterialApp.router(
      title: 'GrimReader',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
