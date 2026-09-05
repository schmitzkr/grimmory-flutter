import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import 'dashboard.dart';

/// Backs the "Continue Reading" dashboard row ([DashboardScrollerView]) —
/// the ebook counterpart to [continueListeningProvider], same audiobook /
/// everything-else split the server makes.
final continueReadingProvider = FutureProvider<List<Book>>((ref) async {
  return ref
      .read(apiClientProvider)
      .getContinueReading(limit: dashboardMaxItems);
});
