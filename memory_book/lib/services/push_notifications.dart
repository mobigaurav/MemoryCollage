import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../data/repositories/settings_repository.dart';
import 'local_notify.dart';

/// FCM register/unregister, matching Vedic AI.
///
/// Without Firebase build defines this does nothing. Local reminders still work.
class PushNotifications {
  PushNotifications(this._settings, this._local);

  final SettingsRepository _settings;
  final LocalNotify _local;
  void Function(String route)? onRoute;
  var _wired = false;

  static const _tokenKey = 'pushDeviceToken';

  Future<void> initialize() async {
    if (!AppConfig.firebaseConfigured) return;
    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: AppConfig.firebaseApiKey,
          appId: AppConfig.firebaseAppId,
          messagingSenderId: AppConfig.firebaseMessagingSenderId,
          projectId: AppConfig.firebaseProjectId,
        ),
      );
      await _local.request();
      await FirebaseMessaging.instance.requestPermission();
      _wire();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _settings.set(_tokenKey, token);
        await registerCurrentToken();
      }
      FirebaseMessaging.instance.onTokenRefresh.listen((next) async {
        await _settings.set(_tokenKey, next);
        await registerCurrentToken();
      });
    } catch (_) {
      // Firebase config is present but native setup is not. Leave push off.
    }
  }

  void _wire() {
    if (_wired) return;
    _wired = true;
    FirebaseMessaging.onMessage.listen((message) async {
      final note = message.notification;
      final title = note?.title ?? message.data['title']?.toString();
      final body = note?.body ?? message.data['body']?.toString();
      if (title == null && body == null) return;
      await _local.show(title: title ?? 'Memory Book', body: body ?? '');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _open(message.data);
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _open(message.data);
    }).catchError((_) {});
  }

  void _open(Map<String, dynamic> data) {
    final route = data['route'];
    if (route is String && route.startsWith('/')) {
      onRoute?.call(route);
    }
  }

  Future<void> registerCurrentToken() async {
    final token = await _settings.get(_tokenKey);
    final session = await _settings.get(SettingsRepository.cognitoIdTokenKey);
    if (token == null || token.length < 8) return;
    if (session == null || session.isEmpty) return;
    try {
      await http.post(
        Uri.parse('${AppConfig.aiBaseUrl}/v1/notifications/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $session',
        },
        body: jsonEncode({
          'device_token': token,
          'platform': Platform.operatingSystem,
        }),
      );
    } catch (_) {}
  }

  Future<void> unregister() async {
    final token = await _settings.get(_tokenKey);
    final session = await _settings.get(SettingsRepository.cognitoIdTokenKey);
    if (token == null || token.isEmpty) return;
    try {
      if (session != null && session.isNotEmpty) {
        await http.delete(
          Uri.parse('${AppConfig.aiBaseUrl}/v1/notifications/register'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $session',
          },
          body: jsonEncode({'device_token': token}),
        );
      }
    } catch (_) {
    } finally {
      await _settings.set(_tokenKey, '');
    }
  }
}

