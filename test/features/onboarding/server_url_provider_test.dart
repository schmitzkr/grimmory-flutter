import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grimmory/core/api/api_client.dart';
import 'package:grimmory/core/providers.dart';
import 'package:grimmory/features/onboarding/server_url_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> containerWith(
    Map<String, Object> prefsValues,
  ) async {
    SharedPreferences.setMockInitialValues(prefsValues);
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer.test(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        apiClientProvider.overrideWithValue(
          ApiClient(prefs, const FlutterSecureStorage()),
        ),
      ],
    );
  }

  test('seeds from the stored URL, treating empty as unset', () async {
    expect((await containerWith({})).read(serverUrlProvider), isNull);
    expect(
      (await containerWith({'server_url': ''})).read(serverUrlProvider),
      isNull,
    );
    expect(
      (await containerWith({
        'server_url': 'https://books.test',
      })).read(serverUrlProvider),
      'https://books.test',
    );
  });

  test('set persists, notifies listeners and points the API client', () async {
    final container = await containerWith({});
    final seen = <String?>[];
    container.listen(serverUrlProvider, (_, next) => seen.add(next));

    await container.read(serverUrlProvider.notifier).set('https://books.test');

    expect(container.read(serverUrlProvider), 'https://books.test');
    expect(seen, ['https://books.test']);
    final prefs = container.read(sharedPrefsProvider);
    expect(prefs.getString('server_url'), 'https://books.test');
  });

  test('clear removes the stored URL and notifies', () async {
    final container = await containerWith({'server_url': 'https://books.test'});
    final seen = <String?>[];
    container.listen(serverUrlProvider, (_, next) => seen.add(next));

    await container.read(serverUrlProvider.notifier).clear();

    expect(container.read(serverUrlProvider), isNull);
    expect(seen, [null]);
    expect(container.read(sharedPrefsProvider).getString('server_url'), isNull);
  });
}
