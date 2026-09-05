import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/errors.dart';
import '../../core/server_config.dart';
import 'server_url_provider.dart';

/// First-run "connect to your server" screen — Grimmory is self-hosted with
/// no fixed domain, so (unlike a fixed-backend app) every user has to enter
/// their own instance's URL before anything else can happen.
class ServerUrlScreen extends ConsumerStatefulWidget {
  const ServerUrlScreen({super.key});

  @override
  ConsumerState<ServerUrlScreen> createState() => _ServerUrlScreenState();
}

class _ServerUrlScreenState extends ConsumerState<ServerUrlScreen> {
  final _controller = TextEditingController();
  bool _checking = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final normalized = normalizeServerUrl(_controller.text);
    if (normalized == null) {
      setState(() => _error = 'Enter a valid server URL.');
      return;
    }

    setState(() {
      _checking = true;
      _error = null;
    });

    final failure = await _probe(normalized);
    if (!mounted) return;
    if (failure != null) {
      setState(() {
        _checking = false;
        _error = failure;
      });
      return;
    }

    // Persisting through the notifier is what re-runs the router's
    // redirect — it moves on to /login by itself once the URL is set.
    await ref.read(serverUrlProvider.notifier).set(normalized);
    if (!mounted) return;
    setState(() => _checking = false);
  }

  /// Null when the server answered at all. No confirmed unauthenticated
  /// health/version endpoint yet (M0) — a 401 here still proves the server
  /// is reachable and speaking the Grimmory API, so any HTTP response
  /// counts. Bounded timeouts: a black-holed host used to leave the spinner
  /// running forever.
  Future<String?> _probe(String serverUrl) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    try {
      await dio.get('$serverUrl/api/v1/libraries');
      return null;
    } on DioException catch (e) {
      return e.response?.statusCode == null ? friendlyApiError(e) : null;
    } catch (_) {
      return 'Could not reach that server.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Grimmory')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the address of your self-hosted Grimmory server.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                hintText: 'https://books.example.com',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _continue(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _checking ? null : _continue,
              child: _checking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
