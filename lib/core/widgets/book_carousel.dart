import 'package:flutter/material.dart';

import '../api/models.dart';
import 'book_grid.dart';

/// A titled horizontal row of book covers — shared by the Libraries tab's
/// Continue Listening and Recently Added sections. Renders nothing (not
/// even an empty state) when [books] is empty, since both callers use this
/// as a bonus shortcut on top of the tab, not a primary view worth an
/// empty/error state of its own.
class BookCarousel extends StatelessWidget {
  const BookCarousel({required this.title, required this.books, super.key});

  final String title;
  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: books.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 130,
                child: BookGridTile(book: books[index]),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
