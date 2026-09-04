import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/update_provider.dart';
import '../browse/authors_screen.dart';
import '../browse/search_screen.dart';
import '../browse/series_screen.dart';
import '../browse/shelves_screen.dart';
import '../player/mini_player.dart';
import 'libraries_screen.dart';

/// Post-login landing screen — bottom-nav shell over the top-level browse
/// destinations. Each tab keeps its own state via IndexedStack rather than
/// being rebuilt from scratch on every switch.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = ['Home', 'Series', 'Authors', 'Shelves', 'Search'];
  static const _tabs = [
    LibrariesTab(),
    SeriesTab(),
    AuthorsTab(),
    ShelvesTab(),
    SearchTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _index == 0
            ? const HomeLibrarySelector()
            : Text(_titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          const UpdateBanner(),
          Expanded(
            child: IndexedStack(index: _index, children: _tabs),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (index) => setState(() => _index = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.collections_bookmark_outlined),
                selectedIcon: Icon(Icons.collections_bookmark),
                label: 'Series',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Authors',
              ),
              NavigationDestination(
                icon: Icon(Icons.shelves),
                label: 'Shelves',
              ),
              NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
            ],
          ),
        ],
      ),
    );
  }
}
