import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../core/config.dart';

class CognitoTokens {
  const CognitoTokens({
    required this.idToken,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  final String idToken;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
}

class CognitoSignUpResult {
  const CognitoSignUpResult({
    required this.userConfirmed,
    required this.userSub,
    this.codeSentTo,
  });

  final bool userConfirmed;
  final String userSub;

  /// Masked address Cognito actually emailed, when it sent a code.
  final String? codeSentTo;
}

/// Same Cognito calls Arogya uses: public app client, USER_PASSWORD_AUTH.
/// Memory Book has its own pool. Empty client id means the account stays on device.
class CognitoAuth {
  bool get configured => AppConfig.cognitoClientId.isNotEmpty;

  Future<CognitoSignUpResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final attrs = [
      {'Name': 'email', 'Value': email},
      if (displayName != null && displayName.isNotEmpty)
        {'Name': 'name', 'Value': displayName},
    ];
    final out = await _call('SignUp', {
      'ClientId': AppConfig.cognitoClientId,
      'Username': email,
      'Password': password,
      'UserAttributes': attrs,
    });
    final delivery = out['CodeDeliveryDetails'];
    final sentTo = delivery is Map ? delivery['Destination'] as String? : null;
    return CognitoSignUpResult(
      userConfirmed: out['UserConfirmed'] == true,
      userSub: out['UserSub'] as String? ?? '',
      codeSentTo: sentTo,
    );
  }

  Future<void> confirmSignUp(String email, String code) {
    return _call('ConfirmSignUp', {
      'ClientId': AppConfig.cognitoClientId,
      'Username': email,
      'ConfirmationCode': code,
    });
  }

  Future<void> resendCode(String email) {
    return _call('ResendConfirmationCode', {
      'ClientId': AppConfig.cognitoClientId,
      'Username': email,
    });
  }

  Future<CognitoTokens> refresh(String refreshToken) async {
    final out = await _call('InitiateAuth', {
      'AuthFlow': 'REFRESH_TOKEN_AUTH',
      'ClientId': AppConfig.cognitoClientId,
      'AuthParameters': {'REFRESH_TOKEN': refreshToken},
    });
    final result = out['AuthenticationResult'];
    if (result is! Map) {
      throw StateError('Sign in again to refresh this account.');
    }
    final id = result['IdToken'] as String?;
    final access = result['AccessToken'] as String?;
    if (id == null || access == null) {
      throw StateError('Sign in again to refresh this account.');
    }
    return CognitoTokens(
      idToken: id,
      accessToken: access,
      refreshToken: result['RefreshToken'] as String? ?? refreshToken,
      expiresIn: (result['ExpiresIn'] as num?)?.toInt() ?? 3600,
    );
  }

  Future<CognitoTokens> signIn(String email, String password) async {
    final out = await _call('InitiateAuth', {
      'AuthFlow': 'USER_PASSWORD_AUTH',
      'ClientId': AppConfig.cognitoClientId,
      'AuthParameters': {
        'USERNAME': email,
        'PASSWORD': password,
      },
    });
    return _tokens(out);
  }

  /// Hosted UI for this pool. The browser returns to the app with a code.
  Uri authorizeUri({
    required String identityProvider,
    required String codeChallenge,
  }) {
    return cognitoAuthorizeUri(
      host: AppConfig.cognitoDomain,
      clientId: AppConfig.cognitoClientId,
      redirectUri: AppConfig.cognitoRedirectUri,
      identityProvider: identityProvider,
      codeChallenge: codeChallenge,
    );
  }

  Future<CognitoTokens> exchangeAuthorizationCode({
    required String code,
    required String codeVerifier,
  }) async {
    final response = await http.post(
      Uri.https(AppConfig.cognitoDomain, '/oauth2/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'client_id': AppConfig.cognitoClientId,
        'code': code,
        'redirect_uri': AppConfig.cognitoRedirectUri,
        'code_verifier': codeVerifier,
      },
    );
    final json = jsonDecode(response.body);
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    if (response.statusCode >= 400) {
      final detail = map['error_description'] ?? map['error'] ?? 'Sign-in failed';
      throw StateError(friendlyCognitoError('$detail'));
    }
    final id = map['id_token'] as String?;
    final access = map['access_token'] as String?;
    final refresh = map['refresh_token'] as String?;
    if (id == null || access == null || refresh == null) {
      throw StateError('Cognito did not finish sign-in.');
    }
    return CognitoTokens(
      idToken: id,
      accessToken: access,
      refreshToken: refresh,
      expiresIn: (map['expires_in'] as num?)?.toInt() ?? 3600,
    );
  }

  Future<void> forgotPassword(String email) {
    return _call('ForgotPassword', {
      'ClientId': AppConfig.cognitoClientId,
      'Username': email,
    });
  }

  Future<void> confirmForgotPassword({
    required String email,
    required String code,
    required String password,
  }) {
    return _call('ConfirmForgotPassword', {
      'ClientId': AppConfig.cognitoClientId,
      'Username': email,
      'ConfirmationCode': code,
      'Password': password,
    });
  }

  CognitoTokens _tokens(Map<String, dynamic> out) {
    final result = out['AuthenticationResult'];
    if (result is! Map) {
      throw StateError('Confirm your email, then sign in.');
    }
    final id = result['IdToken'] as String?;
    final access = result['AccessToken'] as String?;
    final refresh = result['RefreshToken'] as String?;
    if (id == null || access == null || refresh == null) {
      throw StateError('Confirm your email, then sign in.');
    }
    return CognitoTokens(
      idToken: id,
      accessToken: access,
      refreshToken: refresh,
      expiresIn: (result['ExpiresIn'] as num?)?.toInt() ?? 3600,
    );
  }

  Future<Map<String, dynamic>> _call(
    String target,
    Map<String, Object?> body,
  ) async {
    final response = await http.post(
      Uri.parse('https://cognito-idp.${AppConfig.awsRegion}.amazonaws.com/'),
      headers: {
        'Content-Type': 'application/x-amz-json-1.1',
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.$target',
      },
      body: jsonEncode(body),
    );
    final json = jsonDecode(response.body);
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    if (response.statusCode >= 400) {
      throw StateError(friendlyCognitoError(map['message'] as String? ?? map['__type'] as String? ?? 'Sign-in failed'));
    }
    return map;
  }
}

Map<String, dynamic>? jwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    var b64 = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    while (b64.length % 4 != 0) {
      b64 += '=';
    }
    final payload = jsonDecode(utf8.decode(base64Decode(b64)));
    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) return Map<String, dynamic>.from(payload);
    return null;
  } catch (_) {
    return null;
  }
}

