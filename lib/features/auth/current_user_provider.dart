import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import 'auth_provider.dart';

/// The signed-in account. Rebuilt whenever [authProvider] changes, so a
/// sign-out followed by a sign-in as someone else never shows the previous
/// person; otherwise cached for the session (the profile does not change
/// behind the app's back in any way a screen here cares about).
final currentUserProvider = FutureProvider<CurrentUser>((ref) async {
  ref.watch(authProvider);
  return ref.read(apiClientProvider).getCurrentUser();
});
