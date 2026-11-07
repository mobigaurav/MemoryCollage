import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/collage_paper.dart';

/// Draws a paper the same way on screen and in the exported file. Marks scale with the canvas.
class PaperPainter extends CustomPainter {
  PaperPainter(this.paper, this.color);

  final CollagePaper paper;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) => paintPaper(canvas, size, paper, color);

  @override
  bool shouldRepaint(covariant PaperPainter old) =>
      old.paper != paper || old.color != color;
}

void paintPaper(Canvas canvas, Size size, CollagePaper paper, Color color) {
  final rect = Offset.zero & size;
  final unit = size.shortestSide / 360;
  final random = math.Random(paper.index * 97 + 13);
  switch (paper) {
    case CollagePaper.plain:
      canvas.drawRect(rect, Paint()..color = color);
    case CollagePaper.linen:
      canvas.drawRect(rect, Paint()..color = const Color(0xFFEDE3D2));
      final thread = Paint()..strokeWidth = 0.6 * unit;
      for (var y = 0.0; y < size.height; y += 2.2 * unit) {
        thread.color = Color.fromARGB(18 + random.nextInt(18), 120, 96, 70);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), thread);
      }
      for (var x = 0.0; x < size.width; x += 2.2 * unit) {
        thread.color = Color.fromARGB(12 + random.nextInt(14), 255, 255, 255);
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), thread);
      }
    case CollagePaper.kraft:
      canvas.drawRect(rect, Paint()..color = const Color(0xFFBF9A6E));
      final fiber = Paint()
        ..strokeWidth = 0.7 * unit
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 900; i++) {
        final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
        final a = random.nextDouble() * math.pi;
        final l = (2 + random.nextDouble() * 6) * unit;
        fiber.color = random.nextBool()
            ? const Color(0x2E5A3A1E)
            : const Color(0x22FFF2DC);
        canvas.drawLine(p, p + Offset(math.cos(a), math.sin(a)) * l, fiber);
      }
    case CollagePaper.cork:
      canvas.drawRect(rect, Paint()..color = const Color(0xFFC39A6B));
      final grain = Paint();
      for (var i = 0; i < 2600; i++) {
        final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
        final r = (0.6 + random.nextDouble() * 1.8) * unit;
        grain.color = switch (random.nextInt(3)) {
          0 => const Color(0x557A5230),
          1 => const Color(0x40E2C29A),
          _ => const Color(0x30402410),
        };
        canvas.drawOval(Rect.fromCenter(center: p, width: r * 2, height: r * 1.4), grain);
      }
    case CollagePaper.watercolor:
      canvas.drawRect(rect, Paint()..color = const Color(0xFFFBF7F0));
      for (var i = 0; i < 7; i++) {
        final c = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
        final r = (70 + random.nextDouble() * 110) * unit;
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..color = color.withValues(alpha: 0.16 + random.nextDouble() * 0.12)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.45),
        );
      }
    case CollagePaper.notebook:
      canvas.drawRect(rect, Paint()..color = const Color(0xFFFDFBF5));
      final line = Paint()
        ..color = const Color(0x557FA7C4)
        ..strokeWidth = 0.8 * unit;
      final step = 18 * unit;
      for (var y = step; y < size.height; y += step) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
      }
      for (var x = step; x < size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), line..color = const Color(0x307FA7C4));
      }
    case CollagePaper.dots:
      canvas.drawRect(rect, Paint()..color = const Color(0xFFFBF6EE));
      final dot = Paint()..color = const Color(0x55A08870);
      final step = 14 * unit;
      for (var y = step / 2; y < size.height; y += step) {
        for (var x = step / 2; x < size.width; x += step) {
          canvas.drawCircle(Offset(x, y), 0.9 * unit, dot);
        }
      }
    case CollagePaper.chalk:
      canvas.drawRect(rect, Paint()..color = const Color(0xFF2E3833));
      for (var i = 0; i < 14; i++) {
        final c = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
        final r = (30 + random.nextDouble() * 80) * unit;
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..color = const Color(0x0FFFFFFF)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5),
        );
      }
  }
}
