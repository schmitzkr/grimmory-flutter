import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oidc/oidc.dart';
import 'package:oidc_default_store/oidc_default_store.dart';

import '../../core/providers.dart';
import 'auth_provider.dart';
import 'deep_link_oidc_user_manager.dart';
import 'oidc_config.dart';

/// The custom URI scheme this app registers for the OIDC redirect (see
/// AndroidManifest.xml's intent-filter on MainActivity, and
/// build.gradle.kts's appAuthRedirectScheme comment for why it must stay
/// distinct from AppAuth's own placeholder).
final oidcRedirectUri = Uri.parse('is.schmitzkr.grimmory://oidc-callback');

final oidcConfigProvider = Provider<OidcConfig?>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return OidcConfig.load(prefs);
});

/// Null until a per-server OIDC issuer/client ID has been entered (see
/// sso_settings_screen.dart) — Grimmory has no single fixed IdP the way a
/// fixed-tenant app would.
final oidcUserManagerProvider = Provider<DeepLinkOidcUserManager?>((ref) {
  final config = ref.watch(oidcConfigProvider);
  if (config == null) return null;

  return DeepLinkOidcUserManager.lazy(
    discoveryDocumentUri: config.discoveryDocumentUri,
    clientCredentials: OidcClientAuthentication.none(
      clientId: config.clientId,
    ),
    store: OidcDefaultStore(),
    settings: OidcUserManagerSettings(redirectUri: oidcRedirectUri),
  );
});

/// Drives the OIDC login button on login_screen.dart.
final oidcLoginControllerProvider =
    AsyncNotifierProvider<OidcLoginController, void>(OidcLoginController.new);

class OidcLoginController extends AsyncNotifier<void> {
  @override
  void build() {}

  /// Deliberately NOT wrapped end-to-end in one AsyncValue.guard: a failure
  /// exchanging the code with the IdP is a distinct error surface from a
  /// failure exchanging the resulting ID token with Grimmory's own server
  /// (the latter already manages its own error state via [authProvider],
  /// which login_screen.dart listens to separately — see
  /// AuthNotifier.loginWithOidc). Collapsing both into one guard would mean
  /// a Grimmory-side failure (already surfaced via authProvider) gets
  /// silently swallowed here instead of propagating to this controller's
  /// own (unused, in that case) error state.
  Future<void> login() async {
    final manager = ref.read(oidcUserManagerProvider);
    if (manager == null) {
      state = AsyncError(
        StateError('No SSO server configured yet.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    try {
      await manager.init();
      final user = await manager.loginAuthorizationCodeFlow();
      state = const AsyncData(null);
      if (user == null) {
        // Login was abandoned (user closed the browser, or denied consent)
        // rather than a hard failure.
        return;
      }
      await ref.read(authProvider.notifier).loginWithOidc(user.idToken);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
