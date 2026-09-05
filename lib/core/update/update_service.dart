import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

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
    connectTimeout: const Duration(seconds: 10),
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

/// The newest published (non-prerelease, non-draft) [AppRelease] if it's
/// actually newer than the installed version, null otherwise — including on
/// any network/parse error, so a flaky connection or (while this repo is
/// still private, per its GitHub API access rules) a plain 404 just means
/// "no banner", not a visible error state.
Future<AppRelease?> fetchAvailableUpdate() async {
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
}

/// The last 10 published releases, newest first, for the "What's New"
/// sheet — empty (not an error) on any failure, same reasoning as
/// [fetchAvailableUpdate].
Future<List<AppRelease>> fetchRecentReleases() async {
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
}

final appReleasesProvider = FutureProvider.autoDispose<List<AppRelease>>(
  (ref) => fetchRecentReleases(),
);

/// The build that is actually running — `pubspec.yaml`'s `version`
/// (`0.11.18`) and build number (`41`) as the installed APK reports them.
/// Never changes while the process lives, so it is read once.
final installedVersionProvider = FutureProvider<InstalledVersion>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return InstalledVersion(version: info.version, buildNumber: info.buildNumber);
});

class InstalledVersion {
  const InstalledVersion({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  /// `v0.11.18 (41)`; just `v0.11.18` when the build number is blank.
  String get label => formatInstalledVersion(version, buildNumber);

  /// Whether a release entry is this build — release tags carry the
  /// version alone, without the build number.
  bool matches(AppRelease release) => release.version == version;
}

String formatInstalledVersion(String version, String buildNumber) =>
    buildNumber.isEmpty ? 'v$version' : 'v$version ($buildNumber)';

sealed class UpdateInstallResult {
  const UpdateInstallResult();
}

/// The system installer has been handed the APK.
final class UpdateInstallStarted extends UpdateInstallResult {
  const UpdateInstallStarted();
}

/// Android refused because "Install unknown apps" isn't granted for this app.
final class UpdateInstallNeedsPermission extends UpdateInstallResult {
  const UpdateInstallNeedsPermission();
}

final class UpdateInstallFailed extends UpdateInstallResult {
  const UpdateInstallFailed(this.message);

  final String message;
}

const _installChannel = MethodChannel('is.schmitzkr.grimmory/download');

/// Downloads the APK with Dio (follows GitHub's redirect to the asset CDN),
/// verifies it arrived whole, and hands it to the native installer. Never
/// throws — every failure comes back as [UpdateInstallFailed] with the real
/// reason, for the caller to show.
Future<UpdateInstallResult> downloadAndInstallUpdate(String url) async {
  try {
    final dir = await getTemporaryDirectory();
    final savePath = '${dir.path}/grimreader-update.apk';

    // A stale file must never be installed in place of the new build.
    final file = File(savePath);
    if (file.existsSync()) file.deleteSync();

    final response = await Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(minutes: 5),
      ),
    ).download(url, savePath);

    // Dio.download doesn't itself verify the saved file is complete — a
    // dropped connection can leave a truncated file on disk with no
    // exception thrown, which the installer then rejects as "app not
    // installed as package appears to be invalid".
    final expectedSize = int.tryParse(
      response.headers.value(Headers.contentLengthHeader) ?? '',
    );
    final downloadedSize = await file.length();
    if (expectedSize != null && downloadedSize != expectedSize) {
      return UpdateInstallFailed(
        'The download was incomplete ($downloadedSize of $expectedSize '
        'bytes). Check your connection and try again.',
      );
    }

    final result = await _installChannel.invokeMethod<String>('installApk', {
      'path': savePath,
    });
    if (result == 'permission_required') {
      return const UpdateInstallNeedsPermission();
    }
    return const UpdateInstallStarted();
  } on DioException catch (e) {
    return UpdateInstallFailed('Download failed: ${e.message ?? e.type.name}');
  } on PlatformException catch (e) {
    return UpdateInstallFailed('Install failed: ${e.message ?? e.code}');
  } catch (e) {
    return UpdateInstallFailed('Update failed: $e');
  }
}
