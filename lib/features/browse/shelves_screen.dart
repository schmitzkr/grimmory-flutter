import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/providers.dart';
import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/empty_state.dart';

final shelvesListProvider = FutureProvider<List<Shelf>>((ref) async {
  return ref.read(apiClientProvider).getShelves();
});

final magicShelvesListProvider = FutureProvider<List<MagicShelf>>((ref) async {
  return ref.read(apiClientProvider).getMagicShelves();
});

/// Body of the "Shelves" tab on [HomeScreen]. Regular shelves are
/// display-only (see [Shelf]'s doc comment — the server has no endpoint to
/// list their books); magic shelves are tappable.
class ShelvesTab extends ConsumerWidget {
  const ShelvesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelves = ref.watch(shelvesListProvider);
    final magicShelves = ref.watch(magicShelvesListProvider);

    if (shelves.isLoading || magicShelves.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = shelves.error ?? magicShelves.error;
    if (error != null) {
      return ErrorRetryView(
        message: friendlyApiError(error),
        onRetry: () {
          ref.invalidate(shelvesListProvider);
          ref.invalidate(magicShelvesListProvider);
        },
      );
    }

    final regular = shelves.value ?? [];
    final magic = magicShelves.value ?? [];
    if (regular.isEmpty && magic.isEmpty) {
      return const EmptyState('No shelves found.');
    }

    return RefreshIndicator(
      onRefresh: () => Future.wait([
        ref.refresh(shelvesListProvider.future),
        ref.refresh(magicShelvesListProvider.future),
      ]),
      child: ListView(
        children: [
          if (magic.isNotEmpty) ...[
            const _SectionHeader('Shelves'),
            for (final shelf in magic)
              ListTile(
                leading: const Icon(Icons.auto_awesome_outlined),
                title: Text(shelf.name),
                trailing: shelf.publicShelf ? const _PublicBadge() : null,
                onTap: () => context.push('/shelves/magic/${shelf.id}'),
              ),
          ],
          if (regular.isNotEmpty) ...[
            const _SectionHeader('Collections'),
            for (final shelf in regular)
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(shelf.name),
                subtitle: Text(
                  '${shelf.bookCount} ${shelf.bookCount == 1 ? 'book' : 'books'}',
                ),
                trailing: shelf.publicShelf ? const _PublicBadge() : null,
              ),
          ],
        ],
      ),
    );
  }
}

/// A shelf every user on the server can see, not just its owner — the
/// same distinction the web UI draws with its globe icon.
class _PublicBadge extends StatelessWidget {
  const _PublicBadge();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Shared with all users',
      child: Icon(
        Icons.public,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
