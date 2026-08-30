import 'package:shared_preferences/shared_preferences.dart';

/// Per-server OIDC configuration, entered by the user rather than
/// hardcoded — unlike a fixed-tenant app, a self-hosted Grimmory instance
/// may be wired to any IdP the admin chose (or none at all). See
/// sso_settings_screen.dart for where this gets entered.
class OidcConfig {
  const OidcConfig({required this.issuer, required this.clientId});

  final String issuer;
  final String clientId;

  /// Standard OIDC discovery document location relative to the issuer.
  Uri get discoveryDocumentUri =>
      Uri.parse('$issuer/.well-known/openid-configuration');

  static OidcConfig? load(SharedPreferences prefs) {
    final issuer = prefs.getString('oidc_issuer');
    final clientId = prefs.getString('oidc_client_id');
    if (issuer == null ||
        issuer.isEmpty ||
        clientId == null ||
        clientId.isEmpty) {
      return null;
    }
    return OidcConfig(issuer: issuer, clientId: clientId);
  }

  Future<void> save(SharedPreferences prefs) async {
    await prefs.setString('oidc_issuer', issuer);
    await prefs.setString('oidc_client_id', clientId);
  }

  static Future<void> clear(SharedPreferences prefs) async {
    await prefs.remove('oidc_issuer');
    await prefs.remove('oidc_client_id');
  }
}
