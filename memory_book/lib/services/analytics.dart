import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../core/config.dart';

/// Same shape as Vedic AI: one event list, and silence when the key is empty.
abstract final class AnalyticsEvents {
  static const signupCompleted = 'user.registered';
  static const loginCompleted = 'user.logged_in';
  static const logout = 'user.logged_out';
  static const paywallViewed = 'paywall.viewed';
  static const purchaseCompleted = 'iap.purchase.completed';
  static const aiClipStarted = 'ai.clip.started';
  static const reelScored = 'reel.score.added';
  static const screenViewed = '\$screen';
}

class Analytics {
  String? _distinctId;
  var _ready = false;

  void init() {
    _ready = AppConfig.posthogApiKey.isNotEmpty;
  }

  void identify(String userId, {Map<String, Object?> properties = const {}}) {
    _distinctId = userId;
    track(
      '\$identify',
      {
        '\$set': properties,
      },
    );
  }

  void track(String event, [Map<String, Object?> properties = const {}]) {
    if (!_ready) return;
    final id = _distinctId ?? 'anonymous';
    final body = jsonEncode({
      'api_key': AppConfig.posthogApiKey,
      'event': event,
      'distinct_id': id,
      'properties': {
        ...properties,
        '\$lib': 'memory-book',
      },
    });
    final host = AppConfig.posthogHost.replaceAll(RegExp(r'/+$'), '');
    http
        .post(
          Uri.parse('$host/capture/'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .catchError((_) => http.Response('', 599));
  }

  void screen(String name) {
    track(AnalyticsEvents.screenViewed, {'\$screen_name': name});
  }

  void reset() {
    _distinctId = null;
  }
}

final analytics = Analytics();

class AnalyticsRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    analytics.screen(name);
  }
}
