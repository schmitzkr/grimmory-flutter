import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/update_provider.dart';
import '../../core/api/errors.dart';
import '../../core/api/models.dart';
import '../../core/theme_mode_provider.dart';
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
            subtitle: Text(switch (ref.watch(installedVersionProvider).value) {
              final v? => 'Installed ${v.label}',
              null => 'Installed version…',
            }),
            onTap: () => showWhatsNewSheet(context, ref),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {ref.watch(themeModeProvider)},
                onSelectionChanged: (s) =>
                    ref.read(themeModeProvider.notifier).set(s.first),
              ),
            ),
          ),
          const Divider(),
          // The Home tab mirrors the web dashboard's saved layout; there is
          // no editor here yet, so say where the rows come from.
          ListTile(
            leading: const Icon(Icons.dashboard_customize_outlined),
            title: const Text('Home layout'),
            subtitle: const Text(
              'Rows and their order follow your dashboard settings on the web',
            ),
            trailing: const Icon(Icons.open_in_browser),
            onTap: serverUrl == null
                ? null
                : () => launchUrl(
                    Uri.parse('$serverUrl/settings'),
                    mode: LaunchMode.externalApplication,
                  ),
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
            leading: const Icon(Icons.info_outline),
            title: const Text('About GrimReader'),
            subtitle: const Text('Source code, issues, open-source licences'),
            onTap: () => _showAbout(context, ref),
          ),
          const Divider(),
          // Signing out and changing server are different intentions: the
          // first keeps the server and lands on the login screen (switching
          // accounts on the same instance), the second goes back to
          // onboarding. Both end the session, so both confirm first.
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            subtitle: const Text('Keep the server, return to sign-in'),
            onTap: () async {
              final ok = await _confirm(
                context,
                title: 'Sign out?',
                body: 'You will need to sign in again to read or listen.',
                action: 'Sign out',
              );
              if (!ok) return;
              await ref.read(authProvider.notifier).logout();
            },
          ),
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: const Text('Change server'),
            subtitle: const Text('Sign out and connect to a different server'),
            onTap: () async {
              final ok = await _confirm(
                context,
                title: 'Change server?',
                body: 'This signs you out and asks for a server address again.',
                action: 'Change server',
              );
              if (!ok) return;
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

const _repoUrl = 'https://github.com/schmitzkr/grimreader-flutter';

void _showAbout(BuildContext context, WidgetRef ref) {
  final version = ref.read(installedVersionProvider).value?.label ?? '';
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('GrimReader'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (version.isNotEmpty) Text('Version $version'),
          const SizedBox(height: 8),
          const Text(
            'An unofficial Android app for Grimmory: audiobooks, EPUBs, '
            'comics and PDFs from your own server.',
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(_repoUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.code),
            label: const Text('Source on GitHub'),
          ),
          TextButton.icon(
            onPressed: () => launchUrl(
              Uri.parse('$_repoUrl/issues'),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.bug_report_outlined),
            label: const Text('Report an issue'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              showLicensePage(
                context: context,
                applicationName: 'GrimReader',
                applicationVersion: version,
              );
            },
            icon: const Icon(Icons.description_outlined),
            label: const Text('Open-source licences'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );
  return result ?? false;
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
          tooltip: 'Retry',
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
