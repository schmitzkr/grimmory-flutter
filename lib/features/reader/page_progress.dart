/// 0-100 for being on page [pageIndex] (0-based) of [pageCount], rounded to
/// one decimal — exactly Grimmory's web comic reader:
/// `Math.round(((currentPage + 1) / pages.length) * 1000) / 10`. Reaching the
/// last page therefore reports 100, which crosses the server's `READ`
/// threshold (99.5) the same way the web does.
double pagePercentage({required int pageIndex, required int pageCount}) {
  if (pageCount <= 0) return 0;
  final clamped = pageIndex.clamp(0, pageCount - 1);
  return ((clamped + 1) / pageCount * 1000).round() / 10;
}
