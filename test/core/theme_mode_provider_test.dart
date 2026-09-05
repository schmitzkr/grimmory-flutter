import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grimmory/core/providers.dart';
import 'package:grimmory/core/theme_mode_provider.dart';

void main() {
  test('defaults to system and persists a choice', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.system);
    await container.read(themeModeProvider.notifier).set(ThemeMode.dark);
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(prefs.getString(ThemeModeNotifier.prefsKey), 'dark');
  });

  test('reads a stored choice back', () async {
    SharedPreferences.setMockInitialValues({
      ThemeModeNotifier.prefsKey: 'light',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    expect(container.read(themeModeProvider), ThemeMode.light);
  });
}
