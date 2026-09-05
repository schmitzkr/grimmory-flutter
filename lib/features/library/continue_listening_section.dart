import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import 'dashboard.dart';

/// Backs the "Continue Listening" dashboard row ([DashboardScrollerView])
/// and is the same source Android Auto's "Continue Listening" root uses via
/// GrimmoryAudioHandler.getChildren. Fetches the web's maximum row length;
/// each row then cuts to its own `maxItems`.
final continueListeningProvider = FutureProvider<List<Book>>((ref) async {
  return ref
      .read(apiClientProvider)
      .getContinueListening(limit: dashboardMaxItems);
});
