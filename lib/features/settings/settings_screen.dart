import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/update_provider.dart';
import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../auth/auth_provider.dart';
import '../auth/current_user_provider.dart';
import '../onboarding/server_url_provider.dart';
import '../player/mini_player.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SignedInAs(),
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: const Text('Server'),
            subtitle: Text(serverUrl ?? 'Not set'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Downloads'),
            onTap: () => context.push('/downloads'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.new_releases_outlined),
            title: const Text("What's new"),
            onTap: () => showWhatsNewSheet(context, ref),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.battery_alert_outlined),
            title: const Text('Background playback getting interrupted?'),
            subtitle: const Text(
              'Exclude GrimReader from battery optimization',
            ),
            onTap: () => _showBatteryOptimizationDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Change server / sign out'),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              // The router listens to both; clearing the URL last lands on
              // /onboarding without a manual navigation.
              await ref.read(serverUrlProvider.notifier).clear();
            },
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}

/// Who is signed in — display name, account name, e-mail, and whether the
/// session came through SSO — so a shared phone or a second account is
/// never a guess. The same `/users/me` request also feeds the dashboard.
class _SignedInAs extends ConsumerWidget {
  const _SignedInAs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final scheme = Theme.of(context).colorScheme;
    return user.when(
      loading: () => const ListTile(
        leading: CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text('Signed in'),
        subtitle: Text('Loading account…'),
      ),
      error: (error, _) => ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_off_outlined)),
        title: const Text('Signed in'),
        subtitle: Text('Could not load account: ${friendlyApiError(error)}'),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(currentUserProvider),
        ),
      ),
      data: (user) => ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Text(_initials(user)),
        ),
        title: Text(user.displayName),
        subtitle: Text(_accountLine(user)),
        trailing: (user.permissions?.isAdmin ?? false)
            ? Chip(
                label: const Text('Admin'),
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
                backgroundColor: scheme.secondaryContainer,
              )
            : null,
      ),
    );
  }

  static String _initials(CurrentUser user) {
    final parts = user.displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  /// "username · email · via SSO", dropping whatever is absent or would
  /// only repeat the title.
  static String _accountLine(CurrentUser user) {
    final bits = <String>[
      if (user.displayName != user.username) user.username,
      if (user.email != null && user.email!.isNotEmpty) user.email!,
      if (user.signedInWithSso) 'Signed in with SSO',
    ];
    return bits.isEmpty ? 'Local account' : bits.join(' · ');
  }
}

/// Background audio playback (a foreground service, same mechanism every
/// audio/podcast app uses) can still get killed by some manufacturers'
/// aggressive battery management, cutting playback when the screen is off
/// or the app is backgrounded. No plugin dependency added just for a deep
/// link into system settings — the exact path varies enough by
/// manufacturer (stock Android vs. Samsung/Xiaomi/OnePlus battery
/// managers) that a plain explanation is more reliable than guessing at
/// one intent.
void _showBatteryOptimizationDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Background playback'),
      content: const Text(
        'If playback stops unexpectedly when the screen is off or the '
        'app is in the background, your device may be aggressively '
        "battery-optimizing GrimReader. To fix it, find GrimReader in your "
        'phone\'s Settings → Apps → Battery (the exact wording varies by '
        'manufacturer) and set it to "Unrestricted" or "Not optimized".',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}
