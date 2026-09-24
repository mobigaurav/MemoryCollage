import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/nav.dart';
import '../../core/theme/tokens.dart';
import '../../providers.dart';

enum _AuthMode { signIn, signUp, confirm, forgot, reset }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _code = TextEditingController();
  _AuthMode _mode = _AuthMode.signIn;
  bool _busy = false;
  bool _obscure = true;
  bool _accepted = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (!email.contains('@') || !email.contains('.')) {
      _toast('Enter the email you want on this account.');
      return;
    }
    setState(() => _busy = true);
    try {
      final auth = ref.read(authServiceProvider);
      switch (_mode) {
        case _AuthMode.signUp:
          if (!_accepted) {
            throw StateError('Confirm that your books stay on this phone.');
          }
          if (password.length < 8) {
            throw StateError(
              'Use at least 8 characters, with a number and a capital letter.',
            );
          }
          final needsCode = await auth.register(
            email: email,
            password: password,
            displayName: _name.text.trim(),
          );
          if (!mounted) return;
          if (needsCode) {
            setState(() => _mode = _AuthMode.confirm);
            _toast('Enter the code we emailed you.');
          } else {
            _toast('Account saved on this phone. Three credits are waiting.');
            context.pop();
          }
        case _AuthMode.confirm:
          await auth.confirm(email, _code.text.trim());
          await auth.signInWithEmail(email, password);
          if (!mounted) return;
          _toast('Signed in. Three credits are waiting.');
          context.pop();
        case _AuthMode.signIn:
          if (password.length < 8) {
            throw StateError('That password is too short.');
          }
          await auth.signInWithEmail(email, password);
          if (!mounted) return;
          _toast('Signed in.');
          context.pop();
        case _AuthMode.forgot:
          if (!auth.usesCognito) {
            throw StateError('Password reset starts once Cognito is configured.');
          }
          await auth.forgotPassword(email);
          if (!mounted) return;
          setState(() => _mode = _AuthMode.reset);
          _toast('Enter the code and a new password.');
        case _AuthMode.reset:
          await auth.confirmForgotPassword(
            email: email,
            code: _code.text.trim(),
            password: password,
          );
          await auth.signInWithEmail(email, password);
          if (!mounted) return;
          _toast('Password updated.');
          context.pop();
      }
    } catch (e) {
      final message = e is StateError ? e.message : '$e';
      if (message.contains('Confirm the code')) {
        setState(() => _mode = _AuthMode.confirm);
      }
      _toast(message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _apple() async {
    setState(() => _busy = true);
    try {
      await ref.read(authServiceProvider).signInWithApple();
      if (!mounted) return;
      _toast('Signed in with Apple.');
      context.pop();
    } catch (e) {
      _toast('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    setState(() => _busy = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (!mounted) return;
      _toast('Signed in with Google.');
      context.pop();
    } catch (e) {
      _toast('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final cognito = ref.watch(authServiceProvider).usesCognito;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: shelfBackButton(context),
        title: const Text('Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        children: [
          Text('Your books stay here.', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            'Sign in when you spend an AI credit. Photos stay on this phone until you choose to send one.',
            style: theme.textTheme.bodyLarge,
          ),
          if (!cognito) ...[
            const SizedBox(height: 12),
            const Text(
              'No Cognito key yet. This account and its welcome credits stay on this phone so you can test.',
              style: TextStyle(color: MbTokens.caption),
            ),
          ],
          const SizedBox(height: 28),
          if (_mode == _AuthMode.signUp)
            _field(_name, 'Name', textCapitalization: TextCapitalization.words),
          _field(
            _email,
            'Email',
            keyboard: TextInputType.emailAddress,
            enabled: _mode != _AuthMode.confirm,
          ),
          if (_mode == _AuthMode.confirm || _mode == _AuthMode.reset)
            _field(_code, 'Email code', keyboard: TextInputType.number),
          if (_mode != _AuthMode.forgot && _mode != _AuthMode.confirm)
            _field(
              _password,
              _mode == _AuthMode.reset ? 'New password' : 'Password',
              obscure: _obscure,
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
            ),
          if (_mode == _AuthMode.signUp) ...[
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _accepted,
              activeColor: MbTokens.leather,
              onChanged: (v) => setState(() => _accepted = v ?? false),
              title: const Text(
                'I understand my books stay on this device unless I spend a credit.',
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(_busy ? 'One moment' : _primaryLabel),
          ),
          const SizedBox(height: 8),
          ..._links(),
          if (_mode == _AuthMode.signIn) ...[
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.apple),
              title: const Text('Continue with Apple'),
              onTap: _busy ? null : _apple,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.g_mobiledata),
              title: const Text('Continue with Google'),
              onTap: _busy ? null : _google,
            ),
          ],
        ],
      ),
    );
  }

  String get _primaryLabel => switch (_mode) {
        _AuthMode.signIn => 'Sign in',
        _AuthMode.signUp => 'Create account',
        _AuthMode.confirm => 'Confirm and sign in',
        _AuthMode.forgot => 'Email me a code',
        _AuthMode.reset => 'Save password',
      };

  List<Widget> _links() {
    return switch (_mode) {
      _AuthMode.signIn => [
          TextButton(
            onPressed: () => setState(() => _mode = _AuthMode.signUp),
            child: const Text('Create an account'),
          ),
          TextButton(
            onPressed: () => setState(() => _mode = _AuthMode.forgot),
            child: const Text('Forgot password'),
          ),
        ],
      _AuthMode.signUp => [
          TextButton(
            onPressed: () => setState(() => _mode = _AuthMode.signIn),
            child: const Text('I already have an account'),
          ),
        ],
      _AuthMode.confirm => [
          TextButton(
            onPressed: _busy
                ? null
                : () async {
                    try {
                      await ref.read(authServiceProvider).resend(_email.text.trim());
                      _toast('Code sent again.');
                    } catch (e) {
                      _toast(e is StateError ? e.message : '$e');
                    }
                  },
            child: const Text('Resend code'),
          ),
        ],
      _AuthMode.forgot || _AuthMode.reset => [
          TextButton(
            onPressed: () => setState(() => _mode = _AuthMode.signIn),
            child: const Text('Back to sign in'),
          ),
        ],
    };
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    bool enabled = true,
    TextInputType? keyboard,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        enabled: enabled,
        keyboardType: keyboard,
        textCapitalization: textCapitalization,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
