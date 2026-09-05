import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/errors.dart';
import '../../core/providers.dart';
import '../../core/widgets/book_grid.dart';
import 'search_debouncer.dart';
import 'search_history.dart';

const _historyKey = 'recent_searches';

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

  List<String> get _history =>
      ref.read(sharedPrefsProvider).getStringList(_historyKey) ?? const [];

  Future<void> _remember(String query) async {
    final next = rememberSearch(_history, query);
    await ref.read(sharedPrefsProvider).setStringList(_historyKey, next);
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      searchController: _searchController,
      barHintText: 'Search by title, author, narrator…',
      barElevation: const WidgetStatePropertyAll(0),
      // A clear button while there is text — the view's field has none of
      // its own, so emptying a query meant backspacing through it.
      viewTrailing: [
        ValueListenableBuilder(
          valueListenable: _searchController,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.close),
                  onPressed: _searchController.clear,
                ),
        ),
      ],
      onSubmitted: (query) => _remember(query),
      suggestionsBuilder: (context, controller) => _buildResults(controller),
    );
  }

  Future<Iterable<Widget>> _buildResults(SearchController controller) async {
    final query = controller.text.trim();
    if (query.isEmpty) {
      final history = _history;
      if (history.isEmpty) {
        return const [
          Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Start typing to search.')),
          ),
        ];
      }
      return [
        for (final past in history)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(past),
            onTap: () => controller.text = past,
          ),
        ListTile(
          leading: const Icon(Icons.delete_sweep_outlined),
          title: const Text('Clear search history'),
          onTap: () async {
            await ref.read(sharedPrefsProvider).remove(_historyKey);
            // Re-run the (empty) query so the list disappears.
            controller.text = ' ';
            controller.clear();
          },
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
      // A query that produced results is worth remembering.
      unawaited(_remember(query));
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            '${results.length} ${results.length == 1 ? 'result' : 'results'}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
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
