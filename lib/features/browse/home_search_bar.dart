import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/errors.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_grid.dart';
import 'search_debouncer.dart';

/// Search, promoted to a persistent Material 3 search bar living in
/// [HomeScreen]'s AppBar title — reachable from every tab instead of being
/// buried as its own equal-weight bottom-nav destination (the former
/// SearchTab/searchResultsProvider, now fully superseded by this).
class HomeSearchBar extends ConsumerStatefulWidget {
  const HomeSearchBar({super.key});

  @override
  ConsumerState<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends ConsumerState<HomeSearchBar> {
  final _searchController = SearchController();
  // SearchAnchor calls suggestionsBuilder on every keystroke with no
  // debounce of its own; this coalesces a burst into one request and drops
  // any response that a newer keystroke has since overtaken.
  final _debouncer = SearchDebouncer();

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      searchController: _searchController,
      barHintText: 'Search by title, author, narrator…',
      barElevation: const WidgetStatePropertyAll(0),
      suggestionsBuilder: (context, controller) => _buildResults(controller),
    );
  }

  Future<Iterable<Widget>> _buildResults(SearchController controller) async {
    final query = controller.text.trim();
    if (query.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Start typing to search.')),
        ),
      ];
    }

    try {
      final results = await _debouncer.run(
        () => ref.read(apiClientProvider).searchBooks(query),
      );
      // Superseded by a newer keystroke — SearchAnchor will render that
      // one's result instead.
      if (results == null || !mounted) return const [];
      if (results.isEmpty) {
        return const [
          Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No results.')),
          ),
        ];
      }
      return [
        BookGrid(
          books: results,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
      ];
    } catch (e) {
      return [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(friendlyApiError(e)),
        ),
      ];
    }
  }
}
