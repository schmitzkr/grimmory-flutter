import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:oidc/oidc.dart';
import 'package:url_launcher/url_launcher.dart';

/// Android-only OIDC user manager that owns the authorization redirect
/// instead of delegating to flutter_appauth.
///
/// AppAuth can only finish a login when the browser hands the redirect back
/// into the app task where its AuthorizationManagementActivity is waiting —
/// which Chrome Custom Tabs do, but Firefox (and other browsers) relaunch the
/// app in a fresh task, AppAuth finds no stored state, and the returned code
/// is silently discarded ("W AppAuth: No stored state"). flutter_appauth
/// exposes no browser-selection knob, so the flow is owned end to end here
/// (ported from schmlist-flutter's identical fix, itself ported from
/// schmoney-flutter's original — see those repos' deep_link_*_manager.dart):
///
/// - [getAuthorizationResponse] opens the authorize URL in the user's default
///   browser and waits for the redirect
///   (is.schmitzkr.grimmory://oidc-callback?code=…&state=…);
/// - app_links delivers that redirect to [completeLogin] — via the live
///   stream when the app instance is still alive, or via the initial link on
///   a cold start.
///
/// One deliberate difference from schmlist/schmoney: those apps redirect via
/// a domain-verified HTTPS App Link (they each own a fixed domain). Grimmory
/// is self-hosted with no fixed domain per install, so this redirects via a
/// plain custom URI scheme instead (registered on MainActivity in
/// AndroidManifest.xml) — see build.gradle.kts's appAuthRedirectScheme
/// comment for why that scheme must stay distinct from AppAuth's own
/// (unused) redirect activity.
///
/// The cold start is the crucial case: the base manager persists state, nonce
/// and the PKCE verifier in the (secure-storage-backed) store keyed by
/// `state` BEFORE the browser opens, so [handleSuccessfulAuthResponse] can
/// run the code→token exchange in a brand-new process. This makes login work
/// in ANY browser.
class DeepLinkOidcUserManager extends OidcUserManager
    with WidgetsBindingObserver {
  DeepLinkOidcUserManager.lazy({
    required super.discoveryDocumentUri,
    required super.clientCredentials,
    required super.store,
    required super.settings,
  }) : super.lazy();

  /// The login this isolate is currently awaiting a browser redirect for.
  Completer<OidcAuthorizeResponse?>? _pending;
  Timer? _abandonTimer;

  @override
  Future<OidcAuthorizeResponse?> getAuthorizationResponse(
    OidcProviderMetadata metadata,
    OidcAuthorizeRequest request,
    OidcPlatformSpecificOptions options,
    Map<String, dynamic> preparationResult,
  ) async {
    final endpoint = metadata.authorizationEndpoint;
    if (endpoint == null) {
      throw const OidcException(
        "The provider doesn't declare an authorization endpoint.",
      );
    }
    // A new attempt supersedes an unresolved one (whose login() returns null).
    _pending?.complete(null);
    final completer = Completer<OidcAuthorizeResponse?>();
    _pending = completer;
    WidgetsBinding.instance.addObserver(this);
    try {
      final launched = await launchUrl(
        request.generateUri(endpoint),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw const OidcException('Could not open a browser for sign-in.');
      }
      return await completer.future;
    } finally {
      if (identical(_pending, completer)) _pending = null;
      WidgetsBinding.instance.removeObserver(this);
      _abandonTimer?.cancel();
      _abandonTimer = null;
    }
  }

  /// Resolve an abandoned login so the UI doesn't spin forever: if the user
  /// comes back to the app and no redirect follows shortly, the pending
  /// login() completes with null. The redirect fires BEFORE the resumed
  /// lifecycle event, so a successful return always wins this race — and
  /// even if it didn't, a late redirect still logs in via the cold-start
  /// path in [completeLogin].
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final pending = _pending;
    if (pending == null || pending.isCompleted) return;
    _abandonTimer?.cancel();
    _abandonTimer = Timer(const Duration(seconds: 2), () {
      if (!pending.isCompleted) pending.complete(null);
    });
  }

  /// Feeds the OIDC redirect delivered by app_links back into the manager.
  ///
  /// Warm app: the login() call is still awaiting — complete it and let
  /// [tryGetAuthResponse] run the token exchange. Cold start (the browser
  /// relaunched the app; the awaiting isolate is gone): exchange directly
  /// against the state persisted before the browser was opened; the resulting
  /// user is published on [userChanges].
  Future<void> completeLogin(Uri redirect) async {
    final pending = _pending;
    _pending = null;
    try {
      final response =
          await OidcEndpoints.parseAuthorizeResponse(responseUri: redirect);
      if (pending != null && !pending.isCompleted) {
        pending.complete(response);
        return;
      }
      await handleSuccessfulAuthResponse(
        response: response,
        grantType: OidcConstants_GrantType.authorizationCode,
        metadata: discoveryDocument,
      );
    } catch (e, st) {
      // Surface the error (e.g. the user denied consent) to the awaiting
      // login() so the login screen can show it.
      if (pending != null && !pending.isCompleted) {
        pending.completeError(e, st);
        return;
      }
      rethrow;
    }
  }
}
