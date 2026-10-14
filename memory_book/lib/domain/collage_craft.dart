import 'package:flutter/material.dart';

enum StickerKind {
  film,
  foil,
  heart,
  tape,
  corners,
  date;

  String get label => switch (this) {
        StickerKind.film => 'Film',
        StickerKind.foil => 'Foil',
        StickerKind.heart => 'Heart',
        StickerKind.tape => 'Tape',
        StickerKind.corners => 'Corners',
        StickerKind.date => 'Date',
      };

  static StickerKind fromId(String id) => StickerKind.values.firstWhere(
        (s) => s.name == id,
        orElse: () => StickerKind.foil,
      );
}

class PlacedPhoto {
  PlacedPhoto({
    required this.path,
    this.nx = 0.5,
    this.ny = 0.5,
    this.scale = 1,
    this.ox = 0,
    this.oy = 0,
    this.filter = 'none',
  });

  final String path;
  double nx;
  double ny;
  double scale;
  double ox;
  double oy;
  String filter;

  Map<String, Object?> toJson() => {
        'path': path,
        'nx': nx,
        'ny': ny,
        'scale': scale,
        'ox': ox,
        'oy': oy,
        'filter': filter,
      };

  static PlacedPhoto fromJson(Map<String, Object?> json) => PlacedPhoto(
        path: json['path'] as String? ?? '',
        nx: (json['nx'] as num?)?.toDouble() ?? 0.5,
        ny: (json['ny'] as num?)?.toDouble() ?? 0.5,
        scale: (json['scale'] as num?)?.toDouble() ?? 1,
        ox: (json['ox'] as num?)?.toDouble() ?? 0,
        oy: (json['oy'] as num?)?.toDouble() ?? 0,
        filter: json['filter'] as String? ?? 'none',
      );
}

class PlacedSticker {
  PlacedSticker({
    required this.kind,
    this.nx = 0.5,
    this.ny = 0.5,
    this.scale = 1,
  });

  final StickerKind kind;
  double nx;
  double ny;
  double scale;

  Map<String, Object?> toJson() => {
        'kind': kind.name,
        'nx': nx,
        'ny': ny,
        'scale': scale,
      };

  static PlacedSticker fromJson(Map<String, Object?> json) => PlacedSticker(
        kind: StickerKind.fromId(json['kind'] as String? ?? 'foil'),
        nx: (json['nx'] as num?)?.toDouble() ?? 0.5,
        ny: (json['ny'] as num?)?.toDouble() ?? 0.5,
        scale: (json['scale'] as num?)?.toDouble() ?? 1,
      );
}

class PlacedText {
  PlacedText({
    required this.text,
    this.nx = 0.08,
    this.ny = 0.88,
    this.color = const Color(0xFF1C1410),
  });

  String text;
  double nx;
  double ny;
  Color color;

  Map<String, Object?> toJson() => {
        'text': text,
        'nx': nx,
        'ny': ny,
        'color': color.toARGB32(),
      };

  static PlacedText fromJson(Map<String, Object?> json) => PlacedText(
        text: json['text'] as String? ?? 'Memory',
        nx: (json['nx'] as num?)?.toDouble() ?? 0.08,
        ny: (json['ny'] as num?)?.toDouble() ?? 0.88,
        color: Color(json['color'] as int? ?? 0xFF1C1410),
      );
}

class CollageDraft {
  CollageDraft({
    required this.templateId,
    required this.background,
    required this.photos,
    required this.stickers,
    required this.texts,
    this.format = 'JPEG',
    this.resolution = 'High',
  });

  final String templateId;
  final int background;
  final List<PlacedPhoto> photos;
  final List<PlacedSticker> stickers;
  final List<PlacedText> texts;
  final String format;
  final String resolution;

  Map<String, Object?> toJson() => {
        'templateId': templateId,
        'background': background,
        'photos': photos.map((p) => p.toJson()).toList(),
        'stickers': stickers.map((s) => s.toJson()).toList(),
        'texts': texts.map((t) => t.toJson()).toList(),
        'format': format,
        'resolution': resolution,
      };

  static CollageDraft? fromJson(Map<String, Object?>? json) {
    if (json == null) return null;
    return CollageDraft(
      templateId: json['templateId'] as String? ?? 'grid_2x2',
      background: json['background'] as int? ?? 0xFFF3E6D0,
      photos: [
        for (final item in (json['photos'] as List? ?? const []))
          PlacedPhoto.fromJson(Map<String, Object?>.from(item as Map)),
      ],
      stickers: [
        for (final item in (json['stickers'] as List? ?? const []))
          PlacedSticker.fromJson(Map<String, Object?>.from(item as Map)),
      ],
      texts: [
        for (final item in (json['texts'] as List? ?? const []))
          PlacedText.fromJson(Map<String, Object?>.from(item as Map)),
      ],
      format: json['format'] as String? ?? 'JPEG',
      resolution: json['resolution'] as String? ?? 'High',
    );
  }

  static List<PlacedPhoto> layoutPhotos(List<String> paths) {
    return [
      for (var i = 0; i < paths.length; i++)
        PlacedPhoto(
          path: paths[i],
          nx: 0.28 + (i % 3) * 0.22,
          ny: 0.28 + (i ~/ 3) * 0.24,
          scale: 1,
        ),
    ];
  }
}

class VideoDraft {
  VideoDraft({
    required this.photos,
    required this.aspect,
    required this.filter,
    required this.transition,
    required this.seconds,
    this.musicIndex = 1,
    this.customMusicPath,
  });

  final List<String> photos;
  final String aspect;
  final String filter;
  final String transition;
  final double seconds;
  final int musicIndex;
  final String? customMusicPath;

  Map<String, Object?> toJson() => {
        'photos': photos,
        'aspect': aspect,
        'filter': filter,
        'transition': transition,
        'seconds': seconds,
        'musicIndex': musicIndex,
        'customMusicPath': customMusicPath,
      };

  static VideoDraft? fromJson(Map<String, Object?>? json) {
    if (json == null) return null;
    return VideoDraft(
      photos: [
        for (final p in (json['photos'] as List? ?? const [])) p as String,
      ],
      aspect: json['aspect'] as String? ?? '9:16',
      filter: json['filter'] as String? ?? 'none',
      transition: json['transition'] as String? ?? 'crossfade',
      seconds: (json['seconds'] as num?)?.toDouble() ?? 3,
      musicIndex: json['musicIndex'] as int? ?? 1,
      customMusicPath: json['customMusicPath'] as String?,
    );
  }
}
