import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../data/repositories/settings_repository.dart';
import 'analytics.dart';
import 'cognito_auth.dart';
import 'credit_ledger.dart';
import 'photo_files.dart';

class AuthService {
  AuthService(this._repo, this._credits, this._settings, {CognitoAuth? cognito})
      : _cognito = cognito ?? CognitoAuth();

  final AuthRepository _repo;
  final CreditLedger _credits;
  final SettingsRepository _settings;
  final CognitoAuth _cognito;

  bool get usesCognito => _cognito.configured;

  /// [needsEmailCode] is true until Cognito has a verified address.
  /// [sentTo] is the masked inbox Cognito used.
  Future<({bool needsEmailCode, String? sentTo})> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (!_cognito.configured) {
      await _settings.set(SettingsRepository.localAccountEmailKey, email);
      await _saveLocal(email, displayName);
      return (needsEmailCode: false, sentTo: null);
    }
    final result = await _cognito.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    analytics.identify(email, properties: {'provider': 'cognito', 'email': email});
    analytics.track(AnalyticsEvents.signupCompleted, {'provider': 'cognito'});
    return (
      needsEmailCode: !result.userConfirmed,
      sentTo: result.codeSentTo,
    );
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
    if (!jwtEmailVerified(tokens.idToken)) {
      throw StateError('Confirm the code we emailed you, then sign in.');
    }
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
    _noteSession(
      AuthAccount(
        provider: 'cognito',
        subject: jwtSubject(tokens.idToken) ?? email,
        email: email,
      ),
      registered: false,
    );
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
    _noteSession(
      AuthAccount(provider: 'local', subject: email, email: email, displayName: displayName),
      registered: true,
    );
  }

  void _noteSession(AuthAccount account, {required bool registered}) {
    analytics.identify(account.subject, properties: {
      'provider': account.provider,
      if (account.email != null) 'email': account.email,
    });
    analytics.track(
      registered ? AnalyticsEvents.signupCompleted : AnalyticsEvents.loginCompleted,
      {'provider': account.provider},
    );
  }

  Future<AuthAccount> signInWithApple() {
    return _signInWithCognitoProvider(
      identityProvider: 'SignInWithApple',
      accountProvider: 'apple',
      welcome: 'welcome_apple',
    );
  }

  Future<AuthAccount> signInWithGoogle() {
    return _signInWithCognitoProvider(
      identityProvider: 'Google',
      accountProvider: 'google',
      welcome: 'welcome_google',
    );
  }

  /// Cognito hosted UI federates the provider and returns this pool's tokens.
  Future<AuthAccount> _signInWithCognitoProvider({
    required String identityProvider,
    required String accountProvider,
    required String welcome,
  }) async {
    if (!_cognito.configured) {
      throw StateError('Cognito is not configured.');
    }
    final verifier = cognitoCodeVerifier();
    final uri = _cognito.authorizeUri(
      identityProvider: identityProvider,
      codeChallenge: cognitoCodeChallenge(verifier),
    );
    final String callback;
    try {
      callback = await FlutterWebAuth2.authenticate(
        url: uri.toString(),
        callbackUrlScheme: 'memorybook',
      );
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') throw StateError('canceled');
      throw StateError(e.message ?? 'Sign-in did not finish.');
    }
    final tokens = await _cognito.exchangeAuthorizationCode(
      code: cognitoAuthorizationCode(Uri.parse(callback)),
      codeVerifier: verifier,
    );
    await _storeTokens(tokens);
    final payload = jwtPayload(tokens.idToken);
    final email = payload?['email'];
    final name = payload?['name'];
    final account = AuthAccount(
      provider: accountProvider,
      subject: jwtSubject(tokens.idToken) ?? '',
      email: email is String && email.isNotEmpty ? email : null,
      displayName: name is String && name.isNotEmpty ? name : null,
    );
    if (account.subject.isEmpty) {
      throw StateError('Cognito did not return an account id.');
    }
    await _repo.save(account);
    if (await _credits.balance() == 0) {
      await _credits.grant(3, welcome);
    }
    _noteSession(account, registered: false);
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
    analytics.track(AnalyticsEvents.logout);
    analytics.reset();
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
    String? prompt,
    String style = 'cinematic',
    int durationSec = 5,
  }) {
    return generate(
      imagePath: imagePath,
      prompt: prompt,
      style: style,
      durationSec: durationSec,
    );
  }

  Future<AiJobResult> generate({
    String? imagePath,
    String? prompt,
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
    final words = prompt?.trim() ?? '';
    final hasPhoto = imagePath != null && imagePath.isNotEmpty;
    if (!hasPhoto && words.isEmpty) {
      return const AiJobResult(
        ok: false,
        message: 'Add a photo, a prompt, or both.',
      );
    }
    if (AppConfig.aiBaseUrl.isEmpty) {
      if (!hasPhoto) {
        return const AiJobResult(
          ok: false,
          message: 'Cloud video is not connected yet.',
        );
      }
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
      final token = await _settings.get(SettingsRepository.cognitoIdTokenKey);
      if (token == null || token.isEmpty) {
        return const AiJobResult(
          ok: false,
          message:
              'Sign in again with email, Apple, or Google. Cognito issues the token for this account.',
        );
      }
      analytics.track(AnalyticsEvents.aiClipStarted, {
        'has_photo': hasPhoto,
      });
      final response = await http.post(
        Uri.parse('${AppConfig.aiBaseUrl}/v1/ai/video'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Subject': session.subject,
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (hasPhoto)
            'imageBase64': base64Encode(
              await File(PhotoFiles.resolve(imagePath)).readAsBytes(),
            ),
          if (words.isNotEmpty) 'prompt': words,
          'style': style,
          'durationSec': durationSec,
        }),
      );
      return await _resultFrom(response);
    } catch (e) {
      return AiJobResult(ok: false, message: e.toString());
    }
  }

  Future<AiJobResult> refreshJob(String jobId) async {
    final session = await _auth.current();
    if (session == null) {
      return const AiJobResult(ok: false, message: 'Sign in to spend AI credits.');
    }
    final token = await _settings.get(SettingsRepository.cognitoIdTokenKey);
    if (token == null || token.isEmpty) {
      return const AiJobResult(
        ok: false,
        message:
            'Sign in again with email, Apple, or Google. Cognito issues the token for this account.',
      );
    }
    final response = await http.get(
      Uri.parse('${AppConfig.aiBaseUrl}/v1/ai/jobs/$jobId'),
      headers: {
        'X-User-Subject': session.subject,
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    return _resultFrom(response);
  }

  Future<AiJobResult> awaitClip(AiJobResult first) async {
    if (!first.ok || first.videoUrl != null || first.jobId == null) return first;
    var latest = first;
    for (var i = 0; i < 45; i++) {
      await Future<void>.delayed(const Duration(seconds: 4));
      latest = await refreshJob(first.jobId!);
      if (latest.videoUrl != null ||
          latest.status == 'failed' ||
          latest.status == 'completed') {
        return latest;
      }
    }
    return latest;
  }

  Future<AiJobResult> _resultFrom(http.Response response) async {
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    final json = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    final balance = json['balance'];
    if (balance is int) await _credits.matchServer(balance);
    final rawMessage = json['message'] ?? json['detail'];
    final message = rawMessage is String ? rawMessage : 'Server ${response.statusCode}';
    final status = json['status'] as String? ?? '';
    final url = json['videoUrl'] as String?;
    final fallback = json['fallbackToOnDevice'] == true;
    if (response.statusCode >= 400 || fallback || status == 'failed' || status == 'unavailable') {
      return AiJobResult(
        ok: false,
        status: status,
        message: message,
        fallbackToOnDevice: fallback,
      );
    }
    return AiJobResult(
      ok: true,
      status: status,
      jobId: json['jobId'] as String?,
      videoUrl: url,
      message: message,
    );
  }
}

class AiJobResult {
  const AiJobResult({
    required this.ok,
    this.message,
    this.videoUrl,
    this.jobId,
    this.status,
    this.fallbackToOnDevice = false,
  });

  final bool ok;
  final String? message;
  final String? videoUrl;
  final String? jobId;
  final String? status;
  final bool fallbackToOnDevice;
}
