import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grimmory/core/providers.dart';
import 'package:grimmory/core/api/api_client.dart';
import 'package:grimmory/main.dart';

void main() {
  testWidgets('shows the onboarding screen with no server configured yet', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    final apiClient = ApiClient(prefs, secureStorage);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          secureStorageProvider.overrideWithValue(secureStorage),
          apiClientProvider.overrideWithValue(apiClient),
        ],
        child: const GrimmoryApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Connect to Grimmory'), findsOneWidget);
  });
}
