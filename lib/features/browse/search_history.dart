/// The last few queries, newest first, without duplicates and without
/// blanks — what the search view offers before anything is typed.
const searchHistoryMax = 8;

List<String> rememberSearch(
  List<String> history,
  String query, {
  int max = searchHistoryMax,
}) {
  final q = query.trim();
  if (q.isEmpty) return List.of(history);
  final lower = q.toLowerCase();
  return [
    q,
    ...history.where((h) => h.trim().toLowerCase() != lower),
  ].take(max).toList();
}
