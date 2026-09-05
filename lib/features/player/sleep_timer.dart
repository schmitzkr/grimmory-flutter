import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'playback_provider.dart';

/// Not part of the confirmed API surface — standard audiobook-app feature,
/// cheap to add, no server interaction needed. Flagged as an assumption in
/// the project plan rather than something explicitly requested.
final sleepTimerProvider = NotifierProvider<SleepTimerNotifier, Duration?>(
  SleepTimerNotifier.new,
);

class SleepTimerNotifier extends Notifier<Duration?> {
  Timer? _ticker;
  // The book the running timer was started for — it stops meaning anything
  // once playback stops or a different book loads, and must not fire a
  // pause on whatever plays next. Checked on each tick straight off the
  // handler's own subject rather than through Riverpod: Riverpod 3
  // deactivates a provider's `ref.listen` subscriptions — and pauses a
  // StreamProvider's underlying stream — whenever nothing is actively
  // watching, which is every screen but the player, so both a listener in
  // build() and a `ref.read(currentMediaItemProvider)` went stale there.
  int? _startedForBookId;

  int? get _currentBookId =>
      ref.read(audioHandlerProvider).mediaItem.valueOrNull?.extras?['bookId']
          as int?;

  @override
  Duration? build() {
    ref.onDispose(() => _ticker?.cancel());
    return null;
  }

  void start(Duration duration) {
    _ticker?.cancel();
    _startedForBookId = _currentBookId;
    state = duration;
    _scheduleTick();
  }

  void cancel() {
    _ticker?.cancel();
    _ticker = null;
    _startedForBookId = null;
    state = null;
  }

  void _scheduleTick() {
    _ticker = Timer(const Duration(seconds: 1), () {
      final remaining = state;
      if (remaining == null) return;
      if (_currentBookId != _startedForBookId) {
        cancel();
        return;
      }
      final next = remaining - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        _ticker = null;
        _startedForBookId = null;
        state = null;
        ref.read(audioHandlerProvider).pause();
      } else {
        state = next;
        _scheduleTick();
      }
    });
  }
}

Future<void> showSleepTimerSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    builder: (context) => const _SleepTimerSheet(),
  );
}

class _SleepTimerSheet extends ConsumerWidget {
  const _SleepTimerSheet();

  static const _presets = [
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 45),
    Duration(minutes: 60),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(sleepTimerProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Sleep timer', style: TextStyle(fontSize: 18)),
          ),
          for (final preset in _presets)
            ListTile(
              title: Text('${preset.inMinutes} minutes'),
              onTap: () {
                ref.read(sleepTimerProvider.notifier).start(preset);
                Navigator.of(context).pop();
              },
            ),
          if (active != null)
            ListTile(
              leading: const Icon(Icons.cancel_outlined),
              title: const Text('Cancel timer'),
              onTap: () {
                ref.read(sleepTimerProvider.notifier).cancel();
                Navigator.of(context).pop();
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
