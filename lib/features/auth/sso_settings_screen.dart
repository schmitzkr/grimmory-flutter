import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'oidc_config.dart';
import 'oidc_login_controller.dart';

/// Lets the user point the app at their Grimmory instance's OIDC provider —
/// unlike a fixed-tenant app, there's no single IdP to hardcode, since each
/// self-hosted Grimmory install may be wired to a different one (or none).
class SsoSettingsScreen extends ConsumerStatefulWidget {
  const SsoSettingsScreen({super.key});

  @override
  ConsumerState<SsoSettingsScreen> createState() => _SsoSettingsScreenState();
}

class _SsoSettingsScreenState extends ConsumerState<SsoSettingsScreen> {
  late final TextEditingController _issuerController;
  late final TextEditingController _clientIdController;

  @override
  void initState() {
    super.initState();
    final existing = OidcConfig.load(ref.read(sharedPrefsProvider));
    _issuerController = TextEditingController(text: existing?.issuer ?? '');
    _clientIdController = TextEditingController(text: existing?.clientId ?? '');
  }

  @override
  void dispose() {
    _issuerController.dispose();
    _clientIdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final issuer = _issuerController.text.trim();
    final clientId = _clientIdController.text.trim();
    if (issuer.isEmpty || clientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both fields are required.')),
      );
      return;
    }

    final prefs = ref.read(sharedPrefsProvider);
    await OidcConfig(issuer: issuer, clientId: clientId).save(prefs);
    // oidcConfigProvider reads prefs fresh each time it runs, but Provider
    // doesn't re-run on its own without an explicit invalidate.
    ref.invalidate(oidcConfigProvider);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SSO Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the OIDC provider your Grimmory server is configured '
              'to use for single sign-on.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _issuerController,
              keyboardType: TextInputType.url,
              autocorrect: false,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Issuer URL',
                hintText: 'https://auth.example.com/application/o/grimmory/',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clientIdController,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Client ID',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
