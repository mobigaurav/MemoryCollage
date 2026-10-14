import 'package:flutter/material.dart';

import '../core/theme/tokens.dart';

enum BookCoverTheme {
  leather,
  linen,
  polaroid,
  wedding,
  baby,
  travel;

  String get label => switch (this) {
        BookCoverTheme.leather => 'Leather',
        BookCoverTheme.linen => 'Linen',
        BookCoverTheme.polaroid => 'Polaroid',
        BookCoverTheme.wedding => 'Wedding',
        BookCoverTheme.baby => 'Baby',
        BookCoverTheme.travel => 'Travel',
      };

  Color get coverColor => switch (this) {
        BookCoverTheme.leather => MbTokens.leather,
        BookCoverTheme.linen => MbTokens.linen,
        BookCoverTheme.polaroid => const Color(0xFFF2EDE4),
        BookCoverTheme.wedding => const Color(0xFFF7F1EA),
        BookCoverTheme.baby => const Color(0xFFE8D9C4),
        BookCoverTheme.travel => const Color(0xFF3D4A3A),
      };

  Color get foilColor => switch (this) {
        BookCoverTheme.leather => MbTokens.foil,
        BookCoverTheme.linen => MbTokens.ink,
        BookCoverTheme.polaroid => MbTokens.inkSoft,
        BookCoverTheme.wedding => const Color(0xFFB08D57),
        BookCoverTheme.baby => MbTokens.oxblood,
        BookCoverTheme.travel => MbTokens.paper,
      };

  static BookCoverTheme fromId(String id) => BookCoverTheme.values.firstWhere(
        (theme) => theme.name == id,
        orElse: () => BookCoverTheme.leather,
      );
}

enum PageLayoutId {
  full,
  two,
  three,
  polaroid,
  scrapbook,
  blank;

  String get label => switch (this) {
        PageLayoutId.full => 'Full page',
        PageLayoutId.two => 'Two photos',
        PageLayoutId.three => 'Three photos',
        PageLayoutId.polaroid => 'Polaroid stack',
        PageLayoutId.scrapbook => 'Scrapbook',
        PageLayoutId.blank => 'Blank page',
      };

  int get slotCount => switch (this) {
        PageLayoutId.full => 1,
        PageLayoutId.two => 2,
        PageLayoutId.three => 3,
        PageLayoutId.polaroid => 2,
        PageLayoutId.scrapbook => 3,
        PageLayoutId.blank => 1,
      };

  /// Normalized slot frames inside a single page (0–1).
  List<Rect> get slots {
    switch (this) {
      case PageLayoutId.full:
        return [const Rect.fromLTWH(0.08, 0.1, 0.84, 0.72)];
      case PageLayoutId.two:
        return [
          const Rect.fromLTWH(0.08, 0.08, 0.84, 0.4),
          const Rect.fromLTWH(0.08, 0.52, 0.84, 0.4),
        ];
      case PageLayoutId.three:
        return [
          const Rect.fromLTWH(0.08, 0.07, 0.84, 0.42),
          const Rect.fromLTWH(0.08, 0.52, 0.4, 0.4),
          const Rect.fromLTWH(0.52, 0.52, 0.4, 0.4),
        ];
      case PageLayoutId.polaroid:
        return [
          const Rect.fromLTWH(0.12, 0.08, 0.7, 0.42),
          const Rect.fromLTWH(0.18, 0.46, 0.7, 0.42),
        ];
      case PageLayoutId.scrapbook:
        return [
          const Rect.fromLTWH(0.06, 0.08, 0.55, 0.5),
          const Rect.fromLTWH(0.42, 0.18, 0.5, 0.38),
          const Rect.fromLTWH(0.16, 0.58, 0.68, 0.32),
        ];
      case PageLayoutId.blank:
        return [const Rect.fromLTWH(0.12, 0.16, 0.76, 0.62)];
    }
  }

  static PageLayoutId fromId(String id) => PageLayoutId.values.firstWhere(
        (layout) => layout.name == id,
        orElse: () => PageLayoutId.full,
      );
}

class SlotFrame {
  const SlotFrame(this.rect, {this.rotation = 0});
  final Rect rect;
  final double rotation;
}
