import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

import '../../core/theme/tokens.dart';

/// A white sticker with a QR mark. Scanners need the contrast, so the ink stays black.
void paintVoiceMark(Canvas canvas, Size size, String url) {
  final radius = Radius.circular(size.shortestSide * 0.08);
  canvas.drawRRect(
    RRect.fromRectAndRadius(Offset.zero & size, radius),
    Paint()..color = MbTokens.leather,
  );
  final inset = size.shortestSide * 0.045;
  final inner = Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2);
  canvas.drawRRect(
    RRect.fromRectAndRadius(inner, radius),
    Paint()..color = const Color(0xFFFFFBF4),
  );
  if (url.isEmpty) return;
  final code = QrCode.fromData(data: url, errorCorrectLevel: QrErrorCorrectLevel.M);
  final image = QrImage(code);
  const quiet = 2;
  final cells = image.moduleCount + quiet * 2;
  final cell = inner.shortestSide / cells;
  final ox = inner.left + (inner.width - cell * cells) / 2;
  final oy = inner.top + (inner.height - cell * cells) / 2;
  final dark = Paint()..color = const Color(0xFF1C1410);
  for (var row = 0; row < image.moduleCount; row++) {
    for (var col = 0; col < image.moduleCount; col++) {
      if (!image.isDark(row, col)) continue;
      canvas.drawRect(
        Rect.fromLTWH(ox + (col + quiet) * cell, oy + (row + quiet) * cell, cell + 0.5, cell + 0.5),
        dark,
      );
    }
  }
}

class VoiceMark extends CustomPainter {
  VoiceMark(this.url);

  final String url;

  @override
  void paint(Canvas canvas, Size size) => paintVoiceMark(canvas, size, url);

  @override
  bool shouldRepaint(covariant VoiceMark oldDelegate) => oldDelegate.url != url;
}
