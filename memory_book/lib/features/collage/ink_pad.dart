import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../domain/collage_craft.dart';

/// A finger-drawn caption. Nothing leaves the phone.
Future<PlacedInk?> drawCaption(BuildContext context, {bool onDark = false}) {
  return showDialog<PlacedInk>(
    context: context,
    barrierColor: const Color(0xCC1C1410),
    builder: (ctx) => _InkPad(onDark: onDark),
  );
}

void paintInk(Canvas canvas, Size size, PlacedInk ink) {
  final paint = Paint()
    ..color = ink.color
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = size.shortestSide * 0.045;
  for (final stroke in ink.strokes) {
    if (stroke.isEmpty) continue;
    final path = Path()..moveTo(stroke.first.x * size.width, stroke.first.y * size.height);
    for (final dot in stroke.skip(1)) {
      path.lineTo(dot.x * size.width, dot.y * size.height);
    }
    canvas.drawPath(path, paint);
  }
}

class _InkPad extends StatefulWidget {
  const _InkPad({required this.onDark});

  final bool onDark;

  @override
  State<_InkPad> createState() => _InkPadState();
}

class _InkPadState extends State<_InkPad> {
  final _strokes = <List<InkDot>>[];
  List<InkDot>? _current;
  late Color _color = widget.onDark ? MbTokens.cream : MbTokens.leather;

  static const _colors = [MbTokens.leather, MbTokens.oxblood, Color(0xFF1C1410), MbTokens.cream];

  void _start(Offset local, Size size) {
    setState(() {
      _current = [_dot(local, size)];
    });
  }

  void _move(Offset local, Size size) {
    final stroke = _current;
    if (stroke == null || stroke.length >= 400) return;
    final dot = _dot(local, size);
    final last = stroke.last;
    if ((dot.x - last.x).abs() < 0.008 && (dot.y - last.y).abs() < 0.008) return;
    setState(() => stroke.add(dot));
  }

  void _end() {
    final stroke = _current;
    _current = null;
    if (stroke == null || stroke.length < 2 || _strokes.length >= 40) return;
    setState(() => _strokes.add(stroke));
  }

  InkDot _dot(Offset local, Size size) => InkDot(
        (local.dx / size.width).clamp(0, 1),
        (local.dy / size.height).clamp(0, 1),
      );

  PlacedInk get _ink => PlacedInk(
        strokes: [
          ..._strokes,
          if (_current != null && _current!.length >= 2) _current!,
        ],
        color: _color,
      );

  @override
  Widget build(BuildContext context) {
    final ink = _ink;
    return Dialog(
      backgroundColor: MbTokens.cream,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Write it',
              style: TextStyle(fontFamily: MbTokens.serif, fontSize: 28, color: MbTokens.ink),
            ),
            const SizedBox(height: 4),
            const Text(
              'A caption in your handwriting. It stays on this phone.',
              style: TextStyle(color: MbTokens.inkSoft),
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1 / PlacedInk.aspect,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  return GestureDetector(
                    onPanStart: (d) => _start(d.localPosition, size),
                    onPanUpdate: (d) => _move(d.localPosition, size),
                    onPanEnd: (_) => _end(),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.onDark ? const Color(0xFF2E3833) : MbTokens.paper,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: MbTokens.linen),
                      ),
                      child: CustomPaint(
                        painter: InkMark(ink),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final color in _colors)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _color = color),
                      child: CircleAvatar(
                        radius: color == _color ? 14 : 12,
                        backgroundColor: color == _color ? MbTokens.leather : color,
                        child: CircleAvatar(radius: 10, backgroundColor: color),
                      ),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  tooltip: 'Undo',
                  onPressed: _strokes.isEmpty ? null : () => setState(_strokes.removeLast),
                  icon: const Icon(Icons.undo),
                ),
                IconButton(
                  tooltip: 'Clear',
                  onPressed: _strokes.isEmpty ? null : () => setState(_strokes.clear),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            FilledButton(
              onPressed: ink.strokes.isEmpty
                  ? null
                  : () => Navigator.pop(context, PlacedInk(strokes: _strokes, color: _color)),
              child: const Text('Put it on the page'),
            ),
          ],
        ),
      ),
    );
  }
}

class InkMark extends CustomPainter {
  InkMark(this.ink);

  final PlacedInk ink;

  @override
  void paint(Canvas canvas, Size size) => paintInk(canvas, size, ink);

  @override
  bool shouldRepaint(covariant InkMark oldDelegate) => oldDelegate.ink != ink;
}
