import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/async_value_view.dart';
import '../widgets/empty_state.dart';
import 'update_checker.dart';
import 'update_service.dart';

/// Banner shown at the top of a screen when a newer app version is
/// available. Purely a view over [updateCheckerProvider], which owns the
/// checking schedule — mounting several banners costs nothing extra.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final release = ref.watch(updateCheckerProvider).value;
    if (release == null) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.primaryContainer,
      child: InkWell(
        onTap: () => _showUpdateSheet(context, release),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.system_update_outlined,
                size: 18,
                color: colors.onPrimaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Update available: v${release.version} — tap to see '
                  "what's new",
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontSize: 13,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: colors.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showUpdateSheet(BuildContext context, AppRelease release) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _UpdateSheet(release: release),
  );
}

/// Call this to show the What's New sheet from anywhere (e.g. Settings).
void showWhatsNewSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const _WhatsNewSheet(),
  );
}

class _UpdateSheet extends StatelessWidget {
  final AppRelease release;
  const _UpdateSheet({required this.release});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.system_update_outlined),
              const SizedBox(width: 10),
              Text(
                'Update available',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Version ${release.version}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (release.releaseNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              release.releaseNotes,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.download_outlined),
              label: const Text('Download & install'),
              onPressed: release.apkDownloadUrl == null
                  ? null
                  : () {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(context);
                      _runUpdate(messenger, release.apkDownloadUrl!);
                    },
            ),
          ),
        ],
      ),
    );
  }
}

/// Drives [downloadAndInstallUpdate] with a persistent progress snackbar,
/// then reports the outcome — the real reason on failure, with the browser
/// download offered as an explicit action rather than a silent fallback.
Future<void> _runUpdate(ScaffoldMessengerState messenger, String url) async {
  final progress = messenger.showSnackBar(
    const SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Text('Downloading update…'),
        ],
      ),
      duration: Duration(minutes: 10),
    ),
  );

  final result = await downloadAndInstallUpdate(url);
  progress.close();

  switch (result) {
    case UpdateInstallStarted():
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Install started — close and reopen the app once it completes.',
          ),
          duration: Duration(seconds: 6),
        ),
      );
    case UpdateInstallNeedsPermission():
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Allow "Install unknown apps" for GrimReader in Settings, then '
            'tap the update banner again.',
          ),
          duration: Duration(seconds: 8),
        ),
      );
    case UpdateInstallFailed(:final message):
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Open in browser',
            onPressed: () =>
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          ),
        ),
      );
  }
}

class _WhatsNewSheet extends ConsumerWidget {
  const _WhatsNewSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releases = ref.watch(appReleasesProvider);
    final installed = ref.watch(installedVersionProvider).value;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.85,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                const Icon(Icons.new_releases_outlined),
                const SizedBox(width: 10),
                Text(
                  "What's new",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (installed != null)
                  Text(
                    'Installed ${installed.label}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: AsyncValueView(
              value: releases,
              errorMessage: 'Could not load release history.',
              onRetry: () => ref.invalidate(appReleasesProvider),
              data: (list) {
                if (list.isEmpty) return const EmptyState('No releases yet.');
                return ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 32),
                  itemBuilder: (_, i) => _ReleaseEntry(
                    release: list[i],
                    isLatest: i == 0,
                    isInstalled: installed?.matches(list[i]) ?? false,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, {required this.background, required this.foreground});

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: foreground),
      ),
    );
  }
}

class _ReleaseEntry extends StatelessWidget {
  const _ReleaseEntry({
    required this.release,
    required this.isLatest,
    required this.isInstalled,
  });

  final AppRelease release;
  final bool isLatest;

  /// This entry is the build that is running — so the reader can see at a
  /// glance how far behind (or not) the phone is.
  final bool isInstalled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'v${release.version}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isLatest) ...[
              const SizedBox(width: 8),
              _Badge(
                'latest',
                background: theme.colorScheme.primaryContainer,
                foreground: theme.colorScheme.onPrimaryContainer,
              ),
            ],
            if (isInstalled) ...[
              const SizedBox(width: 8),
              _Badge(
                'installed',
                background: theme.colorScheme.secondaryContainer,
                foreground: theme.colorScheme.onSecondaryContainer,
              ),
            ],
          ],
        ),
        if (release.releaseNotes.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(release.releaseNotes, style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }
}
