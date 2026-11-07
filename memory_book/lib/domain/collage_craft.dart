import 'package:flutter/material.dart';

enum StickerGroup { paper, doodles, words, emoji }

enum StickerKind {
  film('Film', StickerGroup.paper),
  foil('Foil', StickerGroup.paper),
  heart('Heart', StickerGroup.doodles),
  tape('Tape', StickerGroup.paper),
  corners('Corners', StickerGroup.paper),
  date('Date', StickerGroup.paper),
  washi('Washi', StickerGroup.paper),
  stamp('Stamp', StickerGroup.paper),
  ticket('Ticket', StickerGroup.paper),
  polaroid('Polaroid', StickerGroup.paper),
  pin('Pin', StickerGroup.paper),
  clip('Clip', StickerGroup.paper),
  tag('Tag', StickerGroup.paper),
  postmark('Postmark', StickerGroup.paper),
  star('Star', StickerGroup.doodles),
  sparkle('Sparkle', StickerGroup.doodles),
  sun('Sun', StickerGroup.doodles),
  moon('Moon', StickerGroup.doodles),
  cloud('Cloud', StickerGroup.doodles),
  flower('Flower', StickerGroup.doodles),
  leaf('Leaf', StickerGroup.doodles),
  balloon('Balloon', StickerGroup.doodles),
  crown('Crown', StickerGroup.doodles),
  arrow('Arrow', StickerGroup.doodles),
  scribble('Circle it', StickerGroup.doodles),
  bubble('Speech', StickerGroup.doodles),
  place('Place', StickerGroup.doodles),
  confetti('Confetti', StickerGroup.doodles),
  word('Word', StickerGroup.words),
  emoji('Emoji', StickerGroup.emoji);

  const StickerKind(this.label, this.group);

  final String label;
  final StickerGroup group;

  static StickerKind fromId(String id) => StickerKind.values.firstWhere(
        (s) => s.name == id,
        orElse: () => StickerKind.foil,
      );
}

abstract final class StickerSets {
  static const words = [
    'Best day',
    'Love',
    'Hello',
    'Adventure',
    'Home',
    'Family',
    'Summer',
    'Happy birthday',
    'Just married',
    'First day',
    'Together',
    'Thank you',
  ];

  static const emoji = [
    '❤️', '😍', '🥰', '😂', '🥳', '😎', '🤍', '✨',
    '🌸', '🌻', '🌿', '🍂', '🌊', '☀️', '🌙', '⭐️',
    '🎉', '🎂', '🎈', '🎁', '💍', '👶', '🐶', '🐱',
    '✈️', '🗺️', '🏖️', '🏔️', '🚗', '📸', '🎞️', '🎶',
    '☕️', '🍕', '🍦', '🥂', '🏡', '🎓', '⚽️', '🏆',
    '👑', '💐', '🌈', '❄️', '🎄', '🪔', '🕯️', '💫',
  ];
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
    this.slot,
    this.remoteKey,
  });

  final String path;
  int? slot;

  /// The copy already on the family collage, so sharing again does not send it twice.
  String? remoteKey;
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
        if (slot != null) 'slot': slot,
        if (remoteKey != null) 'remoteKey': remoteKey,
      };

  static PlacedPhoto fromJson(Map<String, Object?> json) => PlacedPhoto(
        path: json['path'] as String? ?? '',
        nx: (json['nx'] as num?)?.toDouble() ?? 0.5,
        ny: (json['ny'] as num?)?.toDouble() ?? 0.5,
        scale: (json['scale'] as num?)?.toDouble() ?? 1,
        ox: (json['ox'] as num?)?.toDouble() ?? 0,
        oy: (json['oy'] as num?)?.toDouble() ?? 0,
        filter: json['filter'] as String? ?? 'none',
        slot: (json['slot'] as num?)?.toInt(),
        remoteKey: json['remoteKey'] as String?,
      );

  PlacedPhoto copyWith({String? remoteKey}) => PlacedPhoto(
        path: path,
        nx: nx,
        ny: ny,
        scale: scale,
        ox: ox,
        oy: oy,
        filter: filter,
        slot: slot,
        remoteKey: remoteKey ?? this.remoteKey,
      );
}

class PlacedSticker {
  PlacedSticker({
    required this.kind,
    this.text,
    this.nx = 0.5,
    this.ny = 0.5,
    this.scale = 1,
    this.pack = false,
  });

  final StickerKind kind;

  /// The words on a word sticker, or the emoji itself.
  final String? text;
  double nx;
  double ny;
  double scale;

  /// Placed by a theme pack, so switching packs can take it back off.
  final bool pack;

  Map<String, Object?> toJson() => {
        'kind': kind.name,
        if (text != null) 'text': text,
        'nx': nx,
        'ny': ny,
        'scale': scale,
        if (pack) 'pack': true,
      };

