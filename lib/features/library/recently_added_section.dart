import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';

/// `null` (All Libraries) uses the dedicated `/app/books/recently-added`
/// endpoint. A specific library has no server-side "recently added" filter
/// of its own (confirmed against `AppBookController` — `getRecentlyAdded`
/// takes only `limit`), so that case reuses the general `/app/books` list
/// sorted by `addedon desc`, which is the same ordering scoped to one
/// library.
final recentlyAddedProvider = FutureProvider.family<List<Book>, int?>((
  ref,
  libraryId,
) async {
  final api = ref.read(apiClientProvider);
  if (libraryId == null) return api.getRecentlyAdded(limit: 30);
  return api.getLibraryBooks(
    libraryId,
    sort: 'addedon',
    dir: 'desc',
    size: 30,
  );
});
