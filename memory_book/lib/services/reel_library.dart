import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'photo_files.dart';

class ReelRecord {
  const ReelRecord({
    required this.id,
    required this.title,
    required this.fileName,
    required this.createdAt,
    required this.kind,
  });

  final String id;
  final String title;
  final String fileName;
  final DateTime createdAt;
  final String kind;

  String get path {
    final root = PhotoFiles.documentsRoot;
    if (root == null) return fileName;
    return p.join(root, 'reels', fileName);
  }

  ReelRecord copyWith({String? title}) {
    return ReelRecord(
      id: id,
      title: title ?? this.title,
      fileName: fileName,
      createdAt: createdAt,
      kind: kind,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'fileName': fileName,
        'createdAt': createdAt.toIso8601String(),
        'kind': kind,
      };

  static ReelRecord? fromJson(Map<String, Object?> json) {
    final id = json['id'] as String?;
    final fileName = json['fileName'] as String?;
    if (id == null || fileName == null) return null;
    return ReelRecord(
      id: id,
      title: json['title'] as String? ?? 'Reel',
      fileName: fileName,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      kind: json['kind'] as String? ?? 'film',
    );
  }
}

class ReelLibrary {
  final _uuid = const Uuid();

  Future<File> _index() async {
    if (PhotoFiles.documentsRoot == null) await PhotoFiles.warm();
    return File(p.join(PhotoFiles.documentsRoot!, 'reels.json'));
  }

  Future<List<ReelRecord>> load() async {
    final read = await _read();
    final rows = settleReelTitles(read);
    if (!_sameTitles(read, rows)) await _write(rows);
    return rows;
  }

  Future<List<ReelRecord>> _read() async {
    final file = await _index();
    if (!await file.exists()) return [];
    try {
      final list = jsonDecode(await file.readAsString()) as List;
      final rows = <ReelRecord>[];
      for (final item in list) {
        final row = ReelRecord.fromJson(Map<String, Object?>.from(item as Map));
        if (row != null && File(row.path).existsSync()) rows.add(row);
      }
      return rows;
    } catch (_) {
      return [];
    }
  }

  Future<void> keep({
    required File source,
    required String title,
    required String kind,
  }) async {
    if (PhotoFiles.documentsRoot == null) await PhotoFiles.warm();
    final dir = Directory(p.join(PhotoFiles.documentsRoot!, 'reels'));
    if (!await dir.exists()) await dir.create(recursive: true);
    final id = _uuid.v4();
    final name = '$id.mp4';
    await source.copy(p.join(dir.path, name));
    final rows = settleReelTitles(await _read());
    final next = [
      ReelRecord(
        id: id,
        title: nextReelTitle(rows, title),
        fileName: name,
        createdAt: DateTime.now(),
        kind: kind,
      ),
      ...rows,
    ];
    await _write(next);
  }

  Future<void> remove(String id) async {
    final rows = await load();
    ReelRecord? gone;
    for (final row in rows) {
      if (row.id == id) gone = row;
    }
    if (gone != null) {
      final file = File(gone.path);
      if (await file.exists()) await file.delete();
    }
    await _write(rows.where((row) => row.id != id).toList());
  }

  Future<void> _write(List<ReelRecord> rows) async {
    final file = await _index();
    await file.writeAsString(
      jsonEncode([for (final row in rows) row.toJson()]),
    );
  }
}

const _autoTitles = {'AI clip', 'Memory film', 'Reel'};

/// Gives unnamed clips a stable number. "AI clip" becomes "AI clip 1", then 2.
String nextReelTitle(List<ReelRecord> existing, String requested) {
  final base = requested.trim().isEmpty ? 'Reel' : requested.trim();
  final root = _autoRoot(base);
  if (root != null) {
    var highest = 0;
    for (final row in existing) {
      final number = _seriesNumber(row.title, root);
      if (number != null && number > highest) highest = number;
    }
    return '$root ${highest + 1}';
  }
  if (!existing.any((row) => row.title == base)) return base;
  var n = 2;
  while (existing.any((row) => row.title == '$base ($n)')) {
    n++;
  }
  return '$base ($n)';
}

List<ReelRecord> settleReelTitles(List<ReelRecord> rows) {
  final groups = <String, List<ReelRecord>>{};
  for (final row in rows) {
    final root = _autoRoot(row.title);
    if (root == null) continue;
    groups.putIfAbsent(root, () => []).add(row);
  }
  final renamed = <String, String>{};
  for (final entry in groups.entries) {
    final members = [...entry.value]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final bare = members.any((row) => row.title == entry.key);
    final numbers = [
      for (final row in members) _seriesNumber(row.title, entry.key),
    ];
    final parsed = numbers.whereType<int>().toSet();
    final already = !bare &&
        parsed.length == members.length &&
        !parsed.contains(0);
    if (already) continue;
    for (var i = 0; i < members.length; i++) {
      renamed[members[i].id] = '${entry.key} ${i + 1}';
    }
  }
  if (renamed.isEmpty) return rows;
  return [
    for (final row in rows) row.copyWith(title: renamed[row.id] ?? row.title),
  ];
}

bool _sameTitles(List<ReelRecord> left, List<ReelRecord> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i].id != right[i].id || left[i].title != right[i].title) return false;
  }
  return true;
}

String? _autoRoot(String title) {
  final trimmed = title.trim();
  for (final root in _autoTitles) {
    if (trimmed == root || RegExp('^${RegExp.escape(root)} \\d+\$').hasMatch(trimmed)) {
      return root;
    }
  }
  return null;
}

int? _seriesNumber(String title, String root) {
  final trimmed = title.trim();
  if (trimmed == root) return 0;
  final match = RegExp('^${RegExp.escape(root)} (\\d+)\$').firstMatch(trimmed);
  return match == null ? null : int.tryParse(match.group(1)!);
}
