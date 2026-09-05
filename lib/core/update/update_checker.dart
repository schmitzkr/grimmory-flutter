import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'update_service.dart';

/// Whether a newer release is available — one app-wide check, re-run on
/// resume and every six hours, throttled so a burst of triggers (two
/// banners mounted across a navigation transition, a resume right after a
/// tick) costs one request. The schedule lives in its own never-disposed
/// provider because Riverpod 3 recreates the notifier on every rebuild,
/// which is exactly when the throttle must *not* reset.
final updateCheckerProvider = AsyncNotifierProvider<UpdateChecker, AppRelease?>(
  UpdateChecker.new,
);

class UpdateChecker extends AsyncNotifier<AppRelease?> {
  static const throttle = Duration(seconds: 10);

  @override
  Future<AppRelease?> build() {
    ref.read(_scheduleProvider).lastCheck = DateTime.now();
    return fetchAvailableUpdate();
  }

  /// Re-checks unless one already ran within [throttle].
  void recheck() {
    final schedule = ref.read(_scheduleProvider);
    final last = schedule.lastCheck;
    if (last != null && DateTime.now().difference(last) < throttle) return;
    ref.invalidateSelf();
  }
}

final _scheduleProvider = Provider<_UpdateSchedule>((ref) {
  final schedule = _UpdateSchedule(
    recheck: () => ref.read(updateCheckerProvider.notifier).recheck(),
  );
  ref.onDispose(schedule.dispose);
  return schedule;
});

class _UpdateSchedule {
  _UpdateSchedule({required void Function() recheck})
    : _timer = Timer.periodic(const Duration(hours: 6), (_) => recheck()),
      _lifecycle = AppLifecycleListener(onResume: recheck);

  DateTime? lastCheck;
  final Timer _timer;
  final AppLifecycleListener _lifecycle;

  void dispose() {
    _timer.cancel();
    _lifecycle.dispose();
  }
}
