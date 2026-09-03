import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oidc/oidc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers.dart';
import 'auth_provider.dart';
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

/// Drives the OIDC login button on login_screen.dart, and receives the
/// completed redirect from main.dart's app_links listener.
///
/// Deliberately NOT built on the `oidc` package's `OidcUserManager` — that
/// class performs the full authorization-code-for-token exchange itself
/// against the IdP's token endpoint and hands back a completed `OidcUser`.
/// Grimmory's actual `/auth/oidc/callback` contract (confirmed live against
/// grimmory.mael.is, 2026-08-30 — a validation error listed its exact
/// required fields) wants the opposite: the raw, unexchanged PKCE result
/// (`code`/`state`/`codeVerifier`/`nonce`/`redirectUri`), so its own backend
/// performs the exchange itself. So this only runs the authorize-request
/// half of the flow by hand, using `oidc_core`'s low-level PKCE/request
/// utilities (via `package:oidc`, which re-exports `oidc_core`) — no
/// `OidcUserManager`, no `oidc_default_store`.
final oidcLoginControllerProvider =
    AsyncNotifierProvider<OidcLoginController, void>(OidcLoginController.new);

class OidcLoginController extends AsyncNotifier<void>
    with WidgetsBindingObserver {
  Completer<void>? _pending;
  Timer? _abandonTimer;

  @override
  void build() {
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _abandonTimer?.cancel();
    });
  }

  /// Deliberately NOT wrapped end-to-end in one AsyncValue.guard: a failure
  /// during the authorize-request/browser phase is a distinct error surface
  /// from a failure exchanging the code with Grimmory's server (the latter
  /// already manages its own error state via [authProvider], which
  /// login_screen.dart listens to separately — see
  /// AuthNotifier.loginWithOidc). This method's own state only ever
  /// reflects "did the browser round-trip complete", not "did login
  /// succeed" — that distinction matters because AsyncNotifier.loginWithOidc
  /// swallows its own errors into authProvider's state rather than
  /// rethrowing, so this method can't observe that outcome anyway.
  Future<void> login() async {
    final config = ref.read(oidcConfigProvider);
    if (config == null) {
      state = AsyncError(
        StateError('No SSO server configured yet.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    try {
      final metadata = await OidcEndpoints.getProviderMetadata(
        config.discoveryDocumentUri,
      );
      final authEndpoint = metadata.authorizationEndpoint;
      if (authEndpoint == null) {
        throw const OidcException(
          "The identity provider doesn't declare an authorization endpoint.",
        );
      }

      final pkce = OidcPkcePair.generate();
      // Confirmed via the real Grimmory server source (OidcStateService):
      // `state` must be a one-time value the SERVER generates and caches,
      // not client-generated randomness — the callback validates it against
      // that server-side cache and rejects anything it didn't itself issue
      // with "Invalid or expired OIDC state parameter".
      final authState = await ref.read(apiClientProvider).getOidcState();
      final nonce = _randomToken();

      // Persisted BEFORE opening the browser so a cold restart (the browser
      // relaunches the app in a fresh process, wiping in-memory state) can
      // still complete the exchange once the redirect arrives via
      // completeRedirect() — same reasoning schmlist-flutter's deep-link
      // OIDC manager used for its own state persistence.
      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.write(
        key: 'oidc_pending_$authState',
        value: jsonEncode({'codeVerifier': pkce.codeVerifier, 'nonce': nonce}),
      );

      final request = OidcAuthorizeRequest(
        responseType: const ['code'],
        clientId: config.clientId,
        redirectUri: oidcRedirectUri,
        scope: const ['openid'],
        codeChallenge: pkce.codeChallenge,
        codeChallengeMethod: 'S256',
        state: authState,
        nonce: nonce,
      );

      final completer = Completer<void>();
      _pending = completer;
      WidgetsBinding.instance.addObserver(this);
      final launched = await launchUrl(
        request.generateUri(authEndpoint),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw StateError('Could not open a browser for sign-in.');
      }
      await completer.future;
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      WidgetsBinding.instance.removeObserver(this);
      _abandonTimer?.cancel();
      _abandonTimer = null;
      _pending = null;
    }
  }

  /// Resolve an abandoned login so the UI doesn't spin forever: if the user
  /// comes back to the app and no redirect follows shortly, [login]'s
  /// completer resolves anyway. The redirect fires BEFORE the resumed
  /// lifecycle event when it does arrive, so a successful return always
  /// wins this race.
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState != AppLifecycleState.resumed) return;
    final pending = _pending;
    if (pending == null || pending.isCompleted) return;
    _abandonTimer?.cancel();
    _abandonTimer = Timer(const Duration(seconds: 2), () {
      if (!pending.isCompleted) pending.complete();
    });
  }

  /// Called by main.dart's app_links listener when the OIDC redirect
  /// arrives — both the warm case (this isolate is still waiting inside
  /// [login]) and the cold-start case (the browser relaunched the app; the
  /// awaiting isolate is gone, but the pending PKCE state was persisted to
  /// secure storage before the browser opened).
  Future<void> completeRedirect(Uri redirect) async {
    final code = redirect.queryParameters['code'];
    final authState = redirect.queryParameters['state'];
    if (code == null || authState == null) {
      _pending?.complete();
      _pending = null;
      return;
    }

    final secureStorage = ref.read(secureStorageProvider);
    final pendingJson = await secureStorage.read(
      key: 'oidc_pending_$authState',
    );
    await secureStorage.delete(key: 'oidc_pending_$authState');
    if (pendingJson == null) {
      // Unknown/expired state (e.g. a stale redirect replayed) — nothing
      // this app is currently waiting on, so just drop it.
      _pending?.complete();
      _pending = null;
      return;
    }

    final pending = jsonDecode(pendingJson) as Map<String, dynamic>;
    await ref
        .read(authProvider.notifier)
        .loginWithOidc(
          code: code,
          state_: authState,
          codeVerifier: pending['codeVerifier'] as String,
          nonce: pending['nonce'] as String,
          redirectUri: oidcRedirectUri.toString(),
        );
    _pending?.complete();
    _pending = null;
  }

  String _randomToken() {
    final random = Random.secure();
    return base64UrlEncode(
      List.generate(32, (_) => random.nextInt(256)),
    ).split('=').first;
  }
}
