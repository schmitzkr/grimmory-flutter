import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../onboarding/server_url_provider.dart';
import 'oidc_config.dart';

/// What the configured server publishes before login. Null while there is
/// no server, and on any failure — the login screen then falls back to the
/// manually entered SSO settings, exactly as before this existed.
final publicSettingsProvider = FutureProvider<PublicSettings?>((ref) async {
  if (ref.watch(serverUrlProvider) == null) return null;
  try {
    return await ref.read(apiClientProvider).getPublicSettings();
  } catch (_) {
    return null;
  }
});

extension PublicSettingsSsoX on PublicSettings {
  /// The SSO configuration the server itself advertises, or null when OIDC
  /// is off or the details are incomplete — the same issuer and client id
  /// the user used to have to type into the SSO settings screen.
  OidcConfig? get oidcConfig {
    final d = oidcProviderDetails;
    if (!oidcEnabled || d == null) return null;
    final issuer = d.issuerUri?.trim();
    final clientId = d.clientId?.trim();
    if (issuer == null ||
        issuer.isEmpty ||
        clientId == null ||
        clientId.isEmpty) {
      return null;
    }
    // OidcConfig appends /.well-known/openid-configuration itself.
    return OidcConfig(
      issuer: issuer.endsWith('/')
          ? issuer.substring(0, issuer.length - 1)
          : issuer,
      clientId: clientId,
    );
  }

  String get ssoButtonLabel {
    final name = oidcProviderDetails?.providerName?.trim();
    return (name == null || name.isEmpty)
        ? 'Sign in with SSO'
        : 'Sign in with $name';
  }
}
