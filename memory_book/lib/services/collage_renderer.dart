import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../domain/collage_craft.dart';
import '../domain/collage_templates.dart';
import '../domain/media_options.dart';
import '../domain/slot_crop.dart';
import '../features/collage/sticker_painters.dart';

class CollageTextOverlay {
  const CollageTextOverlay({
    required this.text,
    required this.nx,
    required this.ny,
    required this.color,
  });

  final String text;
  final double nx;
  final double ny;
  final Color color;
}

class CollageRenderRequest {
  const CollageRenderRequest({
    required this.template,
    required this.imagePaths,
    required this.background,
    this.scales = const [],
    this.offsetXs = const [],
    this.offsetYs = const [],
    this.texts = const [],
    this.stickers = const [],
    this.size = const Size(2160, 2160),
    this.freeformOrigins = const [],
    this.placedPhotos = const [],
  });

  final CollageTemplate template;
  final List<String> imagePaths;
  final Color background;
  final List<double> scales;
  final List<double> offsetXs;
  final List<double> offsetYs;
  final List<CollageTextOverlay> texts;
  final List<PlacedSticker> stickers;
  final Size size;
  final List<Offset> freeformOrigins;
  final List<PlacedPhoto> placedPhotos;
}

class CollageRenderer {
  Future<ui.Image> render(CollageRenderRequest request) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = request.size;
    canvas.drawRect(Offset.zero & size, Paint()..color = request.background);

    final images = <ui.Image?>[];
    for (final path in request.imagePaths) {
      images.add(await _load(path));
    }

    if (request.template.kind == CollageKind.freeform) {
      for (var i = 0; i < images.length; i++) {
        final image = images[i];
        if (image == null) continue;
        final placed = i < request.placedPhotos.length
            ? request.placedPhotos[i]
            : null;
        final origin = placed != null
            ? Offset(placed.nx, placed.ny)
            : (i < request.freeformOrigins.length
                ? request.freeformOrigins[i]
                : Offset(0.2 + (i % 3) * 0.2, 0.2 + (i ~/ 3) * 0.2));
        final scale = placed?.scale ??
            (i < request.scales.length ? request.scales[i] : 1.0);
        final side = size.width * 0.28 * scale;
        final dest = Rect.fromCenter(
          center: Offset(origin.dx * size.width, origin.dy * size.height),
          width: side,
          height: side,
        );
        _paintCover(canvas, image, dest, filter: _placedFilter(placed));
      }
    } else {
      final frames = request.template.frames;
      for (var i = 0; i < frames.length && i < images.length; i++) {
        final image = images[i];
        if (image == null) continue;
        final norm = insetFrame(frames[i]);
        final frame = Rect.fromLTWH(
          norm.left * size.width,
          norm.top * size.height,
          norm.width * size.width,
          norm.height * size.height,
        );
        final placed = i < request.placedPhotos.length
            ? request.placedPhotos[i]
            : null;
        final scale = placed?.scale ??
            (i < request.scales.length ? request.scales[i] : 1.0);
        final ox = placed?.ox ??
            (i < request.offsetXs.length ? request.offsetXs[i] : 0.0);
        final oy = placed?.oy ??
            (i < request.offsetYs.length ? request.offsetYs[i] : 0.0);
        canvas.save();
        canvas.clipRect(frame);
        final cover = SlotCrop.coverSize(
          frameWidth: frame.width,
          frameHeight: frame.height,
          imageWidth: image.width.toDouble(),
          imageHeight: image.height.toDouble(),
        );
        final dest = Rect.fromCenter(
          center: frame.center.translate(ox * frame.width, oy * frame.height),
          width: cover.width * scale,
          height: cover.height * scale,
        );
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          dest,
          Paint()
            ..filterQuality = FilterQuality.high
            ..colorFilter = _placedFilter(placed),
        );
        canvas.restore();
      }
    }

    for (final sticker in request.stickers) {
      final side = size.width * 0.22 * sticker.scale;
      final dest = Rect.fromCenter(
        center: Offset(sticker.nx * size.width, sticker.ny * size.height),
        width: side,
        height: side,
      );
      canvas.save();
      canvas.translate(dest.left, dest.top);
      StickerPainter(sticker.kind).paint(canvas, dest.size);
      canvas.restore();
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (final text in request.texts) {
      textPainter.text = TextSpan(
        text: text.text,
        style: TextStyle(
          color: text.color,
          fontSize: size.width * 0.035,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(text.nx * size.width, text.ny * size.height),
      );
    }

    final picture = recorder.endRecording();
    return picture.toImage(size.width.toInt(), size.height.toInt());
  }

  void _paintCover(
    Canvas canvas,
    ui.Image image,
    Rect dest, {
    ColorFilter? filter,
  }) {
    final src = _coverSrc(image.width.toDouble(), image.height.toDouble(), dest);
    canvas.drawImageRect(
      image,
      src,
      dest,
      Paint()
        ..filterQuality = FilterQuality.high
        ..colorFilter = filter,
    );
  }

  ColorFilter? _placedFilter(PlacedPhoto? placed) {
    if (placed == null || placed.filter == 'none') return null;
    for (final id in PhotoFilterId.values) {
      if (id.name == placed.filter) return filterFor(id);
    }
    return null;
  }

  Rect _coverSrc(double iw, double ih, Rect dest) {
    final input = iw / ih;
    final output = dest.width / dest.height;
    if (input > output) {
      final w = ih * output;
      final x = (iw - w) / 2;
      return Rect.fromLTWH(x, 0, w, ih);
    }
    final h = iw / output;
    final y = (ih - h) / 2;
    return Rect.fromLTWH(0, y, iw, h);
  }

  Future<ui.Image?> _load(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }
}

ColorFilter? filterFor(PhotoFilterId id) {
  switch (id) {
    case PhotoFilterId.none:
      return null;
    case PhotoFilterId.sepia:
      return const ColorFilter.matrix([
        0.393, 0.769, 0.189, 0, 0,
        0.349, 0.686, 0.168, 0, 0,
        0.272, 0.534, 0.131, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    case PhotoFilterId.noir:
      return const ColorFilter.matrix([
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    case PhotoFilterId.vignette:
      return const ColorFilter.mode(Color(0x33000000), BlendMode.multiply);
    case PhotoFilterId.bloom:
      return const ColorFilter.mode(Color(0x22FFE6A0), BlendMode.screen);
    case PhotoFilterId.instant:
      return const ColorFilter.mode(Color(0x33FFB38A), BlendMode.overlay);
    case PhotoFilterId.comic:
      return const ColorFilter.mode(Color(0xFF1A1A1A), BlendMode.modulate);
    case PhotoFilterId.enhance:
      return const ColorFilter.matrix([
        1.08, 0.04, 0.0, 0, 8,
        0.02, 1.05, 0.0, 0, 6,
        0.0, 0.02, 0.98, 0, 4,
        0, 0, 0, 1, 0,
      ]);
  }
}
