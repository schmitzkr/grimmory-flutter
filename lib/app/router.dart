import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/sso_settings_screen.dart';
import '../features/book/book_detail_screen.dart';
import '../features/browse/series_detail_screen.dart';
import '../features/library/home_screen.dart';
import '../features/library/library_detail_screen.dart';
import '../features/onboarding/server_url_screen.dart';
import '../features/player/player_screen.dart';
import '../features/settings/settings_screen.dart';

/// Single app-wide router, redirect-gated on [authProvider] and whether a
/// server URL has been configured yet — mirrors schmlist-flutter's
/// router.dart pattern (see the project plan, §2/§3.5).
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(ref),
    redirect: (context, state) {
      final prefs = ref.read(sharedPrefsProvider);
      final serverUrl = prefs.getString('server_url');
      final authState = ref.read(authProvider);

      final onOnboarding = state.matchedLocation == '/onboarding';
      final onLogin = state.matchedLocation == '/login';
      // Pre-login screen (configuring SSO before the user has signed in at
      // all) — exempt it the same way /login is exempt, or every visit
      // would immediately bounce back to /login.
      final onSsoSettings = state.matchedLocation == '/sso-settings';

      if (serverUrl == null || serverUrl.isEmpty) {
        return onOnboarding ? null : '/onboarding';
      }

      // Don't redirect while auth state is still loading — avoids bouncing
      // to /login mid cold-start before the stored refresh token has been
      // checked.
      if (authState.isLoading) return null;

      final loggedIn = authState.value ?? false;
      if (!loggedIn) {
        return (onLogin || onSsoSettings) ? null : '/login';
      }
      if (onOnboarding || onLogin) return '/libraries';

      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/libraries'),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const ServerUrlScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/sso-settings',
        builder: (context, state) => const SsoSettingsScreen(),
      ),
      GoRoute(
        path: '/libraries',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/libraries/:id',
        builder: (context, state) => LibraryDetailScreen(
          libraryId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/series/:name',
        builder: (context, state) =>
            SeriesDetailScreen(seriesName: state.pathParameters['name']!),
      ),
      GoRoute(
        path: '/books/:id',
        builder: (context, state) =>
            BookDetailScreen(bookId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/player',
        builder: (context, state) => const PlayerScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

/// Bridges Riverpod's [authProvider] into a [Listenable] so GoRouter
/// re-evaluates `redirect` whenever auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    ref.listen(authProvider, (previous, next) => notifyListeners());
  }
}