String? jwtSubject(String token) {
  final sub = jwtPayload(token)?['sub'];
  return sub is String ? sub : null;
}

/// PKCE verifier for the public Cognito app client.
String cognitoCodeVerifier() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return base64UrlEncode(bytes).replaceAll('=', '');
}

String cognitoCodeChallenge(String verifier) {
  final digest = sha256.convert(utf8.encode(verifier));
  return base64UrlEncode(digest.bytes).replaceAll('=', '');
}

Uri cognitoAuthorizeUri({
  required String host,
  required String clientId,
  required String redirectUri,
  required String identityProvider,
  required String codeChallenge,
}) {
  return Uri.https(host, '/oauth2/authorize', {
    'response_type': 'code',
    'client_id': clientId,
    'redirect_uri': redirectUri,
    'scope': 'openid email profile',
    'identity_provider': identityProvider,
    'code_challenge_method': 'S256',
    'code_challenge': codeChallenge,
  });
}

/// Reads the code Cognito appended to `memorybook://auth`.
String cognitoAuthorizationCode(Uri callback) {
  final error = callback.queryParameters['error'];
  if (error != null && error.isNotEmpty) {
    final detail = callback.queryParameters['error_description'];
    throw StateError(friendlyCognitoOAuthError(error, detail));
  }
  final code = callback.queryParameters['code'];
  if (code == null || code.isEmpty) {
    throw StateError('Cognito did not return a sign-in code.');
  }
  return code;
}

String friendlyCognitoOAuthError(String error, String? detail) {
  final text = '$error ${detail ?? ''}'.toLowerCase();
  if (text.contains('invalid_request') ||
      text.contains('identity_provider') ||
      text.contains('unauthorized')) {
    return 'Cognito does not have that provider yet. Connect Google or Apple on the pool, then try again.';
  }
  if (detail != null && detail.isNotEmpty) return detail;
  return error;
}

bool jwtEmailVerified(String token) {
  final value = jwtPayload(token)?['email_verified'];
  return value == true || value == 'true';
}

String friendlyCognitoError(String raw) {
  final text = raw.toLowerCase();
  if (text.contains('not confirmed') ||
      text.contains('usernotconfirmed') ||
      text.contains('no registered/verified') ||
      text.contains('not verified')) {
    return 'Confirm the code we emailed you, then sign in.';
  }
  if (text.contains('expiredcode') || text.contains('expired')) {
    return 'That code expired. Request a new one.';
  }
  if (text.contains('not authorized') ||
      text.contains('notauthorized') ||
      text.contains('incorrect')) {
    return 'That email or password does not match.';
  }
  if (text.contains('usernameexists') || text.contains('already exists')) {
    return 'An account with that email already exists. Sign in instead.';
  }
  if (text.contains('password')) {
    return 'Use at least 8 characters, with a number and a capital letter.';
  }
  if (text.contains('codemismatch') || text.contains('code mismatch')) {
    return 'That code does not match. Request a new one.';
  }
  return raw;
}
