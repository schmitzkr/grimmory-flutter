import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// This app has no backend of its own to serve version metadata from (unlike
/// schmlist, whose server exposes `/api/app-version`/`/api/app-releases`) —
/// GitHub's own Releases API stands in for both, which is exactly what
/// `.github/workflows/release.yml` already publishes to.
///
/// GitHub requires a `User-Agent` header on every REST API request or it
/// rejects with a 403 — see
/// https://docs.github.com/rest/overview/resources-in-the-rest-api#user-agent-required.
final _github = Dio(
  BaseOptions(
    baseUrl: 'https://api.github.com/repos/schmitzkr/grimreader-flutter',
    headers: {
      'Accept': 'application/vnd.github+json',
      'User-Agent': 'grimreader-flutter',
    },
    receiveTimeout: const Duration(seconds: 10),
  ),
);

class AppRelease {
  final String version;
  final String releaseNotes;
  final DateTime? releasedAt;

  /// The `grimreader.apk` asset's direct download URL — null if a release
  /// somehow has no such asset yet (e.g. checked mid-upload).
  final String? apkDownloadUrl;
  final bool prerelease;

  const AppRelease({
    required this.version,
    required this.releaseNotes,
    required this.releasedAt,
    required this.apkDownloadUrl,
    required this.prerelease,
  });

  factory AppRelease.fromGithubJson(Map<String, dynamic> j) {
    final assets = (j['assets'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final apkAsset = assets.cast<Map<String, dynamic>?>().firstWhere(
      (a) => a?['name'] == 'grimreader.apk',
      orElse: () => null,
    );
    return AppRelease(
      version: (j['tag_name'] as String? ?? '').replaceFirst(RegExp('^v'), ''),
      releaseNotes: (j['body'] as String?)?.trim() ?? '',
      releasedAt: DateTime.tryParse(j['published_at'] as String? ?? ''),
      apkDownloadUrl: apkAsset?['browser_download_url'] as String?,
      prerelease: j['prerelease'] as bool? ?? false,
    );
  }
}

/// Returns the newest published (non-prerelease, non-draft) [AppRelease] if
/// it's actually newer than the installed version, null otherwise —
/// including on any network/parse error, so a flaky connection or (while
/// this repo is still private, per its GitHub API access rules) a plain
/// 404 just means "no banner", not a visible error state.
final updateProvider = FutureProvider<AppRelease?>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    final current = parseVersion(info.version);
    if (current == null) return null;

    final response = await _github.get<Map<String, dynamic>>(
      '/releases/latest',
    );
    if (response.statusCode != 200 || response.data == null) return null;

    final release = AppRelease.fromGithubJson(response.data!);
    final latest = parseVersion(release.version);
    if (latest == null || !isNewerVersion(latest, current)) return null;
    if (release.apkDownloadUrl == null) return null;

    return release;
  } catch (_) {
    return null;
  }
});

/// Returns the last 10 published releases, newest first, for the "What's
/// New" sheet — empty (not an error) on any failure, same reasoning as
/// [updateProvider].
final appReleasesProvider = FutureProvider<List<AppRelease>>((ref) async {
  try {
    final response = await _github.get<List<dynamic>>(
      '/releases',
      queryParameters: {'per_page': 10},
    );
    if (response.statusCode != 200 || response.data == null) return [];
    return response.data!
        .whereType<Map<String, dynamic>>()
        .map(AppRelease.fromGithubJson)
        .toList();
  } catch (_) {
    return [];
  }
});

// Shared throttle — prevents multiple banner instances (e.g. HomeScreen and
// LoginScreen mounted at once during a navigation transition) from stacking
// checks.
DateTime? _lastUpdateCheck;

/// Banner shown at the top of a screen when a newer app version is
/// available. Re-checks on app resume and every 6 hours while the app is
/// open.
class UpdateBanner extends ConsumerStatefulWidget {
  const UpdateBanner({super.key});

