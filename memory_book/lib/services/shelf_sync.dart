import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../core/config.dart';
import '../data/repositories/album_repository.dart';
import '../data/repositories/settings_repository.dart';
import 'credit_ledger.dart';
import 'photo_files.dart';
import 'photo_service.dart';
import 'reel_library.dart';

class ShelfException implements Exception {
  ShelfException(this.message);
  final String message;
}

/// Copies signed-in books and reels to the account, and brings them back
/// onto a phone that no longer has them.
class ShelfSync {
  ShelfSync(this._settings, this._albums, this._photos, this._reels, this._auth);

  final SettingsRepository _settings;
  final AlbumRepository _albums;
  final PhotoService _photos;
  final ReelLibrary _reels;
  final AuthRepository _auth;

  static const _keyMap = 'shelfFileKeys';
  static const weeklyTitle = 'Photos from this week';
  static const weeklyBody = 'Open the shelf and start a book from the last few days.';

  var _merging = false;
  Timer? _pending;

  void noteChanged() {
    if (_merging) return;
    _pending?.cancel();
    _pending = Timer(const Duration(seconds: 2), () {
      unawaited(push());
    });
  }

  Future<void> merge() async {
    if (_merging) return;
    if (!await _signedIn()) return;
    _merging = true;
    try {
      final cloud = await _send('GET', '/v1/library');
      await _pullBooks(cloud['books']);
      await _pullReels(cloud['reels']);
      _merging = false;
      await push();
    } catch (_) {
      _merging = false;
    }
  }

  Future<void> push() async {
    if (_merging || !await _signedIn()) return;
    try {
      final books = <Map<String, Object?>>[];
      for (final album in await _albums.watchAll().first) {
        final detail = await _albums.getDetail(album.id);
        if (detail == null) continue;
        books.add(await _bookJson(detail));
      }
      final reels = <Map<String, Object?>>[];
      for (final reel in await _reels.load()) {
        final key = await _upload(reel.path, 'video/mp4');
        reels.add({
          'id': reel.id,
          'title': reel.title,
          'createdAt': reel.createdAt.toIso8601String(),
          'kind': reel.kind,
          'videoKey': ?key,
        });
      }
      await _send('PUT', '/v1/library', body: {'books': books, 'reels': reels});
    } catch (_) {}
  }

  /// Cloud account first. The phone shelf is cleared only after that succeeds.
  Future<void> erase() async {
    final session = await _auth.current();
    if (session != null && session.provider == 'cognito') {
      final response = await _raw('DELETE', '/v1/me');
      if (response.statusCode >= 400) {
        final message = _message(response.body);
        throw ShelfException(
          message.isEmpty ? 'The account could not be deleted.' : message,
        );
      }
    }
    await _albums.deleteAll();
    for (final reel in await _reels.load()) {
      await _reels.remove(reel.id);
    }
    await _settings.set(_keyMap, '{}');
  }

  Future<Map<String, Object?>> _bookJson(AlbumDetail detail) async {
    final album = detail.album;
    final cover = album.coverPhotoPath;
    final coverKey = cover == null || cover.isEmpty
        ? null
        : await _upload(PhotoFiles.resolve(cover), _type(cover));
    final pages = <Map<String, Object?>>[];
    for (final page in detail.pages) {
      final slots = <Map<String, Object?>>[];
      for (final slot in page.slots) {
        final path = slot.imagePath;
        final key = path == null || path.isEmpty
            ? null
            : await _upload(PhotoFiles.resolve(path), _type(path));
        slots.add({
          'id': slot.id,
          'slotIndex': slot.slotIndex,
          'caption': slot.caption,
          'scale': slot.scale,
          'offsetX': slot.offsetX,
          'offsetY': slot.offsetY,
          'filterId': slot.filterId,
          'showDate': slot.showDate,
          'photoKey': ?key,
        });
      }
      pages.add({
        'id': page.page.id,
        'pageIndex': page.page.pageIndex,
        'layoutId': page.page.layoutId,
        'slots': slots,
      });
    }
    return {
      'id': album.id,
      'title': album.title,
      'themeId': album.themeId,
      'createdAt': album.createdAt.toIso8601String(),
      'updatedAt': album.updatedAt.toIso8601String(),
      if (album.dateStart != null) 'dateStart': album.dateStart!.toIso8601String(),
      if (album.dateEnd != null) 'dateEnd': album.dateEnd!.toIso8601String(),
      'coverKey': ?coverKey,
      'pages': pages,
    };
  }

