import 'package:flutter/services.dart';

class LocalNotify {
  static const _channel = MethodChannel('memory_book/notify');

  Future<void> request() async {
    try {
      await _channel.invokeMethod<void>('request');
    } catch (_) {}
  }

  Future<void> show({required String title, required String body}) async {
    try {
      await _channel.invokeMethod<void>('show', {
        'title': title,
        'body': body,
      });
    } catch (_) {}
  }

  /// Sunday at 10:00 on this phone, including after the app is closed.
  Future<void> scheduleWeekly({required String title, required String body}) async {
    try {
      await request();
      await _channel.invokeMethod<void>('scheduleWeekly', {
        'title': title,
        'body': body,
      });
    } catch (_) {}
  }

  Future<void> cancelWeekly() async {
    try {
      await _channel.invokeMethod<void>('cancelWeekly');
    } catch (_) {}
  }
}
