import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/errors.dart';
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

    ref.listen(authProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyApiError(error))),
        );
      }
    });

    ref.listen(oidcLoginControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SSO sign-in failed: $error')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
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
                            child: CircularProgressIndicator(strokeWidth: 2),
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
    );
  }
}
