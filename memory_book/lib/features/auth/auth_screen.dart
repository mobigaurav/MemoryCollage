import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/nav.dart';
import '../../core/theme/tokens.dart';
import '../../providers.dart';
import '../../widgets/brand_hero.dart';

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
          final started = await auth.register(
            email: email,
            password: password,
            displayName: _name.text.trim(),
          );
          if (!mounted) return;
          if (started.needsEmailCode) {
            setState(() => _mode = _AuthMode.confirm);
            final where = started.sentTo;
            _toast(
              where == null
                  ? 'We emailed you a code. Enter it to verify this address.'
                  : 'We emailed a code to $where.',
            );
          } else if (auth.usesCognito) {
            await auth.signInWithEmail(email, password);
            if (!mounted) return;
            _toast('Signed in.');
            context.pop();
          } else {
            _toast('Account saved on this phone. Three credits are waiting.');
            context.pop();
          }
        case _AuthMode.confirm:
          if (_code.text.trim().isEmpty) {
            throw StateError('Enter the code from your email.');
          }
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
          if (_code.text.trim().isEmpty) {
            throw StateError('Enter the code from your email.');
          }
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
      final message = e is StateError ? e.message : '$e';
      if (message == 'canceled') return;
      _toast(message);
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
      final message = e is StateError ? e.message : '$e';
      if (message == 'canceled') return;
      _toast(message);
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
    final signing = _mode == _AuthMode.signIn || _mode == _AuthMode.signUp;
    return Scaffold(
      backgroundColor: MbTokens.cream,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          MbHero(
            onBack: () => popToShelf(context),
            eyebrow: 'Memory Book',
            title: _headline,
            subtitle: _intro,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (signing) _ModeSwitch(
                  signIn: _mode == _AuthMode.signIn,
                  onSignIn: () => setState(() => _mode = _AuthMode.signIn),
                  onSignUp: () => setState(() => _mode = _AuthMode.signUp),
                ),
                if (signing) const SizedBox(height: 22),
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
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: MbTokens.inkSoft,
                      ),
                    ),
                  ),
                if (_mode == _AuthMode.signUp)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _accepted,
                    activeColor: MbTokens.leather,
                    onChanged: (v) => setState(() => _accepted = v ?? false),
                    title: const Text(
                      'I understand my books stay on this phone unless I spend a credit.',
                      style: TextStyle(
                        fontFamily: MbTokens.sans,
                        fontSize: 15,
                        color: MbTokens.ink,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  onPressed: _busy ? null : _submit,
                  child: Text(_busy ? 'One moment' : _primaryLabel),
                ),
                ..._links(),
                if (_mode == _AuthMode.signIn) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Or continue with the same account',
                    style: TextStyle(
                      fontFamily: MbTokens.sans,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MbTokens.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (defaultTargetPlatform == TargetPlatform.iOS)
                    _SocialButton(
                      icon: Icons.apple,
                      label: 'Continue with Apple',
                      onPressed: _busy ? null : _apple,
                    ),
                  _SocialButton(
                    icon: Icons.g_mobiledata,
                    label: 'Continue with Google',
                    onPressed: _busy ? null : _google,
                  ),
                  TextButton(
                    onPressed: _busy ? null : () => popToShelf(context),
                    child: const Text('Continue as guest'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _headline => switch (_mode) {
        _AuthMode.signIn => 'Welcome back',
        _AuthMode.signUp => 'Create an account',
        _AuthMode.confirm => 'Check your email',
        _AuthMode.forgot => 'Reset password',
        _AuthMode.reset => 'Choose a new password',
      };

  String get _intro => switch (_mode) {
        _AuthMode.signIn =>
          'Sign in when you spend an AI credit. Photos stay on this phone until you choose to send one.',
        _AuthMode.signUp =>
          'We email a code to this address. Only a verified email can sign in.',
        _AuthMode.confirm =>
          'Enter the code from your email. This address cannot sign in until that code is confirmed.',
        _AuthMode.forgot =>
          'We will email a reset code to the verified address on this account.',
        _AuthMode.reset =>
          'Enter the code from your email and choose a new password.',
      };

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
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _mode = _AuthMode.forgot),
              child: const Text('Forgot password'),
            ),
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
      _AuthMode.forgot => [
          TextButton(
            onPressed: () => setState(() => _mode = _AuthMode.signIn),
            child: const Text('Back to sign in'),
          ),
        ],
      _AuthMode.reset => [
          TextButton(
            onPressed: _busy
                ? null
                : () async {
                    try {
                      await ref.read(authServiceProvider).forgotPassword(_email.text.trim());
                      _toast('Code sent again.');
                    } catch (e) {
                      _toast(e is StateError ? e.message : '$e');
                    }
                  },
            child: const Text('Resend code'),
          ),
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

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({
    required this.signIn,
    required this.onSignIn,
    required this.onSignUp,
  });

  final bool signIn;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: MbTokens.paper,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _tab('Sign in', signIn, onSignIn)),
          Expanded(child: _tab('Create account', !signIn, onSignUp)),
        ],
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return Material(
      color: active ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: MbTokens.sans,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: active ? MbTokens.leather : MbTokens.inkSoft,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: Colors.white,
          foregroundColor: MbTokens.ink,
          side: const BorderSide(color: MbTokens.linen),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: MbTokens.ink),
        label: Text(label),
      ),
    );
  }
}
