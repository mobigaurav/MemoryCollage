import 'dart:convert';

import '../data/repositories/settings_repository.dart';

class ExportRecord {
  const ExportRecord({required this.label, required this.at});
  final String label;
  final DateTime at;
}

class ExportHistory {
  ExportHistory(this._settings);
  final SettingsRepository _settings;

  Future<List<ExportRecord>> load() async {
    final raw = await _settings.get(SettingsRepository.exportHistoryKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return [
        for (final item in list)
          ExportRecord(
            label: (item as Map)['label'] as String? ?? 'Export',
            at: DateTime.tryParse(item['at'] as String? ?? '') ?? DateTime.now(),
          ),
      ];
    } catch (_) {
      return [];
    }
  }

  Future<void> add(String label) async {
    final current = await load();
    final next = [
      ExportRecord(label: label, at: DateTime.now()),
      ...current,
    ].take(12);
    await _settings.set(
      SettingsRepository.exportHistoryKey,
      jsonEncode([
        for (final row in next)
          {'label': row.label, 'at': row.at.toIso8601String()},
      ]),
    );
  }
}
