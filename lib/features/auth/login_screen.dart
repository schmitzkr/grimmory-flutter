import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/errors.dart';
import '../../core/update_provider.dart';
import '../../core/providers.dart';
import '../onboarding/server_url_provider.dart';
import 'auth_provider.dart';
import 'oidc_config.dart';
import 'oidc_login_controller.dart';
import 'public_settings_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    await ref
        .read(authProvider.notifier)
        .login(_usernameController.text.trim(), _passwordController.text);
  }

  Future<void> _signInWithSso() async {
    // The server publishes its own OIDC issuer and client id; prefer those
    // over anything typed in by hand (the admin may have changed IdP), and
    // save them so the manual screen shows what is in use.
    final fromServer = ref.read(publicSettingsProvider).value?.oidcConfig;
    if (fromServer != null) {
      final prefs = ref.read(sharedPrefsProvider);
      final stored = OidcConfig.load(prefs);
      if (stored == null ||
          stored.issuer != fromServer.issuer ||
          stored.clientId != fromServer.clientId) {
        await fromServer.save(prefs);
        ref.invalidate(oidcConfigProvider);
      }
    }
    if (ref.read(oidcConfigProvider) == null) {
      if (!mounted) return;
      await context.push('/sso-settings');
      return;
    }
    await ref.read(oidcLoginControllerProvider.notifier).login();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final oidcState = ref.watch(oidcLoginControllerProvider);
    final publicSettings = ref.watch(publicSettingsProvider).value;
    final serverSso = publicSettings?.oidcConfig;
    final oidcConfigured =
        ref.watch(oidcConfigProvider) != null || serverSso != null;
    // The server can insist on SSO; the password form is then disabled
    // rather than hidden, so it is still clear what the screen is.
    final forceSso = publicSettings?.oidcForceOnlyMode ?? false;
    final ssoLabel = serverSso != null
        ? publicSettings!.ssoButtonLabel
        : (oidcConfigured ? 'Sign in with SSO' : 'Set up SSO');
    final isLoading = authState.isLoading || oidcState.isLoading;
    final serverUrl = ref.watch(serverUrlProvider);
    final serverHost = serverUrl == null
        ? null
        : (Uri.tryParse(serverUrl)?.host ?? serverUrl);

    ref.listen(authProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyApiError(error))));
      }
    });

    ref.listen(oidcLoginControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SSO sign-in failed: ${friendlyApiError(error)}'),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Column(
        children: [
          const UpdateBanner(),
          // Which server this signs in to, with a way back to onboarding —
          // a mistyped URL used to be a dead end: the only "change server"
          // sat in Settings, behind the login that was failing.
          if (serverHost != null)
            ListTile(
              leading: const Icon(Icons.dns_outlined),
              title: Text(serverHost, overflow: TextOverflow.ellipsis),
              subtitle: const Text('Server'),
              trailing: TextButton(
                onPressed: isLoading
                    ? null
                    : () => ref.read(serverUrlProvider.notifier).clear(),
                child: const Text('Change'),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _usernameController,
                      autocorrect: false,
                      autofocus: true,
                      autofillHints: const [AutofillHints.username],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 16),
                    if (forceSso)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'This server only allows single sign-on.',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    FilledButton(
                      onPressed: isLoading || forceSso ? null : _login,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign in'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading ? null : _signInWithSso,
                            child: oidcState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(ssoLabel),
                          ),
                        ),
                        if (oidcConfigured)
                          IconButton(
                            tooltip: 'SSO settings',
                            icon: const Icon(Icons.settings),
                            onPressed: () => context.push('/sso-settings'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
