import 'package:flutter/material.dart';

import '../../core/haptics.dart';
import '../../core/theme/tokens.dart';

/// Interactive two-page spread. Page turns live on the left/right edges so
/// photo slots and the system back gesture stay tappable.
class PageCurlSpread extends StatefulWidget {
  const PageCurlSpread({
    super.key,
    required this.left,
    required this.right,
    required this.onTurnForward,
    required this.onTurnBack,
    this.enabled = true,
    this.canTurnForward = true,
    this.canTurnBack = true,
  });

  final Widget left;
  final Widget right;
  final VoidCallback onTurnForward;
  final VoidCallback onTurnBack;
  final bool enabled;
  final bool canTurnForward;
  final bool canTurnBack;

  @override
  State<PageCurlSpread> createState() => PageCurlSpreadState();
}

class PageCurlSpreadState extends State<PageCurlSpread>
    with SingleTickerProviderStateMixin {
  final _drag = ValueNotifier<double>(0);
  late final AnimationController _settle;
  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    _settle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _settle.dispose();
    _drag.dispose();
    super.dispose();
  }

  bool get _reduceMotion {
    final mq = MediaQuery.maybeOf(context);
    if (mq == null) return false;
    return mq.disableAnimations || mq.accessibleNavigation;
  }

  double get _progress {
    final t = _settle.isAnimating ? _settle.value : _drag.value;
    return t.clamp(0.0, 1.0);
  }

  Duration _snapDuration({required double remaining, required double velocity}) {
    final ms = (200 + remaining * 200 - velocity.abs() / 36).clamp(150, 420);
    return Duration(milliseconds: ms.round());
  }

  Future<void> animateTurn({required bool forward}) async {
    if (forward && !widget.canTurnForward) return;
    if (!forward && !widget.canTurnBack) return;
    MbHaptics.rustle();
    if (_reduceMotion) {
      if (forward) {
        widget.onTurnForward();
      } else {
        widget.onTurnBack();
      }
      return;
    }
    if (forward) {
      _drag.value = 0.06;
      _settle.duration = const Duration(milliseconds: 320);
      await _settle.animateTo(1, curve: Curves.easeOutCubic);
      widget.onTurnForward();
    } else {
      widget.onTurnBack();
    }
    _drag.value = 0;
    _settle.value = 0;
  }

  void _onDragUpdate(DragUpdateDetails d, double pageW) {
    if (!widget.enabled || _reduceMotion || _pointers >= 2) return;
    _drag.value = (_drag.value - d.delta.dx / pageW).clamp(0.0, 1.0);
  }

  Future<void> _onDragEnd(DragEndDetails d) async {
    if (!widget.enabled) return;
    final v = d.primaryVelocity ?? 0;
    if (_reduceMotion) {
      if (widget.canTurnForward && v < -280) {
        MbHaptics.rustle();
        widget.onTurnForward();
      } else if (widget.canTurnBack && v > 280) {
        MbHaptics.rustle();
        widget.onTurnBack();
      }
      _drag.value = 0;
      return;
    }
    final goForward = widget.canTurnForward && (_drag.value > 0.38 || v < -380);
    final goBack = widget.canTurnBack && (_drag.value < 0.14 && v > 380);
    MbHaptics.rustle();
    if (goForward) {
      _settle.duration = _snapDuration(
        remaining: 1 - _drag.value,
        velocity: v,
      );
      _settle.value = _drag.value;
      await _settle.animateTo(1, curve: Curves.easeOutCubic);
      widget.onTurnForward();
    } else if (goBack) {
      widget.onTurnBack();
    } else {
      _settle.duration = _snapDuration(remaining: _drag.value, velocity: v);
      _settle.value = _drag.value;
      await _settle.animateTo(0, curve: Curves.easeOutQuart);
    }
    _drag.value = 0;
    _settle.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final pageW = w / 2;
        return Listener(
          onPointerDown: (_) {
            _pointers++;
            if (_pointers >= 2) _drag.value = 0;
          },
          onPointerUp: (_) => _pointers = (_pointers - 1).clamp(0, 10),
          onPointerCancel: (_) => _pointers = (_pointers - 1).clamp(0, 10),
          child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: widget.enabled
              ? (d) => _onDragUpdate(d, pageW)
              : null,
          onHorizontalDragEnd: widget.enabled ? _onDragEnd : null,
          child: Stack(
          children: [
            Row(
              children: [
                SizedBox(
                  width: pageW,
                  height: h,
                  child: RepaintBoundary(child: widget.left),
                ),
                SizedBox(
                  width: pageW,
                  height: h,
                  child: RepaintBoundary(child: widget.right),
                ),
              ],
            ),
            if (!_reduceMotion)
              AnimatedBuilder(
                animation: Listenable.merge([_settle, _drag]),
                builder: (context, _) {
                  final t = _progress;
                  if (t <= 0) return const SizedBox.shrink();
                  return Positioned(
                    left: pageW,
                    width: pageW,
                    height: h,
                    child: IgnorePointer(
                      child: Transform(
                        alignment: Alignment.centerLeft,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.00115)
                          ..rotateY(-t * 2.9),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                MbTokens.paper.withValues(alpha: 0.15),
                                Colors.black.withValues(alpha: 0.35 * t),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            Positioned(
              left: pageW - 6,
              top: 0,
              bottom: 0,
              width: 12,
              child: const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x2E000000),
                        Color(0x00000000),
                        Color(0x2E000000),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
        );
      },
    );
  }
}

class PaperPage extends StatelessWidget {
  const PaperPage({
    super.key,
    required this.child,
    this.isLeft = true,
  });

  final Widget child;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MbTokens.paper,
        border: Border(
          left: isLeft
              ? BorderSide.none
              : BorderSide(
                  color: Colors.black.withValues(alpha: 0.06),
                  width: 8,
                ),
          right: isLeft
              ? BorderSide(
                  color: Colors.black.withValues(alpha: 0.06),
                  width: 8,
                )
              : BorderSide.none,
        ),
      ),
      child: CustomPaint(
        painter: const _GrainPainter(),
        child: child,
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x14C4A35A);
    for (var i = 0; i < 40; i++) {
      final y = size.height * (i / 40);
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
