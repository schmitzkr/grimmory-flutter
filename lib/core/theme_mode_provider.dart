import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// System / light / dark, chosen in Settings and persisted; the app used to
/// follow the system only (the EPUB reader has its own dark toggle).
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const prefsKey = 'theme_mode';

  @override
  ThemeMode build() {
    final stored = ref.watch(sharedPrefsProvider).getString(prefsKey);
    return ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPrefsProvider).setString(prefsKey, mode.name);
  }
}
