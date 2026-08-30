import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../auth/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(sharedPrefsProvider).getString('server_url');

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Server'),
            subtitle: Text(serverUrl ?? 'Not set'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.battery_alert_outlined),
            title: const Text('Background playback getting interrupted?'),
            subtitle: const Text('Exclude Grimmory from battery optimization'),
            onTap: () => _showBatteryOptimizationDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Change server / sign out'),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              await ref.read(sharedPrefsProvider).remove('server_url');
              // Same reasoning as server_url_screen.dart's post-save
              // navigation: logout() fires authProvider's state change
              // (which the router DOES react to), but that happens before
              // server_url is actually removed, and nothing re-triggers the
              // redirect a second time afterward — without this, the app
              // lands on /login (correct reaction to the logout alone) and
              // gets stuck there instead of proceeding to /onboarding, even
              // though there's no server configured anymore.
              if (context.mounted) context.go('/onboarding');
            },
          ),
        ],
      ),
    );
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
        "battery-optimizing Grimmory. To fix it, find Grimmory in your "
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
