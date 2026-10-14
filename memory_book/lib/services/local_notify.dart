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
}
