import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../core/theme/tokens.dart';
import '../data/repositories/album_repository.dart';
import '../domain/book_models.dart';
import '../domain/slot_crop.dart';
import 'export_service.dart';

/// Off-screen book painter used for spread PNG export and 9:16 flip reels.
class BookPainter {
  Future<ui.Image?> load(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      return (await codec.getNextFrame()).image;
    } catch (_) {
      return null;
    }
  }

  Future<ui.Image> paintSpread({
    required PageDetail? left,
    required PageDetail? right,
    required BookCoverTheme theme,
    required Size size,
    double turn = 0,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    _studio(canvas, size);

    final book = _bookRect(size);
    final leftRect = Rect.fromLTWH(book.left, book.top, book.width / 2, book.height);
    final rightRect = Rect.fromLTWH(book.center.dx, book.top, book.width / 2, book.height);

    await _page(canvas, leftRect, left, theme, isLeft: true);
    await _page(canvas, rightRect, right, theme, isLeft: false);

    if (turn > 0) {
      canvas.save();
      canvas.clipRect(rightRect);
      final pivot = rightRect.topLeft;
      canvas.translate(pivot.dx, pivot.dy);
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateY(-turn * 3.05);
      canvas.transform(matrix.storage);
      canvas.translate(-pivot.dx, -pivot.dy);
      canvas.drawRect(
        rightRect,
        Paint()..color = theme.coverColor.withValues(alpha: 0.15 + turn * 0.4),
      );
      canvas.restore();
    }

    final picture = recorder.endRecording();
    return picture.toImage(size.width.toInt(), size.height.toInt());
  }

  Future<ui.Image> paintCover({
    required String title,
    required BookCoverTheme theme,
    String? coverPath,
    required Size size,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    _studio(canvas, size);
    final cover = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.62,
      height: size.height * 0.78,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cover, const Radius.circular(10)),
      Paint()..color = theme.coverColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(cover.left, cover.top, 18, cover.height),
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );
    final photo = await load(coverPath);
    if (photo != null) {
      final photoRect = Rect.fromLTWH(
        cover.left + 36,
        cover.top + 48,
        cover.width - 56,
        cover.height * 0.48,
      );
      canvas.drawImageRect(
        photo,
        Rect.fromLTWH(0, 0, photo.width.toDouble(), photo.height.toDouble()),
        photoRect,
        Paint()..filterQuality = FilterQuality.high,
      );
    }
    final tp = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          color: theme.foilColor,
          fontSize: cover.width * 0.08,
          fontWeight: FontWeight.w600,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: cover.width - 40);
    tp.paint(
      canvas,
      Offset(cover.center.dx - tp.width / 2, cover.bottom - 90),
    );
    final picture = recorder.endRecording();
    return picture.toImage(size.width.toInt(), size.height.toInt());
  }

  Future<void> _page(
    Canvas canvas,
    Rect rect,
    PageDetail? page,
    BookCoverTheme theme, {
    required bool isLeft,
  }) async {
    canvas.drawRect(rect, Paint()..color = MbTokens.paper);
    canvas.drawRect(
      isLeft
          ? Rect.fromLTWH(rect.right - 10, rect.top, 10, rect.height)
          : Rect.fromLTWH(rect.left, rect.top, 10, rect.height),
      Paint()..color = Colors.black.withValues(alpha: 0.06),
    );
    if (page == null) return;
    final layout = page.layout;
    for (var i = 0; i < layout.slots.length; i++) {
      final slotRect = layout.slots[i];
      final dest = Rect.fromLTWH(
        rect.left + slotRect.left * rect.width,
        rect.top + slotRect.top * rect.height,
        slotRect.width * rect.width,
        slotRect.height * rect.height,
      );
      final slot = page.slots.where((s) => s.slotIndex == i).firstOrNull;
      final image = await load(slot?.imagePath);
      if (image == null) {
        final dash = Paint()
          ..color = MbTokens.slotDash
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRect(dest.deflate(4), dash);
      } else {
        canvas.save();
        canvas.clipRect(dest);
        final scale = slot?.scale ?? 1;
        final cover = SlotCrop.coverSize(
          frameWidth: dest.width,
          frameHeight: dest.height,
          imageWidth: image.width.toDouble(),
          imageHeight: image.height.toDouble(),
        );
        final grown = Rect.fromCenter(
          center: dest.center.translate(
            (slot?.offsetX ?? 0) * dest.width,
            (slot?.offsetY ?? 0) * dest.height,
          ),
          width: cover.width * scale,
          height: cover.height * scale,
        );
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          grown,
          Paint()..filterQuality = FilterQuality.high,
        );
        canvas.restore();
      }
      if ((slot?.caption ?? '').isNotEmpty) {
        final tp = TextPainter(
          text: TextSpan(
            text: slot!.caption,
            style: const TextStyle(
              color: MbTokens.inkSoft,
              fontSize: 16,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: dest.width);
        tp.paint(canvas, Offset(dest.left, dest.bottom + 4));
      }
    }
  }

  void _studio(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          [MbTokens.studio, MbTokens.studioDeep],
        ),
    );
  }

  Rect _bookRect(Size size) {
    final maxW = size.width * 0.9;
    final maxH = size.height * 0.78;
    var width = maxW;
    var height = width / MbTokens.spreadAspect;
    if (height > maxH) {
      height = maxH;
      width = height * MbTokens.spreadAspect;
    }
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: width,
      height: height,
    );
  }

}

class FlipReelExporter {
  FlipReelExporter(this.encoder);
  final NativeVideoEncoder encoder;
  final painter = BookPainter();
  final _uuid = const Uuid();

  Future<File> exportAlbum({
    required AlbumDetail detail,
    String? audioPath,
  }) async {
    const size = Size(1080, 1920);
    final tmp = await getTemporaryDirectory();
    final folder = Directory(p.join(tmp.path, 'reel_${_uuid.v4()}'));
    await folder.create(recursive: true);
    final frames = <String>[];

    Future<void> save(ui.Image image, String name) async {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File(p.join(folder.path, name));
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      frames.add(file.path);
    }

    final cover = await painter.paintCover(
      title: detail.album.title,
      theme: detail.theme,
      coverPath: detail.album.coverPhotoPath,
      size: size,
    );
    for (var i = 0; i < 8; i++) {
      await save(cover, 'c_$i.png');
    }

    for (var s = 0; s < detail.spreadCount; s++) {
      final left = s * 2 < detail.pages.length ? detail.pages[s * 2] : null;
      final right =
          s * 2 + 1 < detail.pages.length ? detail.pages[s * 2 + 1] : null;
      final still = await painter.paintSpread(
        left: left,
        right: right,
        theme: detail.theme,
        size: size,
      );
      for (var i = 0; i < 10; i++) {
        await save(still, 's${s}_$i.png');
      }
      if (s < detail.spreadCount - 1) {
        for (var t = 1; t <= 8; t++) {
          final turning = await painter.paintSpread(
            left: left,
            right: right,
            theme: detail.theme,
            size: size,
            turn: t / 8,
          );
          await save(turning, 't${s}_$t.png');
        }
      }
    }

    final out = p.join(tmp.path, 'album_reel_${_uuid.v4()}.mp4');
    await encoder.encodeFrames(
      frames: frames,
      outputPath: out,
      width: 1080,
      height: 1920,
      fps: 12,
      audioPath: audioPath,
    );
    return File(out);
  }
}
