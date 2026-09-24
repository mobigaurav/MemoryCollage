import 'package:flutter/material.dart';

/// Paper-and-film palette. No SaaS purple gradients.
abstract final class MbTokens {
  static const ink = Color(0xFF1C1410);
  static const inkSoft = Color(0xFF4A3B32);
  static const paper = Color(0xFFF3E6D0);
  static const paperDeep = Color(0xFFE6D3B3);
  static const cream = Color(0xFFFAF4E8);
  static const leather = Color(0xFF4A2C1A);
  static const leatherDark = Color(0xFF2A1810);
  static const linen = Color(0xFFD8C7A8);
  static const foil = Color(0xFFC4A35A);
  static const oxblood = Color(0xFF6E2C2C);
  static const film = Color(0xFF111111);
  static const filmBorder = Color(0xFF2A2A2A);
  static const caption = Color(0xFF6B5344);
  static const slotDash = Color(0xFFB89A78);
  static const danger = Color(0xFF8B2E2E);

  /// Warm table the shared spread and reel sit on. Not a dark field.
  static const studio = Color(0xFFF6EFE3);
  static const studioDeep = Color(0xFFE4D0B8);

  static const collagePapers = <Color>[
    Color(0xFFF7F1E8),
    Color(0xFFFFFFFF),
    Color(0xFFE7D3C4),
    Color(0xFFD5DDD4),
    Color(0xFFF3E4C8),
    Color(0xFF1C1410),
  ];

  static const radiusSm = 8.0;
  static const radiusMd = 16.0;
  static const radiusLg = 24.0;

  static const spaceSm = 12.0;
  static const spaceMd = 16.0;
  static const spaceLg = 24.0;
  static const spaceXl = 32.0;
  static const tap = 56.0;

  static const serif = 'InstrumentSerif';
  static const sans = 'Outfit';

  static const pageAspect = 0.72; // closed page
  static const spreadAspect = 1.44; // open book
}