  @override
  ConsumerState<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends ConsumerState<UpdateBanner>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(hours: 6), (_) => _recheck());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _recheck();
  }

  void _recheck() {
    final now = DateTime.now();
    if (_lastUpdateCheck != null &&
        now.difference(_lastUpdateCheck!) < const Duration(seconds: 10)) {
      return;
    }
    _lastUpdateCheck = now;
    ref.invalidate(updateProvider);
  }

  @override
  Widget build(BuildContext context) {
    final update = ref.watch(updateProvider);
    return update.maybeWhen(
      data: (release) {
        if (release == null) return const SizedBox.shrink();
        return Material(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: InkWell(
            onTap: () => _showUpdateSheet(context, release),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.system_update_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Update available: v${release.version} — tap to see '
                      "what's new",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
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
                      _startUpdate(messenger, release.apkDownloadUrl!);
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _WhatsNewSheet extends ConsumerWidget {
  const _WhatsNewSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releases = ref.watch(appReleasesProvider);
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
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: releases.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) =>
                  const Center(child: Text('Could not load release history')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(child: Text('No releases yet'));
                }
                return ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 32),
                  itemBuilder: (_, i) {
                    final r = list[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'v${r.version}',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            if (i == 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'latest',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (r.releaseNotes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            r.releaseNotes,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

const _channel = MethodChannel('is.schmitzkr.grimmory/download');

/// Downloads the APK using Dio (handles redirects correctly), then hands off
/// to the native installer via method channel.
Future<void> _startUpdate(ScaffoldMessengerState messenger, String url) async {
  // Persistent spinner snackbar while downloading
  final snackController = messenger.showSnackBar(
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

  try {
    final dir = await getTemporaryDirectory();
    final savePath = '${dir.path}/grimreader-update.apk';

    // Remove stale file so we never install an old build
    final file = File(savePath);
    if (file.existsSync()) file.deleteSync();

    final response = await Dio(
      BaseOptions(receiveTimeout: const Duration(minutes: 5)),
    ).download(url, savePath);

    // Dio.download doesn't itself verify the saved file is complete -- a
    // dropped connection can leave a truncated file on disk with no
    // exception thrown, which the installer then rejects as "app not
    // installed as package appears to be invalid". Compare against
    // Content-Length so a bad download hits the catch block below (which
    // already retries via the browser) instead of reaching installApk.
    final expectedSize = int.tryParse(
      response.headers.value(Headers.contentLengthHeader) ?? '',
    );
    final downloadedSize = await file.length();
    if (expectedSize != null && downloadedSize != expectedSize) {
      throw Exception(
        'Downloaded update was incomplete ($downloadedSize of $expectedSize bytes)',
      );
    }

    snackController.close();

    final result = await _channel.invokeMethod<String>('installApk', {
      'path': savePath,
    });

    if (result == 'permission_required') {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Allow "Install unknown apps" for GrimReader in Settings, then '
            'tap the update banner again.',
          ),
          duration: Duration(seconds: 8),
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Install started — close and reopen the app once it completes.',
          ),
          duration: Duration(seconds: 6),
        ),
      );
    }
  } catch (e) {
    snackController.close();
    // Fallback: open the download URL directly in the browser
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }
}

/// `"0.11.9"` → `[0, 11, 9]`; null for anything that isn't dot-separated
/// integers (a stray `v` prefix, a build suffix, an empty string).
List<int>? parseVersion(String v) {
  try {
    return v.split('.').map(int.parse).toList();
  } catch (_) {
    return null;
  }
}

/// Component-wise comparison; a longer version with an equal prefix counts
/// as newer (`1.0.1` > `1.0`), a shorter one does not.
bool isNewerVersion(List<int> latest, List<int> current) {
  for (var i = 0; i < latest.length && i < current.length; i++) {
    if (latest[i] > current[i]) return true;
    if (latest[i] < current[i]) return false;
  }
  return latest.length > current.length;
}
