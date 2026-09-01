import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_carousel.dart';

final recentlyAddedProvider = FutureProvider<List<Book>>((ref) async {
  return ref.read(apiClientProvider).getRecentlyAdded();
});

class RecentlyAddedSection extends ConsumerWidget {
  const RecentlyAddedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(recentlyAddedProvider).value ?? [];
    return BookCarousel(title: 'Recently Added', books: books);
  }
}