  static PlacedSticker fromJson(Map<String, Object?> json) => PlacedSticker(
        kind: StickerKind.fromId(json['kind'] as String? ?? 'foil'),
        text: json['text'] as String?,
        pack: json['pack'] == true,
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

class InkDot {
  const InkDot(this.x, this.y);

  final double x;
  final double y;

  Map<String, Object?> toJson() => {'x': x, 'y': y};

  static InkDot fromJson(Map<String, Object?> json) => InkDot(
        (json['x'] as num?)?.toDouble() ?? 0,
        (json['y'] as num?)?.toDouble() ?? 0,
      );
}

/// A handwritten caption. Points sit inside the note, from 0 to 1.
class PlacedInk {
  PlacedInk({
    required this.strokes,
    this.nx = 0.5,
    this.ny = 0.84,
    this.scale = 1,
    this.color = const Color(0xFF4A2C1A),
  });

  final List<List<InkDot>> strokes;
  double nx;
  double ny;
  double scale;
  Color color;

  /// Height divided by width. A caption is a wide strip.
  static const aspect = 0.42;

  Map<String, Object?> toJson() => {
        'strokes': [
          for (final stroke in strokes) [for (final dot in stroke) dot.toJson()],
        ],
        'nx': nx,
        'ny': ny,
        'scale': scale,
        'color': color.toARGB32(),
      };

  static PlacedInk fromJson(Map<String, Object?> json) => PlacedInk(
        strokes: [
          for (final stroke in (json['strokes'] as List? ?? const []))
            if (stroke is List)
              [
                for (final dot in stroke)
                  if (dot is Map) InkDot.fromJson(Map<String, Object?>.from(dot)),
              ],
        ],
        nx: (json['nx'] as num?)?.toDouble() ?? 0.5,
        ny: (json['ny'] as num?)?.toDouble() ?? 0.84,
        scale: (json['scale'] as num?)?.toDouble() ?? 1,
        color: Color((json['color'] as num?)?.toInt() ?? 0xFF4A2C1A),
      );
}

/// A QR mark. Scanning the printed page plays the note at [url].
class PlacedVoice {
  PlacedVoice({
    required this.url,
    this.nx = 0.84,
    this.ny = 0.16,
    this.scale = 1,
  });

  final String url;
  double nx;
  double ny;
  double scale;

  Map<String, Object?> toJson() => {
        'url': url,
        'nx': nx,
        'ny': ny,
        'scale': scale,
      };

  static PlacedVoice fromJson(Map<String, Object?> json) => PlacedVoice(
        url: json['url'] as String? ?? '',
        nx: (json['nx'] as num?)?.toDouble() ?? 0.84,
        ny: (json['ny'] as num?)?.toDouble() ?? 0.16,
        scale: (json['scale'] as num?)?.toDouble() ?? 1,
      );
}

class CollageDraft {
  CollageDraft({
    required this.templateId,
    required this.background,
    required this.photos,
    required this.stickers,
    required this.texts,
    this.inks = const [],
    this.voices = const [],
    this.format = 'JPEG',
    this.resolution = 'High',
    this.paper = 'plain',
    this.packId,
    this.householdCode,
  });

  final String templateId;
  final int background;
  final String paper;
  final String? packId;

  /// The family collage this draft is publishing to.
  final String? householdCode;
  final List<PlacedPhoto> photos;
  final List<PlacedSticker> stickers;
  final List<PlacedText> texts;
  final List<PlacedInk> inks;
  final List<PlacedVoice> voices;
  final String format;
  final String resolution;

  Map<String, Object?> toJson() => {
        'templateId': templateId,
        'background': background,
        'photos': photos.map((p) => p.toJson()).toList(),
        'stickers': stickers.map((s) => s.toJson()).toList(),
        'texts': texts.map((t) => t.toJson()).toList(),
        if (inks.isNotEmpty) 'inks': inks.map((ink) => ink.toJson()).toList(),
        if (voices.isNotEmpty) 'voices': voices.map((voice) => voice.toJson()).toList(),
        'format': format,
        'resolution': resolution,
        'paper': paper,
        if (packId != null) 'packId': packId,
        if (householdCode != null) 'householdCode': householdCode,
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
      inks: [
        for (final item in (json['inks'] as List? ?? const []))
          if (item is Map) PlacedInk.fromJson(Map<String, Object?>.from(item)),
      ],
      voices: [
        for (final item in (json['voices'] as List? ?? const []))
          if (item is Map) PlacedVoice.fromJson(Map<String, Object?>.from(item)),
      ],
      format: json['format'] as String? ?? 'JPEG',
      resolution: json['resolution'] as String? ?? 'High',
      paper: json['paper'] as String? ?? 'plain',
      packId: json['packId'] as String?,
      householdCode: json['householdCode'] as String?,
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
