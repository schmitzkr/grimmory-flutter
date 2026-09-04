/// Extra passed via `context.push('/books/:id/read', extra: ...)`.
/// [jumpToCfi] overrides the server-saved resume position — used when
/// opening the reader from a specific bookmark on the book detail screen,
/// rather than "wherever I last left off". In its own file so both
/// `book_detail_screen.dart` and `epub_reader_screen.dart` can depend on it
/// without depending on each other.
class EpubReaderArgs {
  const EpubReaderArgs({required this.title, this.jumpToCfi});

  final String title;
  final String? jumpToCfi;
}
