import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_carousel.dart';

final continueListeningProvider = FutureProvider<List<Book>>((ref) async {
  return ref.read(apiClientProvider).getContinueListening();
});

/// The phone-UI equivalent of the "Continue Listening" root Android Auto
/// already gets from the same [continueListeningProvider] endpoint via
/// GrimmoryAudioHandler.getChildren.
class ContinueListeningSection extends ConsumerWidget {
  const ContinueListeningSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(continueListeningProvider).value ?? [];
    return BookCarousel(title: 'Continue Listening', books: books);
  }
}
