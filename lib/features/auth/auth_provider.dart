import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Whether the app currently holds a Grimmory session (a stored refresh
/// token). `/auth/me` does exist on a live instance (confirmed as a real
/// route, 2026-08-30), but this deliberately still doesn't fetch/cache a
/// user profile — no screen needs one yet, so there's nothing to gain from
/// the extra request.
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

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(apiClientProvider).login(username, password);
      return true;
    });
  }

  Future<void> loginWithOidc({
    required String code,
    required String state_,
    required String codeVerifier,
    required String nonce,
    required String redirectUri,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(apiClientProvider)
          .loginWithOidc(
            code: code,
            state: state_,
            codeVerifier: codeVerifier,
            nonce: nonce,
            redirectUri: redirectUri,
          );
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(apiClientProvider).logout();
    state = const AsyncData(false);
  }
}
