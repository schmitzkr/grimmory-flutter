import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'core/api/api_client.dart';
import 'core/providers.dart';
import 'features/auth/oidc_login_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();
  final initialToken = await secureStorage.read(key: 'access_token');
  final apiClient = ApiClient(prefs, secureStorage, initialToken: initialToken);

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        secureStorageProvider.overrideWithValue(secureStorage),
        apiClientProvider.overrideWithValue(apiClient),
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
  /// to the active DeepLinkOidcUserManager — both the cold-start case (app
  /// wasn't running) and the warm case (app was backgrounded mid-login). See
  /// DeepLinkOidcUserManager's doc comment for why the redirect has to be
  /// owned this way rather than left to AppAuth's own activity.
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
    ref.read(oidcUserManagerProvider)?.completeLogin(uri);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Grimmory',
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
