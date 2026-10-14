import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../data/repositories/settings_repository.dart';

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.title,
    required this.kind,
    required this.author,
    required this.mine,
    required this.loves,
    required this.loved,
    required this.media,
  });

  final String id;
  final String title;
  final String kind;
  final String author;
  final bool mine;
  final int loves;
  final bool loved;
  final List<String> media;

  CommunityPost copyWith({int? loves, bool? loved}) {
    return CommunityPost(
      id: id,
      title: title,
      kind: kind,
      author: author,
      mine: mine,
      loves: loves ?? this.loves,
      loved: loved ?? this.loved,
      media: media,
    );
  }

  static CommunityPost fromJson(Map<String, dynamic> json) {
    final media = json['media'];
    return CommunityPost(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      kind: json['kind'] as String? ?? 'album',
      author: json['author'] as String? ?? 'Member',
      mine: json['mine'] == true,
      loves: (json['loves'] as num?)?.toInt() ?? 0,
      loved: json['loved'] == true,
      media: media is List ? [for (final item in media) '$item'] : const [],
    );
  }
}

class CommunityUpload {
  const CommunityUpload({
    required this.key,
    required this.url,
    required this.contentType,
  });

  final String key;
  final String url;
  final String contentType;
}

class CommunityApi {
  CommunityApi(this._settings);

  final SettingsRepository _settings;

  Future<List<CommunityPost>> feed() async {
    try {
      return _posts(await _send('GET', '/v1/community'));
    } on CommunityException catch (error) {
      if (error.status != 401) rethrow;
      return _posts(await _send('GET', '/v1/community', ignoreAuth: true));
    }
  }

  List<CommunityPost> _posts(Map<String, dynamic> response) {
    final posts = response['posts'];
    if (posts is! List) return const [];
    return [
      for (final item in posts)
        if (item is Map) CommunityPost.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  Future<List<CommunityUpload>> begin({
    required String title,
    required String kind,
    required int count,
  }) async {
    final response = await _send(
      'POST',
      '/v1/community',
      body: {'title': title, 'kind': kind, 'count': count},
      auth: true,
    );
    final uploads = response['uploads'];
    if (uploads is! List) {
      throw CommunityException('The world did not accept this post.');
    }
    return [
      for (final item in uploads)
        if (item is Map)
          CommunityUpload(
            key: '${item['key']}',
            url: '${item['url']}',
            contentType: '${item['contentType']}',
          ),
    ];
  }

  Future<void> putFile(CommunityUpload upload, Uint8List bytes) async {
    final response = await http.put(
      Uri.parse(upload.url),
      headers: {'Content-Type': upload.contentType},
      body: bytes,
    );
    if (response.statusCode >= 400) {
      throw CommunityException('A page did not upload.');
    }
  }

  Future<void> publish(String id, List<String> keys) async {
    await _send(
      'POST',
      '/v1/community/$id/publish',
      body: {'keys': keys},
      auth: true,
    );
  }

  Future<({bool loved, int loves})> love(String id) async {
    final response = await _send('POST', '/v1/community/$id/love', auth: true);
    return (
      loved: response['loved'] == true,
      loves: (response['loves'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> ignore(String id) async {
    await _send('POST', '/v1/community/$id/ignore', auth: true);
  }

  Future<void> delete(String id) async {
    await _send('DELETE', '/v1/community/$id', auth: true);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
    bool auth = false,
    bool ignoreAuth = false,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await _settings.get(SettingsRepository.cognitoIdTokenKey);
      if (token == null || token.isEmpty) {
        throw CommunityException('Sign in to post, love, or ignore.', status: 401);
      }
      headers['Authorization'] = 'Bearer $token';
    } else if (!ignoreAuth) {
      final token = await _settings.get(SettingsRepository.cognitoIdTokenKey);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    final uri = Uri.parse('${AppConfig.aiBaseUrl}$path');
    final payload = body == null ? null : jsonEncode(body);
    final http.Response response;
    switch (method) {
      case 'POST':
        response = await http.post(uri, headers: headers, body: payload ?? '{}');
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
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
      throw CommunityException('Sign in to post, love, or ignore.', status: 401);
    }
    if (response.statusCode == 404) {
      throw CommunityException(
        'The world is not on this server yet.',
        status: 404,
      );
    }
    if (response.statusCode >= 400) {
      final detail = json['message'] ?? json['detail'] ?? json['error'];
      throw CommunityException(
        detail is String && detail.isNotEmpty
            ? detail
            : 'The world could not be reached.',
        status: response.statusCode,
      );
    }
    return json;
  }
}

class CommunityException implements Exception {
  CommunityException(this.message, {this.status});
  final String message;
  final int? status;

  @override
  String toString() => message;
}
