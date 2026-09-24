import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/tokens.dart';
import '../../domain/collage_craft.dart';

class StickerPainter extends CustomPainter {
  StickerPainter(this.kind);
  final StickerKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case StickerKind.film:
        _film(canvas, size);
      case StickerKind.foil:
        _foil(canvas, size);
      case StickerKind.heart:
        _heart(canvas, size);
      case StickerKind.tape:
        _tape(canvas, size);
      case StickerKind.corners:
        _corners(canvas, size);
      case StickerKind.date:
        _date(canvas, size);
    }
  }

  void _film(Canvas canvas, Size size) {
    final fill = Paint()..color = MbTokens.film;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4)),
      fill,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.12, size.width * 0.8, size.height * 0.76),
      Paint()..color = const Color(0xFF3A2A20),
    );
    final hole = Paint()..color = MbTokens.paperDeep;
    for (var i = 0; i < 6; i++) {
      final y = size.height * (0.08 + i * 0.15);
      canvas.drawCircle(Offset(size.width * 0.05, y), 3, hole);
      canvas.drawCircle(Offset(size.width * 0.95, y), 3, hole);
    }
  }

  void _foil(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MbTokens.foil
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
        const Radius.circular(6),
      ),
      paint,
    );
  }

  void _heart(Canvas canvas, Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w / 2, h * 0.82);
    path.cubicTo(w * 0.1, h * 0.55, w * 0.05, h * 0.22, w / 2, h * 0.32);
    path.cubicTo(w * 0.95, h * 0.22, w * 0.9, h * 0.55, w / 2, h * 0.82);
    canvas.drawPath(path, Paint()..color = MbTokens.oxblood);
  }

  void _tape(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.18);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: size.width, height: size.height * 0.38),
      Paint()..color = const Color(0xAAE8D9C4),
    );
    canvas.restore();
  }

  void _corners(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MbTokens.foil
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    const l = 14.0;
    canvas.drawLine(Offset.zero, const Offset(l, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, l), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - l, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, l), paint);
    canvas.drawLine(Offset(0, size.height), Offset(l, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - l), paint);
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - l, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - l),
      paint,
    );
  }

  void _date(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(3)),
      Paint()..color = MbTokens.paper,
    );
    final stamp = DateFormat.yMMMd().format(DateTime.now());
    final tp = TextPainter(
      text: TextSpan(
        text: stamp,
        style: TextStyle(
          color: MbTokens.ink,
          fontSize: size.height * 0.28,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: size.width);
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant StickerPainter oldDelegate) =>
      oldDelegate.kind != kind;
}
