import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grimmory/features/auth/oidc_config.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load returns null when nothing has been saved', () async {
    final prefs = await SharedPreferences.getInstance();
    expect(OidcConfig.load(prefs), isNull);
  });

  test('save then load round-trips issuer and clientId', () async {
    final prefs = await SharedPreferences.getInstance();
    const config = OidcConfig(
      issuer: 'https://auth.example.com/application/o/grimmory',
      clientId: 'grimmory-mobile',
    );

    await config.save(prefs);
    final loaded = OidcConfig.load(prefs);

    expect(loaded, isNotNull);
    expect(loaded!.issuer, config.issuer);
    expect(loaded.clientId, config.clientId);
  });

  test('discoveryDocumentUri appends the well-known path', () {
    const config = OidcConfig(
      issuer: 'https://auth.example.com/application/o/grimmory',
      clientId: 'grimmory-mobile',
    );

    expect(
      config.discoveryDocumentUri.toString(),
      'https://auth.example.com/application/o/grimmory/.well-known/openid-configuration',
    );
  });

  test('clear removes both stored values', () async {
    final prefs = await SharedPreferences.getInstance();
    const config = OidcConfig(
      issuer: 'https://auth.example.com',
      clientId: 'grimmory-mobile',
    );
    await config.save(prefs);

    await OidcConfig.clear(prefs);

    expect(OidcConfig.load(prefs), isNull);
  });
}
