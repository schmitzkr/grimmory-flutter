import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_list_screen.dart';

final seriesBooksProvider = FutureProvider.autoDispose
    .family<List<Book>, String>((ref, seriesName) async {
      return ref.read(apiClientProvider).getSeriesBooks(seriesName);
    });

class SeriesDetailScreen extends StatelessWidget {
  const SeriesDetailScreen({required this.seriesName, super.key});

  final String seriesName;

  @override
  Widget build(BuildContext context) {
    return BookListScreen(
      title: seriesName,
      provider: seriesBooksProvider(seriesName),
      emptyMessage: 'No books in this series.',
    );
  }
}
