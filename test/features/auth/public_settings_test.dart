import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/api/models.dart';
import 'package:grimmory/features/auth/public_settings_provider.dart';

void main() {
  test('derives the SSO config and label from the server details', () {
    const s = PublicSettings(
      oidcEnabled: true,
      oidcProviderDetails: OidcProviderDetails(
        providerName: 'Authentik',
        clientId: 'abc',
        issuerUri: 'https://auth.example.test/application/o/grimmory/',
      ),
    );
    expect(s.oidcConfig?.clientId, 'abc');
    expect(
      s.oidcConfig?.issuer,
      'https://auth.example.test/application/o/grimmory',
    );
    expect(
      s.oidcConfig?.discoveryDocumentUri.toString(),
      'https://auth.example.test/application/o/grimmory/.well-known/openid-configuration',
    );
    expect(s.ssoButtonLabel, 'Sign in with Authentik');
  });

  test('is null when OIDC is off or details are incomplete', () {
    expect(
      const PublicSettings(
        oidcEnabled: false,
        oidcProviderDetails: OidcProviderDetails(clientId: 'x', issuerUri: 'y'),
      ).oidcConfig,
      isNull,
    );
    expect(
      const PublicSettings(
        oidcEnabled: true,
        oidcProviderDetails: OidcProviderDetails(clientId: 'x'),
      ).oidcConfig,
      isNull,
    );
    expect(const PublicSettings().ssoButtonLabel, 'Sign in with SSO');
  });
}
