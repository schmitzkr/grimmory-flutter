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

  @override
  Duration? build() {
    ref.onDispose(() => _ticker?.cancel());
    return null;
  }

  void start(Duration duration) {
    _ticker?.cancel();
    state = duration;
    _scheduleTick();
  }

  void cancel() {
    _ticker?.cancel();
    _ticker = null;
    state = null;
  }

  void _scheduleTick() {
    _ticker = Timer(const Duration(seconds: 1), () {
      final remaining = state;
      if (remaining == null) return;
      final next = remaining - const Duration(seconds: 1);
      if (next <= Duration.zero) {
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
