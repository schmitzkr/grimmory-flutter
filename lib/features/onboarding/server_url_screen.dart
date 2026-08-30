import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/errors.dart';
import '../../core/providers.dart';
import '../../core/server_config.dart';

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

    final apiClient = ref.read(apiClientProvider);
    final prefs = ref.read(sharedPrefsProvider);
    apiClient.updateBaseUrl(normalized);

    try {
      // No confirmed unauthenticated health/version endpoint yet (M0) — a
      // 401 here still proves the server is reachable and speaking the
      // Grimmory API, so treat it the same as success.
      await Dio().get('$normalized/api/v1/libraries');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == null) {
        setState(() {
          _checking = false;
          _error = friendlyApiError(e);
        });
        return;
      }
      // Any HTTP response (even 401/403) means the server was reachable.
    } catch (e) {
      setState(() {
        _checking = false;
        _error = 'Could not reach that server.';
      });
      return;
    }

    await prefs.setString('server_url', normalized);
    if (!mounted) return;
    setState(() => _checking = false);
    // The router's redirect (gated on authProvider) takes over from here.
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
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
