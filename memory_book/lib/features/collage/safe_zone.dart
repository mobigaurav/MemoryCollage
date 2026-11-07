import 'package:flutter/material.dart';

import '../../domain/collage_sizes.dart';

/// Shades the part a phone covers, or a printer cannot reach. Taps pass through.
class SafeZoneGuide extends StatelessWidget {
  const SafeZoneGuide({super.key, required this.size});

  final CollageSize size;

  @override
  Widget build(BuildContext context) {
    if (!size.hasSafeZone) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        painter: _SafeZonePainter(size),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SafeZonePainter extends CustomPainter {
  _SafeZonePainter(this.size);

  final CollageSize size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final safe = Rect.fromLTRB(
      canvasSize.width * size.safeLeft,
      canvasSize.height * size.safeTop,
      canvasSize.width * (1 - size.safeRight),
      canvasSize.height * (1 - size.safeBottom),
    );
    final shade = Path()
      ..addRect(Offset.zero & canvasSize)
      ..addRRect(RRect.fromRectAndRadius(safe, const Radius.circular(2)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(shade, Paint()..color = const Color(0x33000000));
    canvas.drawRRect(
      RRect.fromRectAndRadius(safe, const Radius.circular(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xE6FAF4E8),
    );
  }

  @override
  bool shouldRepaint(covariant _SafeZonePainter oldDelegate) => oldDelegate.size != size;
}
