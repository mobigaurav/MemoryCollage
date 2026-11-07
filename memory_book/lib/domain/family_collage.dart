/// The look of a collage shared with the family. Photos are separate, one per frame.
class SharedCollageLayout {
  const SharedCollageLayout({
    required this.templateId,
    required this.background,
    required this.paper,
    required this.frames,
    this.packId,
  });

  final String templateId;
  final int background;
  final String paper;
  final int frames;
  final String? packId;

  Map<String, Object?> toJson() => {
        'templateId': templateId,
        'background': background,
        'paper': paper,
        'frames': frames,
        if (packId != null && packId!.isNotEmpty) 'packId': packId,
      };

  static SharedCollageLayout? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, Object?>.from(raw);
    final frames = (json['frames'] as num?)?.toInt() ?? 9;
    return SharedCollageLayout(
      templateId: json['templateId'] as String? ?? 'grid_3x3',
      background: (json['background'] as num?)?.toInt() ?? 0xFFF3E6D0,
      paper: json['paper'] as String? ?? 'plain',
      frames: frames.clamp(1, 20),
      packId: json['packId'] as String?,
    );
  }
}

/// Frames nobody has filled yet, in order.
List<int> openCollageSlots({
  required int frameCount,
  required Iterable<int?> taken,
}) {
  final used = <int>{
    for (final slot in taken)
      if (slot != null && slot >= 0 && slot < frameCount) slot,
  };
  return [for (var i = 0; i < frameCount; i++) if (!used.contains(i)) i];
}
