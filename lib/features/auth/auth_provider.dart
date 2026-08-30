import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Whether the app currently holds a Grimmory session (a stored refresh
/// token). Grimmory's confirmed endpoint list (see docs/) has no `/auth/me`
/// equivalent yet, so this deliberately doesn't try to fetch/cache a user
/// profile — just enough state to gate the router.
final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final secureStorage = ref.watch(secureStorageProvider);
    final refreshToken = await secureStorage.read(key: 'refresh_token');
    return refreshToken != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(apiClientProvider).login(email, password);
      return true;
    });
  }

  Future<void> loginWithOidc(String idToken) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(apiClientProvider).loginWithOidc(idToken);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(apiClientProvider).logout();
    state = const AsyncData(false);
  }
}
