import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../domain/slot_crop.dart';
import 'local_photo.dart';

/// Draws the whole photo at cover size times [crop.scale], clipped to the frame.
/// Scale 1 fills the frame. A smaller scale shrinks it until the photo fits.
class FramedPhoto extends StatefulWidget {
  const FramedPhoto({
    super.key,
    required this.path,
    required this.crop,
    this.colorFilter,
  });

  final String path;
  final SlotCrop crop;
  final ColorFilter? colorFilter;

  @override
  State<FramedPhoto> createState() => _FramedPhotoState();
}

class _FramedPhotoState extends State<FramedPhoto> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  double? _aspect;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(covariant FramedPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _stop();
      _aspect = null;
      _listen();
    }
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  void _listen() {
    final stream = FileImage(File(widget.path)).resolve(const ImageConfiguration());
    final listener = ImageStreamListener(
      (info, _) {
        final width = info.image.width.toDouble();
        final height = info.image.height.toDouble();
        if (!mounted || height <= 0) return;
        setState(() => _aspect = width / height);
      },
      onError: (_, _) {},
    );
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  void _stop() {
    final listener = _listener;
    if (listener != null) _stream?.removeListener(listener);
    _stream = null;
    _listener = null;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final frame = Size(constraints.maxWidth, constraints.maxHeight);
          final aspect = _aspect;
          if (aspect == null || aspect <= 0 || frame.width < 2 || frame.height < 2) {
            final fallback = LocalPhoto(path: widget.path, cacheSize: frame);
            final filter = widget.colorFilter;
            if (filter == null) return fallback;
            return ColorFiltered(colorFilter: filter, child: fallback);
          }
          final cover = SlotCrop.coverSize(
            frameWidth: frame.width,
            frameHeight: frame.height,
            imageWidth: aspect,
            imageHeight: 1,
          );
          final width = cover.width * widget.crop.scale;
          final height = cover.height * widget.crop.scale;
          final dpr = MediaQuery.devicePixelRatioOf(context);
          Widget image = Image.file(
            File(widget.path),
            width: width,
            height: height,
            fit: BoxFit.fill,
            cacheWidth: (width * dpr).round().clamp(64, 2048),
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const ColoredBox(color: Color(0x33000000)),
          );
          final filter = widget.colorFilter;
          if (filter != null) {
            image = ColorFiltered(colorFilter: filter, child: image);
          }
          return Stack(
            children: [
              Positioned(
                left: (frame.width - width) / 2 + widget.crop.offsetX * frame.width,
                top: (frame.height - height) / 2 + widget.crop.offsetY * frame.height,
                width: width,
                height: height,
                child: image,
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<double> fitScaleForPhoto({
  required String path,
  required double frameWidth,
  required double frameHeight,
}) async {
  try {
    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final fit = SlotCrop.fitScale(
      frameWidth: frameWidth,
      frameHeight: frameHeight,
      imageWidth: image.width.toDouble(),
      imageHeight: image.height.toDouble(),
    );
    image.dispose();
    codec.dispose();
    return fit;
  } catch (_) {
    return 1;
  }
}
