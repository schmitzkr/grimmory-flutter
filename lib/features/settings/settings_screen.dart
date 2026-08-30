import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            leading: const Icon(Icons.logout),
            title: const Text('Change server / sign out'),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              await ref.read(sharedPrefsProvider).remove('server_url');
            },
          ),
        ],
      ),
    );
  }
}
