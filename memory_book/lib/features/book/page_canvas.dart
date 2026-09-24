import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/album_repository.dart';
import '../../domain/book_models.dart';
import '../../domain/media_options.dart';
import '../../domain/slot_crop.dart';
import '../../services/collage_renderer.dart';
import '../../widgets/framed_photo.dart';
import '../../widgets/local_photo.dart';
import '../../widgets/photo_pinch.dart';

class PageCanvas extends StatelessWidget {
  const PageCanvas({
    super.key,
    required this.page,
    required this.onSlotTap,
    this.onSlotLongPress,
    this.onCropCommit,
  });

  final PageDetail page;
  final void Function(PhotoSlot slot) onSlotTap;
  final void Function(PhotoSlot slot)? onSlotLongPress;
  final void Function(PhotoSlot slot, SlotCrop crop)? onCropCommit;

  @override
  Widget build(BuildContext context) {
    final layout = page.layout;
    return LayoutBuilder(
      builder: (context, c) {
        return Stack(
          children: [
            for (var i = 0; i < layout.slots.length; i++)
              _slot(layout.slots[i], c.biggest, i),
          ],
        );
      },
    );
  }

  Widget _slot(Rect norm, Size size, int index) {
    final rect = Rect.fromLTWH(
      norm.left * size.width,
      norm.top * size.height,
      norm.width * size.width,
      norm.height * size.height,
    );
    final slot = page.slots.where((s) => s.slotIndex == index).firstOrNull;
    if (slot?.imagePath == null) {
      return Positioned.fromRect(
        rect: rect,
        child: GestureDetector(
          onTap: slot == null ? null : () => onSlotTap(slot),
          child: const CustomPaint(
            painter: PhotoCornersPainter(),
            child: SizedBox.expand(),
          ),
        ),
      );
    }
    return Positioned.fromRect(
      rect: rect,
      child: _CroppedPhoto(
        slot: slot!,
        onTap: () => onSlotTap(slot),
        onLongPress: () => onSlotLongPress?.call(slot),
        onCropCommit: onCropCommit,
      ),
    );
  }
}

class _CroppedPhoto extends StatefulWidget {
  const _CroppedPhoto({
    required this.slot,
    required this.onTap,
    required this.onLongPress,
    required this.onCropCommit,
  });

  final PhotoSlot slot;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final void Function(PhotoSlot slot, SlotCrop crop)? onCropCommit;

  @override
  State<_CroppedPhoto> createState() => _CroppedPhotoState();
}

class _CroppedPhotoState extends State<_CroppedPhoto> {
  late SlotCrop _crop;
  bool _gesturing = false;

  @override
  void initState() {
    super.initState();
    _crop = _fromSlot();
  }

  @override
  void didUpdateWidget(covariant _CroppedPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_gesturing &&
        (oldWidget.slot.scale != widget.slot.scale ||
            oldWidget.slot.offsetX != widget.slot.offsetX ||
            oldWidget.slot.offsetY != widget.slot.offsetY)) {
      _crop = _fromSlot();
    }
  }

  SlotCrop _fromSlot() {
    return SlotCrop.fromValues(
      scale: widget.slot.scale,
      offsetX: widget.slot.offsetX,
      offsetY: widget.slot.offsetY,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = filterFor(PhotoFilterId.fromId(widget.slot.filterId));
    return PhotoPinch(
      crop: _crop,
      panAtFit: false,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onChanged: (next) {
        _gesturing = true;
        setState(() => _crop = next);
      },
      onEnd: () {
        _gesturing = false;
        widget.onCropCommit?.call(widget.slot, _crop);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          FramedPhoto(
            path: widget.slot.imagePath!,
            crop: _crop,
            colorFilter: filter,
          ),
          if (widget.slot.caption.isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  widget.slot.caption,
                  style: const TextStyle(
                    color: MbTokens.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PhotoCornersPainter extends CustomPainter {
  const PhotoCornersPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MbTokens.slotDash
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const l = 18.0;
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BookCoverView extends StatelessWidget {
  const BookCoverView({
    super.key,
    required this.album,
    this.onOpen,
    this.onLongPress,
    this.tilt = Offset.zero,
  });

  final Album album;
  final VoidCallback? onOpen;
  final VoidCallback? onLongPress;
  final Offset tilt;

  @override
  Widget build(BuildContext context) {
    final theme = BookCoverTheme.fromId(album.themeId);
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return GestureDetector(
      onTap: onOpen,
      onLongPress: onLongPress,
      child: AspectRatio(
        aspectRatio: MbTokens.pageAspect,
        child: Transform(
          alignment: Alignment.center,
          transform: reduce || tilt == Offset.zero
              ? Matrix4.identity()
              : (Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(tilt.dx)
                ..rotateX(-tilt.dy)),
          child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.coverColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 16,
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.22)),
              ),
              if (album.coverPhotoPath != null)
                Positioned(
                  left: 28,
                  right: 16,
                  top: 28,
                  height: 160,
                  child: LocalPhoto(
                    path: album.coverPhotoPath!,
                    cacheSize: const Size(220, 160),
                  ),
                ),
              Positioned(
                left: 24,
                right: 16,
                bottom: 28,
                child: Text(
                  album.title,
                  style: TextStyle(
                    fontFamily: MbTokens.serif,
                    color: theme.foilColor,
                    fontSize: 22,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
