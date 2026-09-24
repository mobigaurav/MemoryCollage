import 'dart:convert';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../core/config.dart';
import '../data/repositories/settings_repository.dart';
import 'cognito_auth.dart';
import 'credit_ledger.dart';

class AuthService {
  AuthService(this._repo, this._credits, this._settings, {CognitoAuth? cognito})
      : _cognito = cognito ?? CognitoAuth();

  final AuthRepository _repo;
  final CreditLedger _credits;
  final SettingsRepository _settings;
  final CognitoAuth _cognito;

  bool get usesCognito => _cognito.configured;

  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (!_cognito.configured) {
      await _settings.set(SettingsRepository.localAccountEmailKey, email);
      await _saveLocal(email, displayName);
      return false;
    }
    final result = await _cognito.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    return !result.userConfirmed;
  }

  Future<void> confirm(String email, String code) {
    return _cognito.confirmSignUp(email, code);
  }

  Future<void> resend(String email) => _cognito.resendCode(email);

  Future<void> signInWithEmail(String email, String password) async {
    if (!_cognito.configured) {
      final saved = await _settings.get(SettingsRepository.localAccountEmailKey);
      if (saved == null || saved.toLowerCase() != email.toLowerCase()) {
        throw StateError('Create an account on this phone first.');
      }
      await _saveLocal(email, null);
      return;
    }
    final tokens = await _cognito.signIn(email, password);
    await _storeTokens(tokens);
    await _repo.save(
      AuthAccount(
        provider: 'cognito',
        subject: jwtSubject(tokens.idToken) ?? email,
        email: email,
      ),
    );
    if (await _credits.balance() == 0) {
      await _credits.grant(3, 'welcome_cognito');
    }
  }

  Future<void> forgotPassword(String email) => _cognito.forgotPassword(email);

  Future<void> confirmForgotPassword({
    required String email,
    required String code,
    required String password,
  }) {
    return _cognito.confirmForgotPassword(
      email: email,
      code: code,
      password: password,
    );
  }

  Future<void> _saveLocal(String email, String? displayName) async {
    await _repo.save(
      AuthAccount(
        provider: 'local',
        subject: email,
        email: email,
        displayName: displayName,
      ),
    );
    if (await _credits.balance() == 0) {
      await _credits.grant(3, 'welcome_local');
    }
  }

  Future<AuthAccount> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final account = AuthAccount(
      provider: 'apple',
      subject: credential.userIdentifier ?? 'apple-user',
      email: credential.email,
      displayName: [
        credential.givenName,
        credential.familyName,
      ].whereType<String>().join(' '),
    );
    await _repo.save(account);
    if (await _credits.balance() == 0) {
      await _credits.grant(3, 'welcome_apple');
    }
    return account;
  }

  Future<AuthAccount> signInWithGoogle() async {
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleServerClientId.isEmpty
          ? null
          : AppConfig.googleServerClientId,
    );
    final user = await GoogleSignIn.instance.authenticate();
    final account = AuthAccount(
      provider: 'google',
      subject: user.id,
      email: user.email,
      displayName: user.displayName,
    );
    await _repo.save(account);
    if (await _credits.balance() == 0) {
      await _credits.grant(3, 'welcome_google');
    }
    return account;
  }

  Future<void> refreshSession() async {
    if (!_cognito.configured) return;
    final refresh = await _settings.get(SettingsRepository.cognitoRefreshTokenKey);
    if (refresh == null || refresh.isEmpty) return;
    try {
      await _storeTokens(await _cognito.refresh(refresh));
    } catch (_) {}
  }

  Future<void> _storeTokens(CognitoTokens tokens) async {
    await _settings.set(SettingsRepository.cognitoIdTokenKey, tokens.idToken);
    await _settings.set(
      SettingsRepository.cognitoRefreshTokenKey,
      tokens.refreshToken,
    );
  }

  Future<void> signOut() async {
    await _settings.set(SettingsRepository.cognitoIdTokenKey, '');
    await _settings.set(SettingsRepository.cognitoRefreshTokenKey, '');
    await _repo.signOut();
  }
}

class AiVideoClient {
  AiVideoClient(this._credits, this._auth, this._settings);

  final CreditLedger _credits;
  final AuthRepository _auth;
  final SettingsRepository _settings;

  Future<AiJobResult> generateFromImage({
    required String imagePath,
    String style = 'cinematic',
    int durationSec = 5,
  }) async {
    final session = await _auth.current();
    if (session == null) {
      return const AiJobResult(
        ok: false,
        message: 'Sign in to spend AI credits. v1.5 keeps the wallet on your account.',
      );
    }
    if (AppConfig.aiBaseUrl.isEmpty) {
      final spent = await _credits.spend(1, 'ai_video');
      if (!spent) {
        return const AiJobResult(
          ok: false,
          message: 'Not enough credits. Buy a pack after sign-in.',
        );
      }
      await _credits.grant(1, 'refund_no_server');
      return const AiJobResult(
        ok: false,
        fallbackToOnDevice: true,
        message:
            'Cloud video is not connected yet. Filming this photo on this phone.',
      );
    }
    try {
      final bytes = await File(imagePath).readAsBytes();
      final token = await _settings.get(SettingsRepository.cognitoIdTokenKey);
      final response = await http.post(
        Uri.parse('${AppConfig.aiBaseUrl}/v1/ai/video'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Subject': session.subject,
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'imageBase64': base64Encode(bytes),
          'style': style,
          'durationSec': durationSec,
        }),
      );
      final json = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
      final message = json['message'] as String? ??
          json['detail'] as String? ??
          'Server ${response.statusCode}';
      if (response.statusCode >= 400) {
        return AiJobResult(ok: false, message: message);
      }
      if (json['fallbackToOnDevice'] == true) {
        return AiJobResult(
          ok: false,
          fallbackToOnDevice: true,
          message: message,
        );
      }
      return AiJobResult(
        ok: true,
        videoUrl: json['videoUrl'] as String?,
        message: message,
      );
    } catch (e) {
      return AiJobResult(ok: false, message: e.toString());
    }
  }
}

class AiJobResult {
  const AiJobResult({
    required this.ok,
    this.message,
    this.videoUrl,
    this.fallbackToOnDevice = false,
  });

  final bool ok;
  final String? message;
  final String? videoUrl;
  final bool fallbackToOnDevice;
}
