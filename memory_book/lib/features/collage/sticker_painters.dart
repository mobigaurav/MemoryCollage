import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/tokens.dart';
import '../../domain/collage_craft.dart';

const _sky = Color(0xFF8FB3C9);
const _sage = Color(0xFF7C9A6B);
const _rose = Color(0xFFD9867A);
const _sun = Color(0xFFE2B04A);

/// Paper-and-ink stickers drawn in code, so they stay sharp at any export size.
class StickerPainter extends CustomPainter {
  StickerPainter(this.kind, {this.text});

  final StickerKind kind;
  final String? text;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case StickerKind.film:
        _film(canvas, size);
      case StickerKind.foil:
        _foil(canvas, size);
      case StickerKind.heart:
        _heart(canvas, size, MbTokens.oxblood);
      case StickerKind.tape:
        _tape(canvas, size);
      case StickerKind.corners:
        _corners(canvas, size);
      case StickerKind.date:
        _date(canvas, size);
      case StickerKind.washi:
        _washi(canvas, size);
      case StickerKind.stamp:
        _stamp(canvas, size);
      case StickerKind.ticket:
        _ticket(canvas, size);
      case StickerKind.polaroid:
        _polaroid(canvas, size);
      case StickerKind.pin:
        _pin(canvas, size);
      case StickerKind.clip:
        _clip(canvas, size);
      case StickerKind.tag:
        _tag(canvas, size);
      case StickerKind.postmark:
        _postmark(canvas, size);
      case StickerKind.star:
        _star(canvas, size, 5, 0.42, _sun);
      case StickerKind.sparkle:
        _sparkle(canvas, size);
      case StickerKind.sun:
        _sunDoodle(canvas, size);
      case StickerKind.moon:
        _moon(canvas, size);
      case StickerKind.cloud:
        _cloud(canvas, size);
      case StickerKind.flower:
        _flower(canvas, size);
      case StickerKind.leaf:
        _leaf(canvas, size);
      case StickerKind.balloon:
        _balloon(canvas, size);
      case StickerKind.crown:
        _crown(canvas, size);
      case StickerKind.arrow:
        _arrow(canvas, size);
      case StickerKind.scribble:
        _scribble(canvas, size);
      case StickerKind.bubble:
        _bubble(canvas, size);
      case StickerKind.place:
        _place(canvas, size);
      case StickerKind.confetti:
        _confetti(canvas, size);
      case StickerKind.word:
        _word(canvas, size, text ?? 'Love');
      case StickerKind.emoji:
        _emoji(canvas, size, text ?? '❤️');
    }
  }

  Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _shadow(Canvas canvas, Path path) {
    canvas.drawShadow(path, const Color(0x66000000), 3, false);
  }

  void _text(
    Canvas canvas,
    String value,
    Rect box, {
    required Color color,
    double scale = 0.3,
    String? family,
    FontWeight weight = FontWeight.w700,
  }) {
    var fontSize = box.height * scale;
    late TextPainter tp;
    for (var i = 0; i < 6; i++) {
      tp = TextPainter(
        text: TextSpan(
          text: value,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontFamily: family,
            fontWeight: weight,
            height: 1,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: box.width);
      if (tp.width <= box.width * 0.98 && tp.height <= box.height) break;
      fontSize *= 0.82;
    }
    tp.paint(
      canvas,
      Offset(box.center.dx - tp.width / 2, box.center.dy - tp.height / 2),
    );
  }

  void _film(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4)),
      Paint()..color = MbTokens.film,
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
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
        const Radius.circular(6),
      ),
      _stroke(MbTokens.foil, 5),
    );
  }

  Path _heartPath(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w / 2, h * 0.82)
      ..cubicTo(w * 0.1, h * 0.55, w * 0.05, h * 0.22, w / 2, h * 0.32)
      ..cubicTo(w * 0.95, h * 0.22, w * 0.9, h * 0.55, w / 2, h * 0.82);
  }

  void _heart(Canvas canvas, Size size, Color color) {
    canvas.drawPath(_heartPath(size), Paint()..color = color);
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
    final paint = _stroke(MbTokens.foil, 4);
    const l = 14.0;
    final w = size.width;
    final h = size.height;
    for (final (a, b, c) in [
      (Offset.zero, const Offset(l, 0), const Offset(0, l)),
      (Offset(w, 0), Offset(w - l, 0), Offset(w, l)),
      (Offset(0, h), Offset(l, h), Offset(0, h - l)),
      (Offset(w, h), Offset(w - l, h), Offset(w, h - l)),
    ]) {
      canvas.drawLine(a, b, paint);
      canvas.drawLine(a, c, paint);
    }
  }

  void _date(Canvas canvas, Size size) {
    final box = Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(3)),
      Paint()..color = MbTokens.paper,
    );
    _text(
      canvas,
      DateFormat.yMMMd().format(DateTime.now()),
      box.deflate(4),
      color: MbTokens.ink,
      scale: 0.6,
    );
  }

  void _washi(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(0.22);
    final band = Rect.fromCenter(center: Offset.zero, width: size.width * 1.05, height: size.height * 0.32);
    canvas.clipRect(band);
    canvas.drawRect(band, Paint()..color = const Color(0xCCD9867A));
    final stripe = Paint()..color = const Color(0x88FAF4E8);
    for (var x = -size.width; x < size.width; x += size.width * 0.12) {
      canvas.drawLine(
        Offset(x, band.top),
        Offset(x + band.height, band.bottom),
        stripe..strokeWidth = size.width * 0.035,
      );
    }
    canvas.restore();
  }

  void _stamp(Canvas canvas, Size size) {
    final r = size.width * 0.04;
    final body = Rect.fromLTWH(size.width * 0.12, size.height * 0.06, size.width * 0.76, size.height * 0.88);
    final holes = Path();
    for (var x = body.left; x <= body.right; x += r * 2.4) {
      holes.addOval(Rect.fromCircle(center: Offset(x, body.top), radius: r));
      holes.addOval(Rect.fromCircle(center: Offset(x, body.bottom), radius: r));
    }
    for (var y = body.top; y <= body.bottom; y += r * 2.4) {
      holes.addOval(Rect.fromCircle(center: Offset(body.left, y), radius: r));
      holes.addOval(Rect.fromCircle(center: Offset(body.right, y), radius: r));
    }
    final paper = Path.combine(PathOperation.difference, Path()..addRect(body), holes);
    _shadow(canvas, paper);
    canvas.drawPath(paper, Paint()..color = MbTokens.cream);
    final inner = body.deflate(size.width * 0.08);
    canvas.drawRect(inner, Paint()..color = _sky);
    canvas.save();
    canvas.translate(inner.left, inner.top);
    _heart(canvas, inner.size, MbTokens.cream);
    canvas.restore();
  }

  void _ticket(Canvas canvas, Size size) {
    final body = Rect.fromLTWH(0, size.height * 0.28, size.width, size.height * 0.44);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(body, const Radius.circular(4)));
    final notch = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, body.center.dy), radius: body.height * 0.16))
      ..addOval(Rect.fromCircle(center: Offset(size.width, body.center.dy), radius: body.height * 0.16));
    final shape = Path.combine(PathOperation.difference, path, notch);
    _shadow(canvas, shape);
    canvas.drawPath(shape, Paint()..color = _sun);
    final dash = _stroke(MbTokens.leather, 1.5);
    final x = size.width * 0.72;
    for (var y = body.top + 4; y < body.bottom - 4; y += 7) {
      canvas.drawLine(Offset(x, y), Offset(x, y + 3), dash);
    }
    _text(
      canvas,
      'ADMIT ONE',
      Rect.fromLTRB(body.left + 10, body.top, x - 6, body.bottom),
      color: MbTokens.leather,
      scale: 0.32,
      weight: FontWeight.w900,
    );
  }

  void _polaroid(Canvas canvas, Size size) {
    final body = Rect.fromLTWH(size.width * 0.1, size.height * 0.04, size.width * 0.8, size.height * 0.92);
    final shape = Path()..addRect(body);
    _shadow(canvas, shape);
    canvas.drawRect(body, Paint()..color = Colors.white);
    final window = Rect.fromLTWH(
      body.left + body.width * 0.08,
      body.top + body.width * 0.08,
      body.width * 0.84,
      body.width * 0.84,
    );
    canvas.drawRect(
      window,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_sky, Color(0xFFE6D3B3)],
        ).createShader(window),
    );
  }

  void _pin(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.5, size.height * 0.36);
    canvas.drawLine(
      c,
      Offset(size.width * 0.5, size.height * 0.9),
      _stroke(const Color(0xFF8A8A8A), size.width * 0.04),
    );
    final head = Path()..addOval(Rect.fromCircle(center: c, radius: size.width * 0.22));
    _shadow(canvas, head);
    canvas.drawPath(head, Paint()..color = MbTokens.oxblood);
    canvas.drawCircle(
      c.translate(-size.width * 0.07, -size.width * 0.07),
      size.width * 0.06,
      Paint()..color = const Color(0x66FFFFFF),
    );
  }

  void _clip(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.62, h * 0.3)
      ..lineTo(w * 0.62, h * 0.78)
      ..arcToPoint(Offset(w * 0.38, h * 0.78), radius: Radius.circular(w * 0.12))
      ..lineTo(w * 0.38, h * 0.18)
      ..arcToPoint(Offset(w * 0.7, h * 0.18), radius: Radius.circular(w * 0.16))
      ..lineTo(w * 0.7, h * 0.86)
      ..arcToPoint(Offset(w * 0.3, h * 0.86), radius: Radius.circular(w * 0.2))
      ..lineTo(w * 0.3, h * 0.36);
    canvas.drawPath(path, _stroke(const Color(0xFF9AA3AA), w * 0.05));
  }

  void _tag(Canvas canvas, Size size) {
    final body = Rect.fromLTWH(size.width * 0.04, size.height * 0.32, size.width * 0.92, size.height * 0.36);
    final path = Path()
      ..moveTo(body.left, body.top)
      ..lineTo(body.right - body.height * 0.4, body.top)
      ..lineTo(body.right, body.center.dy)
      ..lineTo(body.right - body.height * 0.4, body.bottom)
      ..lineTo(body.left, body.bottom)
      ..close();
    _shadow(canvas, path);
    canvas.drawPath(path, Paint()..color = MbTokens.cream);
    canvas.drawCircle(
      Offset(body.right - body.height * 0.45, body.center.dy),
      body.height * 0.1,
      Paint()..color = MbTokens.linen,
    );
    canvas.drawLine(
      Offset(body.left + 8, body.center.dy + body.height * 0.18),
      Offset(body.right - body.height * 0.8, body.center.dy + body.height * 0.18),
      _stroke(MbTokens.linen, 1.5),
    );
  }

  void _postmark(Canvas canvas, Size size) {
    final w = size.width;
    final c = Offset(w * 0.34, size.height * 0.5);
    final ink = _stroke(const Color(0xCC6E2C2C), w * 0.025);
    canvas.drawCircle(c, w * 0.28, ink);
    canvas.drawCircle(c, w * 0.2, ink);
    final step = w * 0.12;
    for (var i = 0; i < 4; i++) {
      final y = c.dy - size.height * 0.15 + i * size.height * 0.1;
      var x = w * 0.5;
      final wave = Path()..moveTo(x, y);
      while (x + step <= w * 0.98) {
        wave.quadraticBezierTo(x + step / 4, y - w * 0.03, x + step / 2, y);
        wave.quadraticBezierTo(x + step * 3 / 4, y + w * 0.03, x + step, y);
        x += step;
      }
      canvas.drawPath(wave, ink);
    }
    _text(
      canvas,
      DateFormat('MMM yy').format(DateTime.now()).toUpperCase(),
      Rect.fromCircle(center: c, radius: w * 0.15),
      color: const Color(0xCC6E2C2C),
      scale: 0.42,
      weight: FontWeight.w900,
    );
  }

  Path _starPath(Offset c, double outer, double inner, int points) {
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / points;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  void _star(Canvas canvas, Size size, int points, double ratio, Color color) {
    final c = size.center(Offset.zero);
    final path = _starPath(c, size.width * 0.44, size.width * 0.44 * ratio, points);
    _shadow(canvas, path);
    canvas.drawPath(path, Paint()..color = color);
  }

  void _sparkle(Canvas canvas, Size size) {
    final paint = Paint()..color = MbTokens.foil;
    canvas.drawPath(_starPath(size.center(Offset.zero), size.width * 0.36, size.width * 0.07, 4), paint);
    canvas.drawPath(
      _starPath(Offset(size.width * 0.8, size.height * 0.2), size.width * 0.14, size.width * 0.03, 4),
      paint,
    );
    canvas.drawPath(
      _starPath(Offset(size.width * 0.2, size.height * 0.8), size.width * 0.1, size.width * 0.02, 4),
      paint,
    );
  }

  void _sunDoodle(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final ray = _stroke(_sun, size.width * 0.05);
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * size.width * 0.3,
        c + Offset(math.cos(a), math.sin(a)) * size.width * 0.44,
        ray,
      );
    }
    canvas.drawCircle(c, size.width * 0.22, Paint()..color = _sun);
  }

  void _moon(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final path = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: c, radius: size.width * 0.36)),
      Path()..addOval(Rect.fromCircle(center: c + Offset(size.width * 0.18, -size.width * 0.1), radius: size.width * 0.3)),
    );
    _shadow(canvas, path);
    canvas.drawPath(path, Paint()..color = const Color(0xFFF2D98A));
  }

  void _cloud(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    var path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.1, h * 0.45, w * 0.8, h * 0.26), Radius.circular(h * 0.13)));
    for (final (x, y, r) in [(0.34, 0.47, 0.17), (0.56, 0.4, 0.22), (0.74, 0.52, 0.13)]) {
      path = Path.combine(
        PathOperation.union,
        path,
        Path()..addOval(Rect.fromCircle(center: Offset(w * x, h * y), radius: w * r)),
      );
    }
    _shadow(canvas, path);
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  void _flower(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final petal = Paint()..color = _rose;
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * size.width * 0.2, size.width * 0.16, petal);
    }
    canvas.drawCircle(c, size.width * 0.13, Paint()..color = _sun);
  }

  void _leaf(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.2, h * 0.85)
      ..quadraticBezierTo(w * 0.05, h * 0.25, w * 0.82, h * 0.12)
      ..quadraticBezierTo(w * 0.85, h * 0.75, w * 0.2, h * 0.85)
      ..close();
    canvas.drawPath(path, Paint()..color = _sage);
    canvas.drawLine(Offset(w * 0.2, h * 0.85), Offset(w * 0.7, h * 0.26), _stroke(const Color(0x88FFFFFF), w * 0.025));
  }

  void _balloon(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = Rect.fromCenter(center: Offset(w * 0.5, h * 0.36), width: w * 0.52, height: h * 0.6);
    final string = Path()
      ..moveTo(w * 0.5, body.bottom)
      ..quadraticBezierTo(w * 0.38, h * 0.82, w * 0.52, h * 0.96);
    canvas.drawPath(string, _stroke(MbTokens.inkSoft, 1.5));
    final shape = Path()..addOval(body);
    _shadow(canvas, shape);
    canvas.drawPath(shape, Paint()..color = MbTokens.oxblood);
    canvas.drawOval(
      Rect.fromLTWH(body.left + body.width * 0.2, body.top + body.height * 0.14, body.width * 0.18, body.height * 0.26),
      Paint()..color = const Color(0x55FFFFFF),
    );
  }

  void _crown(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.12, h * 0.72)
      ..lineTo(w * 0.12, h * 0.3)
      ..lineTo(w * 0.32, h * 0.5)
      ..lineTo(w * 0.5, h * 0.22)
      ..lineTo(w * 0.68, h * 0.5)
      ..lineTo(w * 0.88, h * 0.3)
      ..lineTo(w * 0.88, h * 0.72)
      ..close();
    _shadow(canvas, path);
    canvas.drawPath(path, Paint()..color = MbTokens.foil);
    for (final x in [0.12, 0.5, 0.88]) {
      canvas.drawCircle(Offset(w * x, x == 0.5 ? h * 0.2 : h * 0.28), w * 0.05, Paint()..color = MbTokens.oxblood);
    }
  }

  void _arrow(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ink = _stroke(MbTokens.ink, w * 0.035);
    final path = Path()
      ..moveTo(w * 0.1, h * 0.75)
      ..cubicTo(w * 0.3, h * 0.3, w * 0.6, h * 0.85, w * 0.86, h * 0.28);
    canvas.drawPath(path, ink);
    canvas.drawLine(Offset(w * 0.86, h * 0.28), Offset(w * 0.68, h * 0.3), ink);
    canvas.drawLine(Offset(w * 0.86, h * 0.28), Offset(w * 0.84, h * 0.46), ink);
  }

  void _scribble(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final path = Path();
    for (var i = 0; i <= 80; i++) {
      final a = i / 80 * math.pi * 2.15 - 0.4;
      final r = size.width * (0.38 + 0.03 * math.sin(i * 0.5));
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r * 0.78);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, _stroke(MbTokens.oxblood, size.width * 0.03));
  }

  void _bubble(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.06, h * 0.14, w * 0.88, h * 0.56), Radius.circular(h * 0.2));
    final path = Path()
      ..addRRect(body)
      ..moveTo(w * 0.28, h * 0.66)
      ..lineTo(w * 0.2, h * 0.9)
      ..lineTo(w * 0.46, h * 0.68)
      ..close();
    _shadow(canvas, path);
    canvas.drawPath(path, Paint()..color = Colors.white);
    _text(canvas, text ?? 'Wow!', body.outerRect.deflate(w * 0.08), color: MbTokens.ink, scale: 0.42);
  }

  void _place(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.92)
      ..cubicTo(w * 0.18, h * 0.56, w * 0.18, h * 0.08, w * 0.5, h * 0.08)
      ..cubicTo(w * 0.82, h * 0.08, w * 0.82, h * 0.56, w * 0.5, h * 0.92)
      ..close();
    _shadow(canvas, path);
    canvas.drawPath(path, Paint()..color = MbTokens.oxblood);
    canvas.drawCircle(Offset(w * 0.5, h * 0.36), w * 0.1, Paint()..color = MbTokens.cream);
  }

  void _confetti(Canvas canvas, Size size) {
    final random = math.Random(7);
    const colors = [_rose, _sun, _sky, _sage, MbTokens.foil];
    for (var i = 0; i < 22; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final paint = Paint()..color = colors[i % colors.length];
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(random.nextDouble() * math.pi);
      if (i.isEven) {
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: size.width * 0.07, height: size.width * 0.03), paint);
      } else {
        canvas.drawCircle(Offset.zero, size.width * 0.025, paint);
      }
      canvas.restore();
    }
  }

  void _word(Canvas canvas, Size size, String value) {
    final body = Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.4);
    final tail = body.height * 0.3;
    final path = Path()
      ..moveTo(body.left, body.top)
      ..lineTo(body.right, body.top)
      ..lineTo(body.right - tail, body.center.dy)
      ..lineTo(body.right, body.bottom)
      ..lineTo(body.left, body.bottom)
      ..lineTo(body.left + tail, body.center.dy)
      ..close();
    _shadow(canvas, path);
    canvas.drawPath(path, Paint()..color = MbTokens.leather);
    _text(
      canvas,
      value,
      Rect.fromLTRB(body.left + tail + 2, body.top + 3, body.right - tail - 2, body.bottom - 3),
      color: MbTokens.cream,
      scale: 0.62,
      family: MbTokens.serif,
      weight: FontWeight.w400,
    );
  }

  void _emoji(Canvas canvas, Size size, String value) {
    _text(canvas, value, Offset.zero & size, color: MbTokens.ink, scale: 0.8, weight: FontWeight.w400);
  }

  @override
  bool shouldRepaint(covariant StickerPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.text != text;
}
