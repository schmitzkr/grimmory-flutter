import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/errors.dart';

/// The one loading / error-with-retry / data switch every screen used to
/// hand-roll — eleven near-identical copies of the same `when(...)` block.
/// [data] builds the loaded state; a refresh keeps showing the previous
/// data (Riverpod's default `skipLoadingOnRefresh`) so pull-to-refresh
/// doesn't flash a spinner over a populated list.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.data,
    required this.onRetry,
    this.errorMessage,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback onRetry;

  /// Fixed copy for the error state instead of the mapped API error — for
  /// secondary content (a bookmark list, a filter sheet) where the exact
  /// server message adds nothing.
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorRetryView(
        message: errorMessage ?? friendlyApiError(error),
        onRetry: onRetry,
      ),
    );
  }
}

/// Centered message with a Retry button — the error half of
/// [AsyncValueView], on its own for screens that combine several providers.
class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