  Future<void> _pullBooks(Object? raw) async {
    if (raw is! List) return;
    final local = {for (final album in await _albums.watchAll().first) album.id};
    for (final item in raw) {
      if (item is! Map) continue;
      final book = Map<String, Object?>.from(item);
      final id = book['id'] as String? ?? '';
      if (id.isEmpty || local.contains(id)) continue;
      final pages = <Map<String, Object?>>[];
      final rawPages = book['pages'];
      if (rawPages is List) {
        for (final page in rawPages) {
          if (page is! Map) continue;
          final copy = Map<String, Object?>.from(page);
          final slots = <Map<String, Object?>>[];
          final rawSlots = copy['slots'];
          if (rawSlots is List) {
            for (final slot in rawSlots) {
              if (slot is! Map) continue;
              final one = Map<String, Object?>.from(slot);
              final url = one['photoUrl'] as String? ?? '';
              final key = one['photoKey'] as String? ?? '';
              if (url.isNotEmpty && key.isNotEmpty) {
                final path = await _download(url, key, '.jpg');
                if (path != null) one['imagePath'] = path;
              }
              slots.add(one);
            }
          }
          copy['slots'] = slots;
          pages.add(copy);
        }
      }
      String? cover;
      final coverUrl = book['coverUrl'] as String? ?? '';
      final coverKey = book['coverKey'] as String? ?? '';
      if (coverUrl.isNotEmpty && coverKey.isNotEmpty) {
        cover = await _download(coverUrl, coverKey, '.jpg');
      }
      await _albums.restoreBook(
        id: id,
        title: book['title'] as String? ?? 'Book',
        themeId: book['themeId'] as String? ?? 'leather',
        coverPhotoPath: cover,
        createdAt: DateTime.tryParse(book['createdAt'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(book['updatedAt'] as String? ?? '') ?? DateTime.now(),
        dateStart: DateTime.tryParse(book['dateStart'] as String? ?? ''),
        dateEnd: DateTime.tryParse(book['dateEnd'] as String? ?? ''),
        pages: pages,
      );
    }
  }

  Future<void> _pullReels(Object? raw) async {
    if (raw is! List) return;
    if (PhotoFiles.documentsRoot == null) await PhotoFiles.warm();
    final local = {for (final reel in await _reels.load()) reel.id};
    for (final item in raw) {
      if (item is! Map) continue;
      final reel = Map<String, Object?>.from(item);
      final id = reel['id'] as String? ?? '';
      final url = reel['videoUrl'] as String? ?? '';
      if (id.isEmpty || url.isEmpty || local.contains(id)) continue;
      final root = PhotoFiles.documentsRoot;
      if (root == null) return;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode >= 400) continue;
      final name = '$id.mp4';
      final file = File(p.join(root, 'reels', name));
      await file.parent.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);
      await _reels.adopt(
        ReelRecord(
          id: id,
          title: reel['title'] as String? ?? 'Reel',
          fileName: name,
          createdAt: DateTime.tryParse(reel['createdAt'] as String? ?? '') ?? DateTime.now(),
          kind: reel['kind'] as String? ?? 'film',
        ),
      );
    }
  }

  Future<String?> _download(String url, String key, String ext) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode >= 400) return null;
    final relative = await _photos.persistBytes(response.bodyBytes, ext: _ext(key, ext));
    final map = await _keys();
    map[relative] = key;
    await _saveKeys(map);
    return relative;
  }

  Future<String?> _upload(String absolutePath, String contentType) async {
    final stored = _stored(absolutePath);
    final map = await _keys();
    final known = map[stored];
    if (known != null && known.isNotEmpty) return known;
    final file = File(absolutePath);
    if (!await file.exists()) return null;
    final reserved = await _send(
      'POST',
      '/v1/library/uploads',
      body: {
        'files': [
          {'contentType': contentType},
        ],
      },
    );
    final uploads = reserved['uploads'];
    if (uploads is! List || uploads.isEmpty || uploads.first is! Map) return null;
    final upload = Map<String, Object?>.from(uploads.first as Map);
    final key = upload['key'] as String? ?? '';
    final url = upload['url'] as String? ?? '';
    if (key.isEmpty || url.isEmpty) return null;
    final put = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': contentType},
      body: await file.readAsBytes(),
    );
    if (put.statusCode >= 400) return null;
    map[stored] = key;
    await _saveKeys(map);
    return key;
  }

  String _stored(String absolutePath) {
    final root = PhotoFiles.documentsRoot;
    if (root != null && absolutePath.startsWith(root)) {
      final relative = p.relative(absolutePath, from: root);
      if (!relative.startsWith('..')) return relative;
    }
    return absolutePath;
  }

  String _type(String path) {
    final ext = p.extension(path).toLowerCase();
    return switch (ext) {
      '.png' => 'image/png',
      '.heic' => 'image/heic',
      '.mp4' => 'video/mp4',
      _ => 'image/jpeg',
    };
  }

  String _ext(String key, String fallback) {
    final ext = p.extension(key);
    return ext.isEmpty ? fallback : ext;
  }

  Future<bool> _signedIn() async {
    final session = await _auth.current();
    if (session == null || session.provider != 'cognito') return false;
    final token = await _settings.get(SettingsRepository.cognitoIdTokenKey);
    return token != null && token.isNotEmpty && AppConfig.aiBaseUrl.isNotEmpty;
  }

  Future<Map<String, String>> _keys() async {
    final raw = await _settings.get(_keyMap);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return {
        for (final entry in decoded.entries) '${entry.key}': '${entry.value}',
      };
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveKeys(Map<String, String> map) {
    return _settings.set(_keyMap, jsonEncode(map));
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
  }) async {
    final response = await _raw(method, path, body: body);
    if (response.statusCode >= 400) {
      throw ShelfException(_message(response.body));
    }
    if (response.body.isEmpty) return {};
    final decoded = jsonDecode(response.body);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {};
  }

  Future<http.Response> _raw(
    String method,
    String path, {
    Map<String, Object?>? body,
  }) async {
    final token = await _settings.get(SettingsRepository.cognitoIdTokenKey);
    if (token == null || token.isEmpty) {
      throw ShelfException('Sign in to keep this shelf on the account.');
    }
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('${AppConfig.aiBaseUrl}$path');
    final payload = body == null ? null : jsonEncode(body);
    return switch (method) {
      'GET' => http.get(uri, headers: headers),
      'PUT' => http.put(uri, headers: headers, body: payload),
      'POST' => http.post(uri, headers: headers, body: payload),
      'DELETE' => http.delete(uri, headers: headers),
      _ => throw ShelfException('Unknown request.'),
    };
  }

  String _message(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] is String) return decoded['message'] as String;
    } catch (_) {}
    return '';
  }
}
