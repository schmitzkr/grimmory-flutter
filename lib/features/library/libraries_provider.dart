import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';

/// Every library the account can see — the Libraries tab's list and the
/// source of a library's name for its detail screen's title. Its own file
/// so the tab and the detail screen can both read it without importing
/// each other.
final librariesProvider = FutureProvider<List<Library>>((ref) async {
  return ref.read(apiClientProvider).getLibraries();
});
