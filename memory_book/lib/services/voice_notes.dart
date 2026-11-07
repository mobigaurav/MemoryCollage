import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../data/repositories/settings_repository.dart';

class VoiceNoteException implements Exception {
  VoiceNoteException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Puts a short recording where a printed QR can reach it. Returns the page address.
class VoiceNoteApi {
  VoiceNoteApi(this._settings);

  final SettingsRepository _settings;

  Future<String> publish(Uint8List bytes) async {
    final token = await _settings.get(SettingsRepository.cognitoIdTokenKey);
    if (token == null || token.isEmpty) {
      throw VoiceNoteException('Sign in to leave a voice note.');
    }
    final http.Response response;
    try {
      response = await http.post(
        Uri.parse('${AppConfig.aiBaseUrl}/v1/notes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'audio/mp4',
        },
        body: bytes,
      );
    } catch (_) {
      throw VoiceNoteException('The voice note could not be sent.');
    }
    Map<String, dynamic> json = {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) json = Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    if (response.statusCode >= 400) {
      final detail = json['message'];
      throw VoiceNoteException(
        detail is String && detail.isNotEmpty
            ? detail
            : 'The voice note could not be sent.',
      );
    }
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw VoiceNoteException('The voice note could not be sent.');
    }
    return '${AppConfig.aiBaseUrl}/v1/notes/$id';
  }
}
