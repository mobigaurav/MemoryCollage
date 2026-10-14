import 'package:flutter/material.dart';

import '../domain/slot_crop.dart';

/// Pinch and drag measured from the fingers, not Flutter's scale recognizer.
/// That recognizer was reporting a scale of 1 while drag still moved.
class PhotoPinch extends StatefulWidget {
  const PhotoPinch({
    super.key,
    required this.crop,
    required this.onChanged,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onEnd,
    this.panAtFit = true,
  });

  final SlotCrop crop;
  final ValueChanged<SlotCrop> onChanged;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEnd;

  /// When false, a one-finger drag is left for the page-turn swipe.
  final bool panAtFit;

  @override
  State<PhotoPinch> createState() => _PhotoPinchState();
}

class _PhotoPinchState extends State<PhotoPinch> {
  final Map<int, Offset> _points = {};
  SlotCrop? _origin;
  double? _startDistance;
  Offset? _startFocal;
  Offset _pan = Offset.zero;

  void _down(PointerDownEvent event) {
    _points[event.pointer] = event.localPosition;
    _origin = widget.crop;
    _pan = Offset.zero;
    _startDistance = null;
    _startFocal = _focal;
  }

  void _move(PointerMoveEvent event) {
    if (!_points.containsKey(event.pointer)) return;
    _points[event.pointer] = event.localPosition;
    final origin = _origin ?? widget.crop;
    final box = context.size;
    if (box == null || box.width < 8 || box.height < 8) return;

    if (_points.length >= 2) {
      final pts = _points.values.toList();
      final distance = (pts[0] - pts[1]).distance;
      _startDistance ??= distance < 12 ? null : distance;
      if (_startDistance == null || _startDistance! < 12) return;
      final ratio = distance / _startDistance!;
      final focal = _focal;
      if (_startFocal != null && focal != null) {
        _pan = focal - _startFocal!;
      }
      widget.onChanged(
        SlotCrop(
          scale: origin.scale * ratio,
          offsetX: origin.offsetX + _pan.dx / box.width,
          offsetY: origin.offsetY + _pan.dy / box.height,
        ).clamp(),
      );
      return;
    }

    if (!widget.panAtFit && origin.scale <= 1.04) return;
    final focal = _focal;
    if (_startFocal != null && focal != null) {
      _pan = focal - _startFocal!;
    }
    widget.onChanged(
      SlotCrop(
        scale: origin.scale,
        offsetX: origin.offsetX + _pan.dx / box.width,
        offsetY: origin.offsetY + _pan.dy / box.height,
      ).clamp(),
    );
  }

  void _up(PointerEvent event) {
    _points.remove(event.pointer);
    if (_points.isEmpty) {
      widget.onEnd?.call();
    }
    if (_points.length < 2) {
      _startDistance = null;
      _origin = widget.crop;
      _startFocal = _focal;
      _pan = Offset.zero;
    }
  }

  Offset? get _focal {
    if (_points.isEmpty) return null;
    var sum = Offset.zero;
    for (final point in _points.values) {
      sum += point;
    }
    return sum / _points.length.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _down,
        onPointerMove: _move,
        onPointerUp: _up,
        onPointerCancel: _up,
        child: widget.child,
      ),
    );
  }
}
