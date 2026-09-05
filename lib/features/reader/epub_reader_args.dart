/// Extra passed via `context.push('/books/:id/read', extra: ...)`.
/// [jumpToCfi] overrides the server-saved resume position — used when
/// opening the reader from a specific bookmark on the book detail screen,
/// rather than "wherever I last left off". Optional by design: a deep link
/// or a restored route has no extra, and the reader needs nothing else (it
/// fetches its own title by id). In its own file so both
/// `book_detail_screen.dart` and `epub_reader_screen.dart` can depend on it
/// without depending on each other.
class EpubReaderArgs {
  const EpubReaderArgs({this.jumpToCfi});

  final String? jumpToCfi;
}
