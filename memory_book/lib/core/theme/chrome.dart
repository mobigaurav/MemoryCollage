import 'package:flutter/material.dart';

import 'tokens.dart';

/// Chrome that follows Paper or Darkroom. The book page and the collage stay paper.
extension MbChrome on BuildContext {
  bool get mbDark => Theme.of(this).brightness == Brightness.dark;

  /// Card sitting on the shelf, studio, or You tab.
  Color get mbSurface => mbDark ? const Color(0xEE24160F) : MbTokens.glass;

  /// Sheet and dialog. Matches [MbTheme] so theme type stays readable.
  Color get mbSheet => mbDark ? const Color(0xFF1C120C) : MbTokens.cream;

  Color get mbInk => mbDark ? MbTokens.cream : MbTokens.ink;

  Color get mbMuted => mbDark ? const Color(0xFFE4D3B8) : MbTokens.inkSoft;

  Color get mbAccent => mbDark ? MbTokens.foil : MbTokens.leather;

  Color get mbChip => mbDark ? const Color(0xFF3A2418) : MbTokens.paper;
}
