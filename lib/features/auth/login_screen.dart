import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/errors.dart';
import '../../core/update_provider.dart';
import '../onboarding/server_url_provider.dart';
import 'auth_provider.dart';
import 'oidc_login_controller.dart';

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
    final configured = ref.read(oidcConfigProvider) != null;
    if (!configured) {
      await context.push('/sso-settings');
      return;
    }
    await ref.read(oidcLoginControllerProvider.notifier).login();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final oidcState = ref.watch(oidcLoginControllerProvider);
    final oidcConfigured = ref.watch(oidcConfigProvider) != null;
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
                    FilledButton(
                      onPressed: isLoading ? null : _login,
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
                                : Text(
                                    oidcConfigured
                                        ? 'Sign in with SSO'
                                        : 'Set up SSO',
                                  ),
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
