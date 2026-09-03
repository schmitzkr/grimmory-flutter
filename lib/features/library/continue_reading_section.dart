import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_carousel.dart';

final continueReadingProvider = FutureProvider<List<Book>>((ref) async {
  return ref.read(apiClientProvider).getContinueReading();
});

/// Ebook counterpart to [ContinueListeningSection] — same
/// `/app/books/continue-*` split Grimmory's own server already makes
/// between audiobooks and everything else.
class ContinueReadingSection extends ConsumerWidget {
  const ContinueReadingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(continueReadingProvider).value ?? [];
    return BookCarousel(title: 'Continue Reading', books: books);
  }
}
