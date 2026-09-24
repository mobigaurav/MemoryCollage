import 'dart:convert';

import '../../domain/collage_craft.dart';
import 'settings_repository.dart';

class DraftRepository {
  DraftRepository(this._settings);
  final SettingsRepository _settings;

  static const collageKey = 'collage.draft';
  static const videoKey = 'video.draft';

  Future<void> saveCollage(CollageDraft draft) {
    return _settings.set(collageKey, jsonEncode(draft.toJson()));
  }

  Future<CollageDraft?> loadCollage() async {
    final raw = await _settings.get(collageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return CollageDraft.fromJson(
        Map<String, Object?>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveVideo(VideoDraft draft) {
    return _settings.set(videoKey, jsonEncode(draft.toJson()));
  }

  Future<VideoDraft?> loadVideo() async {
    final raw = await _settings.get(videoKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return VideoDraft.fromJson(
        Map<String, Object?>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }
}
