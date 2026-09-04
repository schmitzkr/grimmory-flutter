import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/errors.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_grid.dart';

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

  @override
  void dispose() {
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

    // SearchAnchor calls suggestionsBuilder on every keystroke with no
    // debounce of its own — wait, then bail out if the text has since moved
    // on, so a fast typist doesn't fire one request per character.
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted || controller.text.trim() != query) return const [];

    try {
      final results = await ref.read(apiClientProvider).searchBooks(query);
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
