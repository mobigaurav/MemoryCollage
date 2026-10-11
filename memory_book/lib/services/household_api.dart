import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../data/repositories/settings_repository.dart';

class HouseholdPhoto {
  const HouseholdPhoto({
    required this.id,
    required this.author,
    required this.yours,
    required this.url,
  });

  final String id;
  final String author;
  final bool yours;
  final String url;

  static HouseholdPhoto fromJson(Map<String, dynamic> json) {
    return HouseholdPhoto(
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? 'Member',
      yours: json['yours'] == true,
      url: json['url'] as String? ?? '',
    );
  }
}

class HouseholdBook {
  const HouseholdBook({
    required this.code,
    required this.title,
    required this.owner,
    required this.memberCount,
    required this.photos,
  });

  final String code;
  final String title;
  final bool owner;
  final int memberCount;
  final List<HouseholdPhoto> photos;

  static HouseholdBook fromJson(Map<String, dynamic> json) {
    final members = json['members'];
    final photos = json['photos'];
    return HouseholdBook(
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? 'Family book',
      owner: json['owner'] == true,
      memberCount: members is List ? members.length : 0,
      photos: photos is List
          ? [
              for (final item in photos)
                if (item is Map)
                  HouseholdPhoto.fromJson(Map<String, dynamic>.from(item)),
            ]
          : const [],
    );
  }
}

class HouseholdUpload {
  const HouseholdUpload({required this.key, required this.url});

  final String key;
  final String url;
}

class HouseholdApi {
  HouseholdApi(this._settings);

  final SettingsRepository _settings;

  Future<List<HouseholdBook>> list() async {
    final response = await _send('GET', '/v1/households');
    final books = response['books'];
    if (books is! List) return const [];
    return [
      for (final item in books)
        if (item is Map) HouseholdBook.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  Future<HouseholdBook> create(String title) async {
    return HouseholdBook.fromJson(
      await _send('POST', '/v1/households', body: {'title': title}),
    );
  }

  Future<HouseholdBook> join(String code) async {
    return HouseholdBook.fromJson(
      await _send('POST', '/v1/households/join', body: {'code': code.trim()}),
    );
  }

  Future<HouseholdBook> read(String code) async {
    return HouseholdBook.fromJson(await _send('GET', '/v1/households/$code'));
  }

  Future<List<HouseholdUpload>> reserve(String code, int count) async {
    final response = await _send(
      'POST',
      '/v1/households/$code/photos',
      body: {'count': count},
    );
    final uploads = response['uploads'];
    if (uploads is! List) {
      throw HouseholdException('This book did not accept the photos.');
    }
    return [
      for (final item in uploads)
        if (item is Map)
          HouseholdUpload(key: '${item['key']}', url: '${item['url']}'),
    ];
  }

  Future<void> putJpeg(HouseholdUpload upload, Uint8List bytes) async {
    final response = await http.put(
      Uri.parse(upload.url),
      headers: {'Content-Type': 'image/jpeg'},
      body: bytes,
    );
    if (response.statusCode >= 400) {
      throw HouseholdException('A photo did not upload.');
    }
  }

  Future<HouseholdBook> commit(String code, List<String> keys) async {
    return HouseholdBook.fromJson(
      await _send(
        'POST',
        '/v1/households/$code/photos/commit',
        body: {'keys': keys},
      ),
    );
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
  }) async {
    final token = await _settings.get(SettingsRepository.cognitoIdTokenKey);
    if (token == null || token.isEmpty) {
      throw HouseholdException('Sign in to share a book with family.', status: 401);
    }
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('${AppConfig.aiBaseUrl}$path');
    final payload = body == null ? null : jsonEncode(body);
    final http.Response response;
    switch (method) {
      case 'POST':
        response = await http.post(uri, headers: headers, body: payload ?? '{}');
      default:
        response = await http.get(uri, headers: headers);
    }
    Map<String, dynamic> json = {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) json = Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    if (response.statusCode == 401) {
      throw HouseholdException('Sign in to share a book with family.', status: 401);
    }
    if (response.statusCode == 404 && (json['message'] is! String)) {
      throw HouseholdException(
        'Family books are not on this server yet.',
        status: 404,
      );
    }
    if (response.statusCode >= 400) {
      final detail = json['message'] ?? json['detail'] ?? json['error'];
      throw HouseholdException(
        detail is String && detail.isNotEmpty
            ? detail
            : 'The family book could not be reached.',
        status: response.statusCode,
      );
    }
    return json;
  }
}

class HouseholdException implements Exception {
  HouseholdException(this.message, {this.status});
  final String message;
  final int? status;

  @override
  String toString() => message;
}
